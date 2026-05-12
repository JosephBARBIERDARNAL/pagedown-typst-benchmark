# Acme Industries — pagedown vs Quarto+Typst benchmark
#
#   just                  -> list recipes
#   just render-pagedown  -> render pagedown/report.Rmd to output/pagedown.pdf
#   just render-typst     -> render typst/report.qmd      to output/typst.pdf
#   just render           -> render both
#   just benchmark        -> run both N times and print stats (N=10 by default)
#   just clean            -> remove generated files

set shell := ["bash", "-cu"]

# How many runs per format. Override with: just runs=5 benchmark

runs := "15"

# Where the Chrome binary lives on this Mac (pagedown needs it for chrome_print).

CHROME := "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

default:
    @just --list

# ---------------------------------------------------------------- render --

render: render-pagedown render-typst

render-pagedown:
    @mkdir -p output
    @echo "→ rendering pagedown/report.Rmd"
    @cd pagedown && CHROMOTE_CHROME="{{ CHROME }}" Rscript -e \
      'pagedown::chrome_print("report.Rmd", output = "../output/pagedown.pdf", browser = Sys.getenv("CHROMOTE_CHROME"), timeout = 120)'
    @ls -lh output/pagedown.pdf | awk '{print "  ", $5, $9}'

render-typst:
    @mkdir -p output
    @echo "→ rendering typst/report.qmd"
    @quarto render typst/report.qmd --to typst >/dev/null
    @mv typst/report.pdf output/typst.pdf
    @ls -lh output/typst.pdf | awk '{print "  ", $5, $9}'

# ------------------------------------------------------------- benchmark --

benchmark: render
    @mkdir -p output
    @echo
    @echo "Benchmarking ({{ runs }} runs each, A4 PDF, warm caches)"
    @echo "----------------------------------------------------"
    @./bench.sh pagedown {{ runs }} > output/bench-pagedown.tsv
    @./bench.sh typst    {{ runs }} > output/bench-typst.tsv
    @./bench.sh --report output/bench-pagedown.tsv output/bench-typst.tsv

# --------------------------------------------------------------- helpers --

clean:
    rm -rf output typst/.quarto typst/report_files

# Verify the toolchain quickly.
doctor:
    @echo "just     : $(just --version)"
    @echo "Rscript  : $(Rscript --version 2>&1 | head -1)"
    @echo "pagedown : $(Rscript -e 'cat(as.character(packageVersion(\"pagedown\")))')"
    @echo "quarto   : $(quarto --version)"
    @echo "pandoc   : $(pandoc --version | head -1)"
    @echo "chrome   : {{ CHROME }}"
    @[ -x "{{ CHROME }}" ] && echo "         : OK" || echo "         : NOT FOUND"
