import matplotlib.pyplot as plt
import morethemes as mt
import polars as pl
import numpy as np
from highlight_text import fig_text

df = pl.read_csv("output/bench-pagedown.tsv", separator="\t")
pagedown = df["seconds"].to_numpy()

df = pl.read_csv("output/bench-typst.tsv", separator="\t")
typst = df["seconds"].to_numpy()

df = pl.read_csv("output/bench-typst-direct.tsv", separator="\t")
typst_direct = df["seconds"].to_numpy()

n_runs = len(pagedown)

mt.set_theme("lumen")

typst_color = "#00AEC5"
typst_direct_color = "#0F3D5C"
pagedown_color = "#A7171B"
labels = [f"Mean (n={n_runs})", f"Median (n={n_runs})"]


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

typst_direct_mean, _ = mean_ci(typst_direct)
typst_direct_median, _ = median_ci(typst_direct)

pagedown_stats = [pagedown_mean, pagedown_median]
typst_stats = [typst_mean, typst_median]
typst_direct_stats = [typst_direct_mean, typst_direct_median]

x = np.arange(len(labels))
width = 0.25
gap = 0.04
step = width + gap

fig, ax = plt.subplots()
ax.grid(False)

bars1 = ax.bar(x - step, pagedown_stats, width, color=pagedown_color)
bars2 = ax.bar(x, typst_stats, width, color=typst_color)
bars3 = ax.bar(x + step, typst_direct_stats, width, color=typst_direct_color)

ax.bar_label(
    bars1,
    labels=["pagedown" for _ in pagedown_stats],
    color=pagedown_color,
    weight="bold",
    size=8,
    padding=15,
)
ax.bar_label(
    bars1,
    labels=[f"{v:.1f} sec" for v in pagedown_stats],
    padding=3,
    size=8,
)

ax.bar_label(
    bars2,
    labels=["Quarto + Typst" for _ in typst_stats],
    color=typst_color,
    weight="bold",
    padding=15,
    size=8,
)
ax.bar_label(
    bars2,
    labels=[f"{v:.1f} sec" for v in typst_stats],
    padding=3,
    size=8,
)

ax.bar_label(
    bars3,
    labels=["Typst" for _ in typst_direct_stats],
    color=typst_direct_color,
    weight="bold",
    size=8,
    padding=15,
)
ax.bar_label(
    bars3,
    labels=[f"{v:.2f} sec" for v in typst_direct_stats],
    size=8,
    padding=3,
)

ymax = max(pagedown_stats) * 1.1
ax.set_ylim(top=ymax)
ax.set_xticks(x)
ax.set_xticklabels(labels)
ax.set_yticks(ax.get_yticks()[:-1])
ax.set_yticklabels([f"{label:.0f}s" for label in ax.get_yticks()], size=8)


speedup_quarto = pagedown_mean / typst_mean
speedup_direct = pagedown_mean / typst_direct_mean

fig_text(
    x=0.05,
    y=0.97,
    s="Rendering a 12-page PDF with <pagedown>, <Quarto + Typst>, and <Typst> alone",
    highlight_textprops=[
        {"color": pagedown_color, "weight": "bold"},
        {"color": typst_color, "weight": "bold"},
        {"color": typst_direct_color, "weight": "bold"},
    ],
)
fig_text(
    x=0.05,
    y=0.92,
    s=(
        f"The generated PDF was rendered {n_runs} times with each tool. On average, <Typst> is <{speedup_direct:.1f}×> faster than <pagedown> and <Quarto + Typst>\nis <{speedup_quarto:.1f}×> faster than <pagedown>. <Typst> via the bare CLI skips Quarto's pandoc step, while <Quarto + Typst> calls the same Typst\nengine through Quarto."
    ),
    size=7,
    color="darkgray",
    va="top",
    highlight_textprops=[
        {"color": typst_direct_color, "weight": "bold"},
        {"weight": "bold"},
        {"color": pagedown_color, "weight": "bold"},
        {"color": typst_color, "weight": "bold"},
        {"weight": "bold"},
        {"color": pagedown_color, "weight": "bold"},
        {"color": typst_direct_color, "weight": "bold"},
        {"color": typst_color, "weight": "bold"},
    ],
)

plt.savefig("output.png", dpi=300, bbox_inches="tight")
