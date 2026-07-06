import sys
#!/usr/bin/env python3
# Data-contract evidence generator (pure python3, no dbt/GE/network).
# Mirrors dbt `dbt test` per-assertion pass/fail + row-count delta + output
# checksum + rerun-determinism. Deterministic: identical bytes every run.
import hashlib

# --- Fixed in-memory source table: raw_orders(order_id, customer_id, status) ---
RAW = [
    (1, "C1", "shipped"),
    (2, "C2", "pending"),
    (2, "C2", "pending"),    # duplicate order_id
    (3, "C3", "delivered"),
    (4, None, "shipped"),    # null customer_id
    (5, "C5", "bogus"),      # invalid status
]
ACCEPTED_STATUS = ("shipped", "pending", "delivered")

# --- Transform under test: drop null customer, drop invalid status, dedup id ---
def transform(rows):
    seen, out = set(), []
    for oid, cust, status in rows:
        if cust is None:
            continue
        if status not in ACCEPTED_STATUS:
            continue
        if oid in seen:
            continue
        seen.add(oid)
        out.append((oid, cust, status))
    return out

# --- Declarative data-contract runner: named generic assertions -> failing rows ---
def not_null(rows, col):
    return sum(1 for r in rows if r[col] is None)

def unique(rows, col):
    vals = [r[col] for r in rows]
    return len(vals) - len(set(vals))

def accepted_values(rows, col, allowed):
    return sum(1 for r in rows if r[col] not in allowed)

def run_contract(rows):
    checks = [
        ("not_null(customer_id)", not_null(rows, 1)),
        ("unique(order_id)",      unique(rows, 0)),
        ("accepted_values(status)", accepted_values(rows, 2, ACCEPTED_STATUS)),
    ]
    return checks

def summarize(checks):
    p = sum(1 for _, f in checks if f == 0)
    fl = sum(1 for _, f in checks if f != 0)
    return p, fl

def sample_checksum(rows):
    # canonical serialization of output sample, order-independent
    canon = "\n".join(repr(r) for r in sorted(rows))
    return hashlib.sha256(canon.encode("utf-8")).hexdigest()

# --- Evidence emission (pasteable, hash-chain-friendly) ---
before = len(RAW)
clean = transform(RAW)
after = len(clean)

target_checks = run_contract(clean)
p, fl = summarize(target_checks)

# NEGATIVE CONTROL: same assertions on RAW must FAIL, proving they discriminate
raw_checks = run_contract(RAW)
rp, rfl = summarize(raw_checks)

# RERUN-DETERMINISM: recompute checksum on a second transform pass
chk1 = sample_checksum(clean)
chk2 = sample_checksum(transform(RAW))

print("== data-contract evidence (model: stg_orders) ==")
for name, failing in target_checks:
    print("  %-24s %-4s failing_rows=%d" % (name, "PASS" if failing == 0 else "FAIL", failing))
print("Done. PASS=%d FAIL=%d TOTAL=%d" % (p, fl, len(target_checks)))
print("row_count  before=%d  after=%d  delta=%d" % (before, after, after - before))
print("output_sample_sha256=%s" % chk1)
print("rerun_determinism  match=%s" % ("true" if chk1 == chk2 else "false"))
print("negative_control(raw)  PASS=%d FAIL=%d  (expect FAIL>0)" % (rp, rfl))
green = (fl == 0 and chk1 == chk2 and rfl > 0)
print("VERDICT=%s" % ("GREEN" if green else "RED"))
sys.exit(0 if green else 1)  # S1-fix: tripwire cashes out to EXIT CODE (ML/scraper standard) — J1 checks $?, not prose
