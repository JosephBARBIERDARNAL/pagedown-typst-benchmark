#!/usr/bin/env bash
# bench.sh — minimal benchmarking harness for the pagedown vs typst comparison
#
#   bench.sh pagedown N            run N pagedown renders, print "run<TAB>seconds" lines
#   bench.sh typst    N            same, for the quarto+typst pipeline
#   bench.sh typst-direct N        same, for the bare typst (no quarto) pipeline
#   bench.sh --report a.tsv ...    summarise N TSVs side by side
set -euo pipefail

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

now() { python3 -c 'import time; print(f"{time.perf_counter():.6f}")'; }

run_pagedown() {
  cd pagedown
  CHROMOTE_CHROME="$CHROME" Rscript -e \
    'pagedown::chrome_print("report.Rmd", output = "../output/pagedown.pdf", browser = Sys.getenv("CHROMOTE_CHROME"), timeout = 120)' \
    >/dev/null 2>&1
  cd - >/dev/null
}

run_typst() {
  quarto render typst/report.qmd >/dev/null
  mv typst/report.pdf output/typst.pdf
}

run_typst_direct() {
  typst compile --root . typst-direct/report.typ output/typst-direct.pdf >/dev/null
}

bench() {
  local kind="$1" n="$2"
  echo -e "run\tseconds"
  for i in $(seq 1 "$n"); do
    local t0 t1
    t0=$(now)
    case "$kind" in
      pagedown)     run_pagedown ;;
      typst)        run_typst ;;
      typst-direct) run_typst_direct ;;
      *) echo "unknown bench kind: $kind" >&2; exit 2 ;;
    esac
    t1=$(now)
    awk -v i="$i" -v t0="$t0" -v t1="$t1" 'BEGIN{printf "%d\t%.4f\n", i, t1-t0}'
  done
}

report() {
  python3 - "$@" <<'PY'
import sys, statistics
from pathlib import Path

def load(p):
    rows = [l.strip().split("\t") for l in Path(p).read_text().splitlines()[1:]]
    return [float(r[1]) for r in rows if r and len(r) == 2]

paths = sys.argv[1:]
labels = [Path(p).stem.replace("bench-", "") for p in paths]
data   = [load(p) for p in paths]

def stats(xs):
    return dict(
        n=len(xs),
        mean=statistics.mean(xs),
        median=statistics.median(xs),
        stdev=statistics.stdev(xs) if len(xs) > 1 else 0.0,
        mn=min(xs), mx=max(xs),
    )

hdr = f"{'format':<14}  {'runs':>4}  {'mean(s)':>9}  {'median(s)':>10}  {'min(s)':>8}  {'max(s)':>8}  {'stdev':>7}"
print(hdr)
print("-" * len(hdr))
rows = []
for lbl, xs in zip(labels, data):
    s = stats(xs)
    rows.append((lbl, s))
    print(f"{lbl:<14}  {s['n']:>4}  {s['mean']:>9.3f}  {s['median']:>10.3f}  {s['mn']:>8.3f}  {s['mx']:>8.3f}  {s['stdev']:>7.3f}")

if len(rows) >= 2:
    ordered = sorted(rows, key=lambda r: r[1]['mean'])
    fast = ordered[0]
    print()
    for r in ordered[1:]:
        ratio = r[1]['mean'] / fast[1]['mean']
        print(f"→ {fast[0]} is {ratio:.2f}× faster than {r[0]} on the mean")
PY
}

case "${1:-}" in
  pagedown|typst|typst-direct) bench "$1" "${2:-5}" ;;
  --report)                    shift; report "$@" ;;
  *) echo "usage: $0 {pagedown|typst|typst-direct} N  |  $0 --report file1.tsv ..." >&2; exit 2 ;;
esac
