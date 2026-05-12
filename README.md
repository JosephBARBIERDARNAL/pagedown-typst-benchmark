
![Bar chart comparing PDF rendering times for a 12-page document using three tools: pagedown, Quarto + Typst, and Typst alone. Two grouped comparisons are shown: mean rendering time and median rendering time, each based on 15 runs. For the mean times, pagedown takes 5.9 seconds, Quarto + Typst takes 1.2 seconds, and Typst takes 0.36 seconds. For the median times, pagedown takes 5.8 seconds, Quarto + Typst takes 1.2 seconds, and Typst takes 0.35 seconds. The chart subtitle states that Typst is on average 16.5 times faster than pagedown, while Quarto + Typst is 4.9 times faster than pagedown. It also notes that Typst skips Quarto’s pandoc step by using the bare CLI directly, while Quarto + Typst still uses the Typst engine through Quarto. Pagedown bars are dark red, Quarto + Typst bars are teal, and Typst bars are dark blue. The y-axis ranges from 0 to 6 seconds.](./output.png)

This repository benchmarks rendering the same annual-report style document with three PDF pipelines:

- `pagedown`, via `pagedown::chrome_print()`
- Quarto + Typst, via `quarto render --to typst`
- Typst alone, via `typst compile` (no Quarto, no Pandoc)

The Typst-only pipeline imports the same `typst-template.typ` used by the Quarto pipeline and produces a page-for-page identical PDF — it just skips Quarto's Pandoc conversion step.

The benchmark writes timing data to TSV files and then uses `chart.py` to generate the comparison figure.

## Requirements

Install the command-line tools used by the benchmark:

- `uv`
- `just`
- `Rscript`
- `pagedown` for R
- Quarto
- Pandoc
- `typst` (the standalone CLI)
- Google Chrome

The render scripts currently expect Chrome at:

```sh
/Applications/Google Chrome.app/Contents/MacOS/Google Chrome
```

If Chrome is elsewhere, update the `CHROME` value in `justfile` and `bench.sh`.

Install the Python dependencies with:

```sh
uv sync
```

Install the R package if needed:

```sh
Rscript -e 'install.packages("pagedown")'
```

Check that the required tools are visible:

```sh
just doctor
```

## Reproduce the Results

Run the full benchmark:

```sh
just benchmark
```

By default this performs 15 timed renders for each pipeline. It first renders each PDF once, then writes:

- `output/bench-pagedown.tsv`
- `output/bench-typst.tsv`
- `output/bench-typst-direct.tsv`
- `output/pagedown.pdf`
- `output/typst.pdf`
- `output/typst-direct.pdf`

It also prints a small summary table with the mean, median, minimum, maximum, and standard deviation for each renderer.

To use a different number of runs:

```sh
just runs=5 benchmark
```

Generate the chart from the benchmark TSV files:

```sh
uv run python chart.py
```

This writes:

```sh
output.png
```

## Useful Commands

Render both PDFs without benchmarking:

```sh
just render
```

Render only one pipeline:

```sh
just render-pagedown
just render-typst
just render-typst-direct
```

Remove generated output:

```sh
just clean
```

Absolute timings depend on the local machine, installed versions, and system load, so compare the three pipelines from the same benchmark run.
