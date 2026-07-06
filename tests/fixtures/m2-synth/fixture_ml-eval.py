#!/usr/bin/env python3
# ML-EVAL evidence fixture — PURE python3, NO sklearn, NO network, fully deterministic.
# Grounding: scikit-learn model_evaluation (classification_report / confusion_matrix.ravel()->tn,fp,fn,tp
#            / DummyClassifier baseline) + Model Cards, arXiv:1810.03993 (disaggregated per-group report).
# Anti-Goodhart: a lone accuracy scalar is NOT sufficient — we emit per-class P/R/F1, raw TN/FP/FN/TP,
# a disaggregated (per-group) slice, AND a most_frequent baseline the model must beat.
# MACHINE TRIPWIRE: the baseline-beat gate is enforced by process exit code (0=beats baseline,
# 1=does not) — not just a printed sentence a submitter/juror could skim past. A J1 re-runner
# checks `echo $?`, not prose.
import sys

SEED = 42  # INLINE fixed seed — threads through BOTH the split AND the estimator; change it => every number moves.

def lcg(seed):
    # Numerical Recipes LCG: deterministic PRNG, zero imports.
    state = seed & 0xFFFFFFFF
    while True:
        state = (1664525 * state + 1013904223) & 0xFFFFFFFF
        yield state / 0x100000000

def make_dataset(n, seed):
    rng = lcg(seed)
    X, y, group = [], [], []
    for _ in range(n):
        f = next(rng)
        label = 1 if f > 0.55 else 0            # ground-truth generative rule
        noise = next(rng)
        feat = f if noise > 0.20 else 1.0 - f   # label-correlated but noisy feature
        g = 'A' if next(rng) > 0.5 else 'B'      # a protected/subgroup axis (Model Cards)
        X.append(feat); y.append(label); group.append(g)
    return X, y, group

def split(X, y, group, seed, test_frac=0.40):
    # seeded Fisher-Yates shuffle-split == train_test_split(random_state=SEED)
    rng = lcg(seed ^ 0x5DEECE66)
    idx = list(range(len(X)))
    for i in range(len(idx) - 1, 0, -1):
        j = int(next(rng) * (i + 1))
        idx[i], idx[j] = idx[j], idx[i]
    cut = int(len(X) * (1 - test_frac))
    tr, te = idx[:cut], idx[cut:]
    pack = lambda ix: ([X[i] for i in ix], [y[i] for i in ix], [group[i] for i in ix])
    return pack(tr), pack(te)

def fit_threshold(Xtr, ytr, seed):
    # "estimator": pick train-accuracy-maximizing threshold; seeded scan order, strict-improvement tie-break.
    rng = lcg(seed ^ 0xABCD)
    order = sorted(range(1, 20), key=lambda k: next(rng))  # seeded, deterministic scan order
    best_t, best_acc = 0.5, -1.0
    for k in order:
        t = k / 20.0
        acc = sum(1 for x, yy in zip(Xtr, ytr) if (1 if x >= t else 0) == yy) / len(ytr)
        if acc > best_acc:                       # strict '>' => deterministic winner
            best_acc, best_t = acc, t
    return best_t

def predict(X, t):
    return [1 if x >= t else 0 for x in X]

def confusion(y_true, y_pred):
    tn = fp = fn = tp = 0
    for a, p in zip(y_true, y_pred):
        if   a == 0 and p == 0: tn += 1
        elif a == 0 and p == 1: fp += 1
        elif a == 1 and p == 0: fn += 1
        else:                   tp += 1
    return tn, fp, fn, tp

def prf(tp, fp, fn):
    p = tp / (tp + fp) if (tp + fp) else 0.0
    r = tp / (tp + fn) if (tp + fn) else 0.0
    f = 2 * p * r / (p + r) if (p + r) else 0.0
    return p, r, f

def accuracy(y_true, y_pred):
    return sum(1 for a, p in zip(y_true, y_pred) if a == p) / len(y_true)

# --- pipeline -----------------------------------------------------------------
X, y, group = make_dataset(200, SEED)
(Xtr, ytr, _gtr), (Xte, yte, gte) = split(X, y, group, SEED)
t = fit_threshold(Xtr, ytr, SEED)
yp = predict(Xte, t)

tn, fp, fn, tp = confusion(yte, yp)
# per-class: class 1 uses (tp,fp,fn); class 0 is its mirror (tn as its tp, fn as its fp, fp as its fn)
p1, r1, f1 = prf(tp, fp, fn)
p0, r0, f0 = prf(tn, fn, fp)
support0 = tn + fp
support1 = fn + tp
acc = accuracy(yte, yp)
macro_p = (p0 + p1) / 2; macro_r = (r0 + r1) / 2; macro_f = (f0 + f1) / 2

# baseline: DummyClassifier(strategy='most_frequent') fit on TRAIN, scored on TEST
majority = 1 if sum(ytr) * 2 >= len(ytr) else 0
base_pred = [majority] * len(yte)
base_acc = accuracy(yte, base_pred)

# --- evidence block (pasteable, identical every run) --------------------------
print(f"SEED={SEED}  split=train_test_split(test=0.40, random_state=SEED)  estimator=threshold@{t:.2f}")
print("== classification_report (held-out test) ==")
print("              precision    recall  f1-score   support")
print(f"     class 0      {p0:.2f}      {r0:.2f}      {f0:.2f}      {support0:>4}")
print(f"     class 1      {p1:.2f}      {r1:.2f}      {f1:.2f}      {support1:>4}")
print("")
print(f"    accuracy                          {acc:.2f}      {len(yte):>4}")
print(f"   macro avg      {macro_p:.2f}      {macro_r:.2f}      {macro_f:.2f}      {len(yte):>4}")
print("== confusion_matrix.ravel() -> (tn, fp, fn, tp) ==")
print(f"tn={tn}  fp={fp}  fn={fn}  tp={tp}")
print("== disaggregated accuracy (Model Cards per-group slice) ==")
for gval in ('A', 'B'):
    idx = [i for i, gg in enumerate(gte) if gg == gval]
    ga = accuracy([yte[i] for i in idx], [yp[i] for i in idx]) if idx else 0.0
    print(f"group {gval}: acc={ga:.2f}  n={len(idx)}")
print("== baseline gate (DummyClassifier most_frequent) ==")
beats_baseline = acc > base_acc
print(f"model_acc={acc:.2f}  baseline_acc={base_acc:.2f}  lift={acc - base_acc:+.2f}  "
      f"BEATS_BASELINE={beats_baseline}")
sys.exit(0 if beats_baseline else 1)  # non-zero exit == falsifiable anti-Goodhart tripwire
