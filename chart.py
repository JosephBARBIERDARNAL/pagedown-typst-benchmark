import matplotlib.pyplot as plt
import morethemes as mt
import polars as pl
import numpy as np
from highlight_text import fig_text
from pyfonts import load_google_font

df = pl.read_csv("output/bench-pagedown.tsv", separator="\t")
pagedown = df["seconds"].to_numpy()

df = pl.read_csv("output/bench-typst.tsv", separator="\t")
typst = df["seconds"].to_numpy()

mt.set_theme("lumen")

typst_color = "#00AEC5"
pagedown_color = "#A7171B"
labels = ["Mean (n=15)", "Median (n=15)"]


def mean_ci(x):
    mean = np.mean(x)
    ci = 1.96 * np.std(x, ddof=1) / np.sqrt(len(x))
    return mean, ci


def median_ci(x, n_boot=10_000):
    med = np.median(x)

    boot = np.random.choice(x, (n_boot, len(x)), replace=True)
    meds = np.median(boot, axis=1)

    low, high = np.percentile(meds, [2.5, 97.5])
    ci = (high - low) / 2

    return med, ci


pagedown_mean, _ = mean_ci(pagedown)
pagedown_median, _ = median_ci(pagedown)

typst_mean, _ = mean_ci(typst)
typst_median, _ = median_ci(typst)

pagedown_stats = [pagedown_mean, pagedown_median]
typst_stats = [typst_mean, typst_median]

x = np.arange(len(labels))
width = 0.32
gap = 0.06

fig, ax = plt.subplots()
ax.grid(False)

bars1 = ax.bar(x - (width + gap) / 2, pagedown_stats, width, color=pagedown_color)
bars2 = ax.bar(x + (width + gap) / 2, typst_stats, width, color=typst_color)

ax.bar_label(
    bars1,
    labels=["pagedown" for v in pagedown_stats],
    color=pagedown_color,
    weight="bold",
    padding=15,
)
ax.bar_label(
    bars1,
    labels=[f"{v:.1f} sec" for v in pagedown_stats],
    padding=3,
)

ax.bar_label(
    bars2,
    labels=["Typst" for v in typst_stats],
    color=typst_color,
    weight="bold",
    padding=15,
)
ax.bar_label(
    bars2,
    labels=[f"{v:.1f} sec" for v in typst_stats],
    padding=3,
)

ax.set_xticks(x)
ax.set_xticklabels(labels)
ax.set_yticks(ax.get_yticks()[:-1])
ax.set_yticklabels([f"{label:.0f}s" for label in ax.get_yticks()], size=8)


fig_text(
    x=0.05,
    y=0.97,
    s="Performance comparison of rendering a 12-page PDF using <pagedown> and <Typst>",
    highlight_textprops=[
        {"color": pagedown_color, "weight": "bold"},
        {"color": typst_color, "weight": "bold"},
    ],
)
fig_text(
    x=0.05,
    y=0.92,
    s="<Typst> rendering uses Quarto, while <pagedown> rendering uses R Markdown and <chrome_print()>. The generated PDF was\nrendered 15 times with each tool. On average, <Typst> <is 4.87×> faster than <pagedown>.",
    size=7,
    color="darkgray",
    va="top",
    highlight_textprops=[
        {"color": typst_color, "weight": "bold"},
        {"color": pagedown_color, "weight": "bold"},
        {"font": load_google_font("Source Code Pro")},
        {"color": typst_color, "weight": "bold"},
        {"weight": "bold"},
        {"color": pagedown_color, "weight": "bold"},
    ],
)

plt.savefig("output.png", dpi=300, bbox_inches="tight")
