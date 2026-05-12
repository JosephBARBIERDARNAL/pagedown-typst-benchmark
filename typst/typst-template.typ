// =========================================================================
// ACME INDUSTRIES — Brand template for the Quarto/Typst report
// -------------------------------------------------------------------------
// Mirrors the pagedown CSS: same palette, typography, page geometry,
// cover page, running header & footer, and styled block elements.
// =========================================================================

// ---- Pandoc/Quarto helper (also defined by the Quarto pipeline) ---------
#let content-to-string(content) = {
  if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(content-to-string).join("")
  } else if content.has("body") {
    content-to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

// ---- Brand tokens --------------------------------------------------------
#let primary = rgb("#0F3D5C")
#let accent  = rgb("#E07A1F")
#let neutral = rgb("#F4F1EC")
#let ink     = rgb("#1A2530")
#let muted   = rgb("#5B6770")
#let rule    = rgb("#D6CFC4")

#let sansfont  = ("Helvetica Neue", "Helvetica", "Arial")
#let seriffont = ("Georgia", "Times New Roman")

// ---- Reusable block helpers (exposed to the document) --------------------

#let callout(body) = block(
  width: 100%,
  fill: neutral,
  inset: (x: 5mm, y: 4mm),
  stroke: (left: 3pt + accent),
  breakable: false,
  spacing: 5mm,
)[
  #set text(font: sansfont, size: 10pt, fill: ink)
  #set par(justify: false, leading: 0.55em)
  #body
]

#let lead(body) = block(below: 6mm, above: 4mm)[
  #set text(font: sansfont, size: 13pt, fill: primary, weight: 300)
  #set par(justify: false, leading: 0.45em)
  #body
]

#let signoff(body) = block(above: 6mm)[
  #set text(font: sansfont, size: 10.5pt, fill: ink)
  #set par(justify: false, leading: 0.55em)
  #body
]

#let disclaimer(body) = block(above: 10mm)[
  #line(length: 100%, stroke: 0.4pt + rule)
  #v(2mm)
  #set text(font: sansfont, size: 8.5pt, fill: muted)
  #set par(justify: false, leading: 0.55em)
  #body
]

#let kpi(body) = block(breakable: false, above: 4mm, below: 4mm)[#body]

#let numbered(body) = block[
  #set text(fill: ink)
  #body
]

// ---- Cover page ----------------------------------------------------------
#let acme-cover(title, subtitle, author, date) = {
  page(
    paper: "a4",
    margin: 0pt,
    header: none,
    footer: none,
    background: rect(width: 100%, height: 100%, fill: primary, stroke: none),
  )[
    #pad(top: 32mm, left: 24mm, right: 24mm, bottom: 24mm)[
      #rect(width: 30mm, height: 2pt, fill: accent, stroke: none)
      #v(12mm)
      #set text(fill: neutral, font: sansfont)
      #block[
        #set par(leading: 0.4em)
        #text(size: 56pt, weight: 800, tracking: -1.1pt)[#title]
      ]
      #v(4mm)
      #text(size: 18pt, weight: 300, fill: accent, tracking: 0.4pt)[#subtitle]
      #v(80mm)
      #text(size: 11pt, tracking: 2.4pt)[#upper(author)]
      #v(2mm)
      #text(size: 10pt, fill: accent, tracking: 1pt)[#upper(date)]
    ]
  ]
}

