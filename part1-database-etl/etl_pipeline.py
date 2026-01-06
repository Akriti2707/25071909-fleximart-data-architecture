import os
import re
import sys
import logging
from datetime import datetime
import pandas as pd
import mysql.connector

# optional .env support
try:
    from dotenv import load_dotenv
    load_dotenv()
except Exception:
    pass

logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")


def pick_col(df, options):
    # find a column by name (case-insensitive)
    cols = {c.lower(): c for c in df.columns}
    for o in options:
        if o.lower() in cols:
            return cols[o.lower()]
    raise KeyError(f"Missing column. Tried: {options}. Found: {list(df.columns)}")


def clean_phone(x):
    if pd.isna(x):
        return None
    digits = re.sub(r"\D", "", str(x))
    if len(digits) == 12 and digits.startswith("91"):
        digits = digits[2:]
    elif len(digits) == 11 and digits.startswith("0"):
        digits = digits[1:]
    elif len(digits) > 10:
        digits = digits[-10:]
    elif len(digits) < 10:
        digits = digits.zfill(10)
    return "+91-" + digits


def clean_date(x):
    if pd.isna(x):
        return None
    s = str(x).strip()
    for fmt in ("%Y-%m-%d", "%d/%m/%Y", "%m/%d/%Y", "%d-%m-%Y", "%m-%d-%Y","%Y/%m/%d"):
        try:
            return datetime.strptime(s, fmt).date()
        except Exception:
            pass
    dt = pd.to_datetime(s, dayfirst=True, errors="coerce")
    if pd.isna(dt):
        return None
    return dt.date()


def clean_category(x):
    if pd.isna(x):
        return "Unknown"
    s = str(x).strip().lower()
    mapping = {
        "electronics": "Electronics",
        "electronic": "Electronics",
        "fashion": "Fashion",
        "groceries": "Groceries",
        "grocery": "Groceries",
    }
    return mapping.get(s, s.title())


def make_email(first_name, last_name, raw_id):
    base = f"{str(first_name).strip()}.{str(last_name).strip()}".lower()
    safe = re.sub(r"\W+", "", str(raw_id).lower())
    return f"{base}.{safe}@example.com"


def get_conn():
    return mysql.connector.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=int(os.getenv("DB_PORT", "3306")),
        user=os.getenv("DB_USER", "root"),
        password=os.getenv("DB_PASSWORD", ""),
        database=os.getenv("DB_NAME", "fleximart"),
        autocommit=False,
    )


