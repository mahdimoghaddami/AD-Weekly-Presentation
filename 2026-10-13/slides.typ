// Three-slide sample based on source PDF pages 1, 14, and 12.
#import "@preview/touying:0.8.0": config-page, slide, themes
#import themes.simple: simple-theme, slide
#import "theme.typ": *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  primary: ink,
  header: none,
  header-right: none,
  footer: none,
  footer-right: context [#text(
    size: page-number-size,
    fill: page-number-fill,
  )[#counter(page).display() / #counter(page).final().first()]],
  subslide-preamble: none,
  config-page(width: 960pt, height: 540pt, margin: slide-margin, fill: cream),
)

#show: apply-theme.with(text-size: 14pt, math-size: 20pt)

#slide(config: config-page(fill: olive, footer: none))[
  #set text(fill: cream)
  #set par(leading: 0.4em)
  #align(right)[#text(10pt)[#datetime.today().display("[month repr:long] [day], [year]")]]
  #align(horizon)[#grid(
    columns: (1fr, 1fr),
    [#text(font: "Libertinus Serif", size: 85pt)[Alzheimer's\ Disease\ Research]],
    [#image("assets/cover.png", width: 100%, height: 250pt, fit: "contain")],
  )]
  #v(20pt)
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

#section-slide("Projects Overview")

#split-slide(
  40%,
  [#slide-title([Longitudinal\ vs.\ Cross-Sectional], color: cream)
    #align(bottom)[
      - Longitudinal Models:
        - RNN
        - LSTM
        - GRU
        - MinimalRNN

      - Cross-Sectional Models:
        - Random Forest
        - Support Vector Machine
        - Logistic Regression
    ]
  ],
  [
    - This study compares two categories of modeling: longitudinal and cross-sectional. We predict the clinical diagnosis of cognitive impairment in Alzheimer's disease (CN, MCI, or AD).

    - hola!
  ],
)

#split-slide(
  40%,
  [#slide-title([Review Article], color: cream)
    #align(bottom)[
      - Two major questions:
        1. How is longitudinal data used for AD?
        2. How should we write articles when there is an abundance of papers?
          - ASReview
          - Elicit
          - Covidence
          - DistillerSR
          - Nested-Knowledge
    ]
  ],
  [
    - 2020-2026 papers

    - Four Sources:
      1. ACM Digital Library
      2. IEEEXplore
      3. Scopus
      4. PubMed

    - We filter papers based on the existence of certain keywords in the title and abstract

    - We find relevant papers.

    - We need further ranking of paper. We add different metric for papers:
      - Journal papers:
        - Journal Impact Factor (JIF)
        - CiteScore
        - SCImage Journal Rank (SJR)
        - Source Normalized Impact per Paper (SNIP)
      - Conference papers:
        - Core Ranking (A, A, B, C)
        - CCF Ranking (A, B, C)
      - Both:
        - Google Scholar h5-index
  ],
)

#split-slide(
  40%,
  [#slide-title([Longitudinal\ vs.\ Cross-Sectional], color: cream)
    #align(bottom)[
      - The question:
        - Will a subject progress to a further stage of AD (CN -> MCI or MCI -> AD) in the next visit?

      - Binary Stable/Converter prediction.
    ]
  ],
  [
    - 337 subjects

    - The data:
      - DTI
      - Structured clinical and biomarker data (TADPOLE)

    - Brett will talk more about this project!
  ],
)

#section-slide("AD Progression Prediction using fMRI")

#slide[
  #slide-title("What is fMRI?")
  #v(slide-margin)
  #grid(
    columns: (30%, auto),
    gutter: slide-margin,
    [
      - Functional Magnetic Resonance Imaging is a type of brain scan that shows both the structure of the brain and, more importantly, *which areas are active during specific tasks or at rest*.

      - It's acquired by tracking blood flow changes. When a brain area is more active, it uses more oxygen, and fMRI can detect that via something called the *BOLD signal* (Blood Oxygen Level Dependent signal).

      - Each voxel contains a BOLD signal that changes over time.

      - It's basically *a number of 3D images*.
    ],
    [
      #figure(image("assets/data_classes.png"), caption: "Example fMRI volume", gap: 1em)
    ],
  )
]

#slide[
  #slide-title("Preprocessing Steps using fMRIPrep")
  #v(slide-margin)
  #grid(
    columns: (50%, auto),
    gutter: slide-margin,
    [
      1. Convert the data into a standard format:
        - DICOM (.dcm) -> NIfTI (.nii)
    ],
    [hello],
  )
]

#slide[
  #slide-title("GraphSAGE", venue: "[NeurIPS 2017]")
  // #text(16pt, fill: olive, font: "Libertinus Serif")[[NeurIPS 2017]]
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

  - hello
    - dawdh
  - dawdj
]