// ---- The article entry point used by typst-show.typ ----------------------
#let article(
  title: none,
  subtitle: none,
  authors: none,
  keywords: (),
  date: none,
  abstract-title: none,
  abstract: none,
  thanks: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: none,
  fontsize: 10.5pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: none,
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  mathfont: none,
  codefont: none,
  linestretch: 1,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  // PDF metadata
  set document(
    title: if title != none { content-to-string(title) } else { "" },
    author: if authors != none and authors != () {
      authors.map(a => content-to-string(a.name)).join(", ")
    } else { "" },
    keywords: keywords,
  )

  // -- Cover page (suppresses header/footer via a one-off page rule) ------
  if title != none {
    acme-cover(title, subtitle, [#authors.map(a => a.name).join(", ")], date)
  }

  // -- Regular page layout: A4, brand running header & footer ------------
  set page(
    paper: "a4",
    margin: (x: 20mm, y: 22mm),
    header: context {
      let elems = query(selector(heading.where(level: 1)).before(here()))
      let chapter = if elems.len() > 0 { elems.last().body } else { [] }
      stack(dir: ttb,
        grid(
          columns: (1fr, 1fr),
          align: (left + horizon, right + horizon),
          text(font: sansfont, size: 8.5pt, fill: muted, tracking: 1.4pt)[
            #upper(chapter)
          ],
          text(font: sansfont, size: 8.5pt, fill: muted)[
            Acme Industries · Annual Report 2026
          ],
        ),
        v(2mm),
        line(length: 100%, stroke: 0.4pt + rule),
      )
    },
    footer: grid(
      columns: (1fr, 1fr),
      align: (left + horizon, right + horizon),
      text(font: sansfont, size: 8pt, fill: muted)[
        Confidential — for shareholder distribution
      ],
      context text(font: sansfont, size: 10pt, weight: 700, fill: primary)[
        #counter(page).display()
      ],
    ),
  )

  // Reset the page counter so content begins at page 2 (cover is 1)
  // (Default behaviour already; we leave it.)

  // -- Body typography ---------------------------------------------------
  set text(
    font: seriffont,
    size: fontsize,
    fill: ink,
    lang: lang,
    region: region,
  )
  set par(justify: true, leading: 0.6em, first-line-indent: 0pt)

  // -- Headings ----------------------------------------------------------
  set heading(numbering: sectionnumbering)

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    block(below: 4mm, above: 0mm)[
      #set text(font: sansfont, size: 26pt, fill: primary, weight: 800, tracking: -0.3pt)
      #set par(leading: 0.4em)
      #it.body
    ]
    line(length: 100%, stroke: 1.2pt + accent)
    v(3mm)
  }

  show heading.where(level: 2): it => {
    v(6mm, weak: true)
    block(below: 2mm)[
      #set text(font: sansfont, size: 14pt, fill: primary, weight: 700)
      #box(baseline: -1.2pt, rect(width: 6mm, height: 2.5pt, fill: accent, stroke: none))
      #h(2mm)
      #it.body
    ]
  }

  show heading.where(level: 3): it => {
    v(4mm, weak: true)
    block(below: 1mm)[
      #set text(font: sansfont, size: 10pt, fill: ink, weight: 700, tracking: 1.2pt)
      #upper(it.body)
    ]
  }

  // -- Tables ------------------------------------------------------------
  set table(
    inset: (x: 3mm, y: 2.2mm),
    stroke: 0pt,
    fill: (col, row) => {
      if row == 0 { primary }
      else if calc.rem(row, 2) == 0 { neutral }
      else { white }
    },
  )
  show table.cell: set text(font: sansfont, size: 9.5pt, fill: ink)
  show table.cell.where(y: 0): set text(fill: neutral, weight: 700, tracking: 0.4pt)

  // -- Lists -------------------------------------------------------------
  set list(marker: ([•], [◦]), indent: 2mm, body-indent: 3mm)
  set enum(numbering: n => text(fill: accent, weight: 700)[#n.], indent: 2mm, body-indent: 3mm)
  show list: set text(fill: ink)

  // -- Links -------------------------------------------------------------
  show link: set text(fill: primary)
  show ref:  set text(fill: primary)

  // -- Figures -----------------------------------------------------------
  show figure.caption: it => {
    set text(font: sansfont, size: 8.5pt, fill: muted)
    it.body
  }

  // -- Table of contents -------------------------------------------------
  if toc {
    set page(header: context {
      grid(
        columns: (1fr, 1fr),
        align: (left + horizon, right + horizon),
        [],
        text(font: sansfont, size: 8.5pt, fill: muted)[
          Acme Industries · Annual Report 2026
        ],
      )
      v(2mm)
      line(length: 100%, stroke: 0.4pt + rule)
    })
    block(below: 8mm)[
      #set text(font: sansfont, size: 22pt, fill: primary, weight: 800)
      Contents
    ]
    line(length: 100%, stroke: 1.2pt + accent)
    v(4mm)
    show outline.entry: it => {
      let target = it.element.location()
      block(below: 2.4mm, above: 2.4mm, width: 100%)[
        #set text(font: sansfont, size: 11pt, fill: ink)
        #grid(
          columns: (1fr, auto),
          link(target, it.body()),
          link(target, text(fill: primary, weight: 700)[#it.page()]),
        )
        #v(1mm)
        #line(length: 100%, stroke: (paint: rule, thickness: 0.3pt, dash: "dotted"))
      ]
    }
    outline(title: none, depth: 1, indent: 0pt)
    pagebreak(weak: true)
  }

  // -- Body --------------------------------------------------------------
  doc
}
