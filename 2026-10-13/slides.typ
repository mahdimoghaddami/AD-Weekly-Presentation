// Three-slide sample based on source PDF pages 1, 14, and 12.
#import "@preview/touying:0.8.0": *
#import themes.simple: simple-theme, slide
#import "theme.typ": *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  primary: olive,
  header: none,
  header-right: none,
  footer: none,
  footer-right: context [#counter(page).display() / #counter(page).final().first()],
  subslide-preamble: none,
  config-page(width: 960pt, height: 540pt, margin: 36pt, fill: cream),
)

#show: apply-theme


#slide(config: config-page(fill: olive, footer: none))[
  #set text(fill: cream)
  #set par(leading: 0.4em)
  #align(right)[#text(12pt)[#datetime.today().display("[month repr:long] [day], [year]")]]
  // #v(26pt)
  #align(horizon)[#grid(
    columns: (1fr, 1fr),
    [#text(font: "Libertinus Serif", size: 80pt)[Alzheimer's\ Disease\ Research]],
    [#image("assets/cover.png", width: 100%, height: 285pt, fit: "contain")],
  )]

  #align(bottom)[Mahdi Moghaddami]
  #v(-8pt)
  #line(length: 100%, stroke: 0.6pt + cream)
]

// #slide[
//   #outline(
//     depth: 2,
//     title: text("Contents", fill: olive, font: "Libertinus Serif"),
//     indent: 1em,
//   )
// ]

#slide[
  #slide-title[GraphSAGE]
  #text(16pt, fill: olive, font: "Libertinus Serif")[[NeurIPS 2017]]
  #v(10pt)
  #grid(
    columns: (1.65fr, 1fr),
    gutter: 40pt,
    [
      *Connectivity profile of ROI $i$*
      #text(24pt)[$ x_i = ["corr"(i, R_1), dots, "corr"(i, R_N)] $]
      #v(10pt)
      *Mean of neighboring node features*
      #text(25pt)[$ m_i = 1 / abs(cal(N)(i)) sum_(j in cal(N)(i)) x_j $]
      #v(10pt)
      *Updated node embedding*
      #text(25pt)[$ h_i = sigma(W_"self" x_i + W_"neigh" m_i + b) $]
    ],
    [
      #text(fill: olive, weight: "bold")[Notation]
      #v(10pt)
      #text(19pt)[
        $cal(N)(i)$: neighbors of ROI $i$\
        $W_"self", W_"neigh"$: learned weights\
        $b$: learned bias\
        $sigma$: activation function
      ]
      #v(12pt)
      #text(fill: olive, weight: "bold")[Layer output]
      #text(24pt)[$ H = mat(h_1^T; dots.v; h_N^T) in RR^(N times d) $]
      #text(18pt)[$N$ nodes, $d$ embedding features]
    ],
  )
]

#slide[
  #slide-title[The Model]
  #v(6pt)
  Functional connectivity graphs across a subject's visits
  #v(10pt)
  #image("assets/model_1row_block.png", width: 100%, height: 180pt, fit: "contain")
  #v(5pt)
]

#slide[
  #slide-title[Testing]

  // - hello
  //   - dawdh
  // - dawdj
  // #section-title("hello")
]

#section-slide("New Section")
