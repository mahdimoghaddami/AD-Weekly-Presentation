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
  config-page(width: 960pt, height: 540pt, margin: (bottom: slide-margin, rest: slide-margin), fill: cream),
)

#show: apply-theme.with(text-size: 14pt, math-size: 19pt)

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

    #figure(image("assets/lg-cs-meantop3-BCA.png"), caption: "Mean BCA for top 3 models in each category", gap: 1em)
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
      #figure(image("assets/fmri-example.png"), caption: "Example fMRI volume", gap: 1em)
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
      1. *Convert the data into a standard format:*
        - DICOM (.dcm) -> NIfTI (.nii)

      2. *Motion correction:*
        - During a several-minute fMRI scan, the subject inevitably moves a little.
        - fMRIPrep estimates how each volume moved relative to a reference volume.
        - It then realigns the volumes.

      3. *Slice-timing correction:*
        - An fMRI volume isn't actually acquired all at once.
        - The scanner acquires different slices at slightly different times.
        - Slice-timing correction estimates what the signal would have been at the appropriate timing.
    ],
    [
      4. *Susceptibility distortion correction:*
        - Magnetic fields get warped near air-filled spaces in the skull (like the sinuses).
        - This step calculates that magnetic warping and "un-squishes" the image back to its true anatomical shape.

      5. *Coregistration:*
        - fMRI images are low-resolution and blurry.
        - To know exactly where the brain activity is happening, fMRIPrep aligns the functional image with the subject's anatomical image (T1w MRI).

      6. *Spatial normalization:*
        - Every person's brain is a slightly different size and shape.
        - fMRIPrep estimates a nonlinear transformation that maps the individual's anatomy to a standard brain template (usually called MNI space).
    ],
  )
]

#slide[
  #slide-title("Generating Brain Functional Connectivity Network using NiLearn")
  #v(slide-margin)
  #grid(
    columns: (50%, auto),
    gutter: slide-margin,
    [
      1. *Parcellation (applying an atlas):*
        - Instead of analyzing 100,000 tiny individual voxels, Nilearn uses a brain "atlas" to group those voxels into larger, meaningful ROIs (e.g., the hippocampus, the amygdala, the motor cortex).
        - $R = \{R_1, R_2, dots, R_N\}$: set of ROIs defined by the atlas

      2. *Extracting time series from each ROI (4D -> $|R| times T$):*
        - Each voxel in an ROI has its own BOLD time series. We summarize these voxel signals, typically by taking the mean signal across voxels in the region.
        - $R_1 = [x_1, x_2, dots, x_T]$ where $T$ is the number of time points.
        - We do this for every region.
    ],
    [
      3. *Correlation matrix ($|R| times T -> |R| times |R|$):*
        - "How similarly does Region $i$'s activity fluctuate with Region $j$'s activity?"

        - Suppose:
          - $R_i = [0.2, 0.4, 0.1, -0.2, dots]$
          - $R_j = [0.3, 0.5, 0.2, -0.1, dots]$

        - We calculate the Pearson correlation:

          $r_(i j) &= "corr"(R_i, R_j)\
          &= (sum(R_i - mu_i)(R_j - mu_j))/(sqrt(sum(R_i - mu_i)^2) sqrt(sum(R_j - mu_j)^2))$

        - $-1<=r_(i j)<=1$ for all $i, j in \{1, dots, N\}$
    ],
  )
]

#split-slide(
  40%,
  [
    #slide-title("FC Matrix", color: cream)
    #align(horizon + center)[
      #set math.mat(delim: "[")
      #show math.equation: set text(size: 1.56em)
      $F C=mat(
        r_11, r_12, ..., r_(1N);
        r_21, r_22, ..., r_(2N);
        dots.v, dots.v, dots.down, dots.v;
        r_(N 1), r_(N 2), ..., r_(N N);
      )$]
  ],
  [
    - An example functional connectivity (FC) matrix using the AAL atlas (number of regions: 116):

    #align(horizon)[
      #figure(image("assets/fc-example.png"), caption: "Example FC matrix", gap: 1em)
    ]
  ],
)

#slide[
  #slide-title("The Dataset")
  #v(slide-margin)
  - *Stable sequence:* Last visit diagnosis same as previous

  - *Converter sequence:* Last visit diagnosis different from previous (CN -> MCI or MCI -> AD)

  #align(horizon)[
    #grid(
      columns: (1fr, 1fr),
      gutter: slide-margin,
      [
        #figure(image("assets/data_classes.png"), caption: "Stable/converter subject distribution", gap: 1em)
      ],
      [
        #figure(
          image("assets/data_dist.png"),
          caption: "Another view of stable/converter subject distribution",
          gap: 1em,
        )
      ],
    )]
]

#slide[
  #slide-title("The Model")

  #align(horizon)[
    #figure(
      image("assets/model_1row_block.png"),
      caption: "Model architecture",
      gap: 1em,
    )
  ]
]

#slide[
  #grid(
    columns: (auto, 1fr),
    gutter: slide-margin,
    [#slide-title("Input")], [#align(right)[#image("assets/model_1row_block.png", height: 30%)]],
  )

  #v(slide-margin)

  #grid(
    columns: (50%, auto),
    gutter: slide-margin,
    [
      hello
    ],
    [
      hello
    ],
  )
]

#slide[
  #grid(
    columns: (auto, 1fr),
    gutter: slide-margin,
    [#slide-title("GraphSAGE", venue: "[NeurIPS 2017]")],
    [#align(right)[#image("assets/model_1row_block.png", height: 30%)]],
  )

  #v(slide-margin)

  #grid(
    columns: (50%, auto),
    gutter: slide-margin,
    [
      hello
    ],
    [
      hello
    ],
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
  #grid(
    columns: (auto, 1fr),
    gutter: slide-margin,
    [#slide-title("GraphNorm", venue: "[ICML 2021]")],
    [#align(right)[#image("assets/model_1row_block.png", height: 30%)]],
  )

  #v(slide-margin)

  #grid(
    columns: (50%, auto),
    gutter: slide-margin,
    [
      hello
    ],
    [
      hello
    ],
  )
]

#slide[
  #grid(
    columns: (auto, 1fr),
    gutter: slide-margin,
    [#slide-title("Dropout", venue: "[JMLR 2014]")],
    [#align(right)[#image("assets/model_1row_block.png", height: 30%)]],
  )

  #v(slide-margin)

  #grid(
    columns: (50%, auto),
    gutter: slide-margin,
    [
      hello
    ],
    [
      hello
    ],
  )
]

#slide[
  #grid(
    columns: (auto, 1fr),
    gutter: slide-margin,
    [#slide-title("TopK Pooling", venue: "[RRL@NeurIPS 2018]")],
    [#align(right)[#image("assets/model_1row_block.png", height: 30%)]],
  )

  #v(slide-margin)

  #grid(
    columns: (50%, auto),
    gutter: slide-margin,
    [
      hello
    ],
    [
      hello
    ],
  )
]

#slide[
  #grid(
    columns: (auto, 1fr),
    gutter: slide-margin,
    [#slide-title("Mean and Max Pooling")], [#align(right)[#image("assets/model_1row_block.png", height: 30%)]],
  )

  #v(slide-margin)

  #grid(
    columns: (50%, auto),
    gutter: slide-margin,
    [
      hello
    ],
    [
      hello
    ],
  )
]


#slide[
  #slide-title("Pretraining")
  #v(slide-margin)
  - Using 20% of the data
]

#slide[
  #slide-title("Challenges")
  #v(slide-margin)
  - hello
]

#section-slide("Thank you!")