def main():
    # paths
    data_dir = os.path.join(os.path.dirname(__file__), "..", "data")
    c_path = os.path.join(data_dir, "customers_raw.csv")
    p_path = os.path.join(data_dir, "products_raw.csv")
    s_path = os.path.join(data_dir, "sales_raw.csv")

    # counters for report
    dq = {
        "customers": {"processed": 0, "dups": 0, "missing_fixed": 0, "dropped": 0, "loaded": 0},
        "products": {"processed": 0, "dups": 0, "missing_fixed": 0, "dropped": 0, "loaded": 0},
        "sales": {"processed": 0, "dups": 0, "missing_fixed": 0, "dropped": 0, "loaded": 0},
    }

    # ========== EXTRACT ==========
    customers = pd.read_csv(c_path)
    products = pd.read_csv(p_path)
    sales = pd.read_csv(s_path)

    dq["customers"]["processed"] = len(customers)
    dq["products"]["processed"] = len(products)
    dq["sales"]["processed"] = len(sales)

    # ========== TRANSFORM: CUSTOMERS ==========
    c = customers.copy()
    cid = pick_col(c, ["customer_id", "cust_id", "id"])
    fn = pick_col(c, ["first_name", "firstname", "first"])
    ln = pick_col(c, ["last_name", "lastname", "last"])
    em = pick_col(c, ["email", "email_id"])
    ph = pick_col(c, ["phone", "phone_number", "mobile"])
    city = pick_col(c, ["city"])
    reg = pick_col(c, ["registration_date", "registered_on", "reg_date"])

    before = len(c)
    c = c.drop_duplicates()
    dq["customers"]["dups"] += before - len(c)

    c[ph] = c[ph].apply(clean_phone)
    c[reg] = c[reg].apply(clean_date)

    # fill missing email (schema needs UNIQUE + NOT NULL)
    missing_email = c[em].isna().sum() + (c[em].astype(str).str.strip() == "").sum()
    dq["customers"]["missing_fixed"] += int(missing_email)

    def fix_email_row(r):
        v = r[em]
        if pd.isna(v) or str(v).strip() == "":
            return make_email(r[fn], r[ln], r[cid])
        return str(v).strip().lower()

    c[em] = c.apply(fix_email_row, axis=1)

    # enforce unique email
    before2 = len(c)
    c = c.sort_values([em, reg]).drop_duplicates(subset=[em], keep="first")
    dq["customers"]["dups"] += before2 - len(c)

    c_clean = pd.DataFrame({
        "raw_customer_id": c[cid].astype(str),
        "first_name": c[fn].astype(str).str.strip(),
        "last_name": c[ln].astype(str).str.strip(),
        "email": c[em].astype(str).str.strip().str.lower(),
        "phone": c[ph],
        "city": c[city].astype(str).str.strip(),
        "registration_date": c[reg],
    })

    # ========== TRANSFORM: PRODUCTS ==========
    p = products.copy()
    pid = pick_col(p, ["product_id", "prod_id", "id"])
    pname = pick_col(p, ["product_name", "name"])
    pcat = pick_col(p, ["category"])
    pprice = pick_col(p, ["price", "unit_price"])
    pstock = pick_col(p, ["stock_quantity", "stock", "qty_in_stock"])

    before = len(p)
    p = p.drop_duplicates()
    dq["products"]["dups"] += before - len(p)

    p[pcat] = p[pcat].apply(clean_category)

    p[pstock] = pd.to_numeric(p[pstock], errors="coerce")
    miss_stock = p[pstock].isna().sum()
    dq["products"]["missing_fixed"] += int(miss_stock)
    p[pstock] = p[pstock].fillna(0).astype(int)

    p[pprice] = pd.to_numeric(p[pprice], errors="coerce")
    miss_price = p[pprice].isna().sum()
    dq["products"]["missing_fixed"] += int(miss_price)

    # median by category, then overall median
    p[pprice] = p.groupby(pcat)[pprice].transform(lambda s: s.fillna(s.median()))
    p[pprice] = p[pprice].fillna(p[pprice].median()).round(2)

    p_clean = pd.DataFrame({
        "raw_product_id": p[pid].astype(str),
        "product_name": p[pname].astype(str).str.strip(),
        "category": p[pcat].astype(str).str.strip(),
        "price": p[pprice].astype(float).round(2),
        "stock_quantity": p[pstock].astype(int),
    })

    # ========== TRANSFORM: SALES ==========
    s = sales.copy()
    scust = pick_col(s, ["customer_id", "cust_id"])
    sprod = pick_col(s, ["product_id", "prod_id"])
    sdate = pick_col(s, ["transaction_date", "order_date", "date"])
    sqty = pick_col(s, ["quantity", "qty"])
    sunit = pick_col(s, ["unit_price", "price"])

    try:
        sstatus = pick_col(s, ["status"])
    except KeyError:
        sstatus = None

    before = len(s)
    s = s.drop_duplicates()
    dq["sales"]["dups"] += before - len(s)

    s[sdate] = s[sdate].apply(clean_date)
    s[sqty] = pd.to_numeric(s[sqty], errors="coerce")
    s[sunit] = pd.to_numeric(s[sunit], errors="coerce")

    # drop rows missing required keys (keeps FK integrity)
    before2 = len(s)
    s = s.dropna(subset=[scust, sprod, sdate, sqty, sunit])
    dq["sales"]["dropped"] += before2 - len(s)

    if sstatus is None:
        s["status_clean"] = "Pending"
    else:
        s["status_clean"] = s[sstatus].astype(str).str.strip()
        s.loc[s["status_clean"] == "", "status_clean"] = "Pending"
        s["status_clean"] = s["status_clean"].fillna("Pending")

    s_clean = pd.DataFrame({
        "raw_customer_id": s[scust].astype(str),
        "raw_product_id": s[sprod].astype(str),
        "order_date": s[sdate],
        "quantity": s[sqty].astype(int),
        "unit_price": s[sunit].astype(float).round(2),
        "status": s["status_clean"],
    })

    # ========== LOAD ==========
    conn = None
    try:
        conn = get_conn()
        cur = conn.cursor()

        # clean run each time
        cur.execute("SET FOREIGN_KEY_CHECKS=0;")
        for t in ["order_items", "orders", "products", "customers"]:
            cur.execute(f"TRUNCATE TABLE {t};")
        cur.execute("SET FOREIGN_KEY_CHECKS=1;")
        conn.commit()

        # insert customers
        cur.executemany(
            "INSERT INTO customers (first_name, last_name, email, phone, city, registration_date) VALUES (%s,%s,%s,%s,%s,%s)",
            [(r.first_name, r.last_name, r.email, r.phone, r.city, r.registration_date)
             for r in c_clean.itertuples(index=False)]
        )
        dq["customers"]["loaded"] = len(c_clean)

        # map raw_customer_id -> db customer_id using email (unique)
        cur.execute("SELECT customer_id, email FROM customers;")
        email_to_id = {e.lower(): i for (i, e) in cur.fetchall()}
        raw_cust_to_id = {r.raw_customer_id: email_to_id[r.email.lower()] for r in c_clean.itertuples(index=False)}

        # insert products
        cur.executemany(
            "INSERT INTO products (product_name, category, price, stock_quantity) VALUES (%s,%s,%s,%s)",
            [(r.product_name, r.category, float(r.price), int(r.stock_quantity))
             for r in p_clean.itertuples(index=False)]
        )
        dq["products"]["loaded"] = len(p_clean)

        # map raw_product_id -> db product_id using (name, category)
        cur.execute("SELECT product_id, product_name, category FROM products;")
        key_to_id = {(n, ccat): i for (i, n, ccat) in cur.fetchall()}
        raw_prod_to_id = {r.raw_product_id: key_to_id[(r.product_name, r.category)]
                          for r in p_clean.itertuples(index=False)}

        # sales -> orders + order_items (1 row = 1 order)
        order_sql = "INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES (%s,%s,%s,%s)"
        item_sql = "INSERT INTO order_items (order_id, product_id, quantity, unit_price, subtotal) VALUES (%s,%s,%s,%s,%s)"

        loaded_sales = 0
        for r in s_clean.itertuples(index=False):
            if r.raw_customer_id not in raw_cust_to_id:
                continue
            if r.raw_product_id not in raw_prod_to_id:
                continue

            customer_id = raw_cust_to_id[r.raw_customer_id]
            product_id = raw_prod_to_id[r.raw_product_id]

            subtotal = round(int(r.quantity) * float(r.unit_price), 2)

            cur.execute(order_sql, (customer_id, r.order_date, subtotal, r.status))
            order_id = cur.lastrowid

            cur.execute(item_sql, (order_id, product_id, int(r.quantity), float(r.unit_price), subtotal))
            loaded_sales += 1

        dq["sales"]["loaded"] = loaded_sales
        conn.commit()

    except mysql.connector.Error as e:
        if conn:
            conn.rollback()
        logging.error("MySQL error: %s", e)
        raise
    finally:
        if conn:
            conn.close()

    # ========== REPORT ==========
    report_path = os.path.join(os.path.dirname(__file__), "data_quality_report.txt")
    with open(report_path, "w", encoding="utf-8") as f:
        f.write("FlexiMart Data Quality Report\n")
        f.write("================================\n\n")

        def write_block(label, stats):
            f.write(f"{label}\n")
            f.write("--------------------------------\n")
            f.write(f"Records processed:      {stats['processed']}\n")
            f.write(f"Duplicates removed:     {stats['dups']}\n")
            f.write(f"Missing values handled: {stats['missing_fixed']}\n")
            f.write(f"Rows dropped:           {stats['dropped']}\n")
            f.write(f"Records loaded:         {stats['loaded']}\n\n")

        write_block("customers_raw.csv", dq["customers"])
        write_block("products_raw.csv", dq["products"])
        write_block("sales_raw.csv", dq["sales"])

    logging.info("ETL done.")
    logging.info("Loaded customers=%s, products=%s, orders=%s",
                 dq["customers"]["loaded"], dq["products"]["loaded"], dq["sales"]["loaded"])


if __name__ == "__main__":
    main()
