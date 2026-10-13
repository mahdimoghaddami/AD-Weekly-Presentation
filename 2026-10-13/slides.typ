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

#show: apply-theme.with()

#slide(config: config-page(fill: olive, footer: none))[
  #set text(fill: cream)
  #set par(leading: 0.4em)
  #align(right)[#text(page-number-size)[#datetime.today().display("[month repr:long] [day], [year]")]]
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

    #align(horizon)[
      #figure(
        grid(
          columns: (1fr, 1fr),
          align: bottom,
          gutter: 1em,
          [
            #image("assets/lg-cs-bca-mean.png", width: 100%, height: 200pt, fit: "contain")
          ],
          [
            #image("assets/lg-cs-data-dist.png", width: 100%)
          ],
        ),
        caption: "a) Mean BCA for top 3 models in each category, b) Data distribution based on the number of visits.",
        gap: 1em,
      )]
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
        - Core Ranking (A\*, A, B, C)
        - CCF Ranking (A, B, C)
      - Both:
        - Google Scholar h5-index
  ],
)

#split-slide(
  40%,
  [#slide-title([AD Progression Prediction using DTI], color: cream)
    #align(bottom)[
      - The question:
        - Will a subject progress to a further stage of AD (CN #sym.arrow.r MCI or MCI #sym.arrow.r AD) in the next visit?

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
    columns: (1fr, auto),
    gutter: slide-margin,
    [
      - Functional Magnetic Resonance Imaging is a type of brain scan that shows both the structure of the brain and, more importantly, *which areas are active during specific tasks or at rest*.

      - It's acquired by tracking blood flow changes. When a brain area is more active, it uses more oxygen, and fMRI can detect that via something called the *BOLD signal* (Blood Oxygen Level Dependent signal).

      - Each voxel contains a BOLD signal that changes over time.

      - It's basically *a number of 3D images*.
    ],
    [
      #align(right)[
        #figure(
          image("assets/fmri-example.png", height: 70%),
          caption: "Example fMRI volume",
          gap: 1em,
        )
      ]
    ],
  )
]

#slide[
  #slide-title("Preprocessing Steps using fMRIPrep", venue: "[Nature Methods 2019]")
  #v(slide-margin)
  #grid(
    columns: (1fr, 1fr),
    gutter: slide-margin,
    [
      1. *Convert the data into a standard format:*
        - DICOM (`.dcm`) #sym.arrow.r NIfTI (`.nii`)

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
    columns: (1fr, 1fr),
    gutter: slide-margin,
    [
      1. *Parcellation (applying an atlas):*
        - Instead of analyzing 100,000 tiny individual voxels, Nilearn uses a brain "atlas" to group those voxels into larger, meaningful regions of interest (ROIs) (e.g., the hippocampus, the amygdala, the motor cortex).
        $ R = \{R_1, R_2, dots, R_N\}, $ set of ROIs defined by the atlas

      2. *Extracting time series from each ROI (4D -> $|R| times T$):*
        - Each voxel in an ROI has its own BOLD time series. We summarize these voxel signals, typically by taking the mean signal across voxels in the region.
        $ R_1 = [x_1, x_2, dots, x_T], $ where $T$ is the number of time points.

        - We do this for every region.
    ],
    [
      3. *Correlation matrix ($|R| times T -> |R| times |R|$):*
        - "How similarly does Region $i$'s activity fluctuate with Region $j$'s activity?"

        - Suppose:
          $ R_i = [0.2, 0.4, 0.1, -0.2, dots] $
          $ R_j = [0.3, 0.5, 0.2, -0.1, dots] $

        - We calculate the Pearson correlation:

          $
            r_(i j) & = "corr"(R_i, R_j) & = (sum(R_i - mu_i)(R_j - mu_j))/(sqrt(sum(R_i - mu_i)^2) sqrt(sum(R_j - mu_j)^2))
          $

        - $-1<=r_(i j)<=1$ for all $i, j in \{1, dots, N\}$
    ],
  )
]

#split-slide(
  50%,
  [
    #slide-title("FC Matrix", color: cream)
    #align(horizon + center)[
      #set math.mat(delim: "[")
      #show math.equation: set text(size: 2.05em)
      $F C=mat(
        r_11, r_12, ..., r_(1N);
        r_21, r_22, ..., r_(2N);
        dots.v, dots.v, dots.down, dots.v;
        r_(N 1), r_(N 2), ..., r_(N N);
      )$
    ]
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

  - *Converter sequence:* Last visit diagnosis different from previous (CN #sym.arrow.r MCI or MCI #sym.arrow.r AD)

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
    columns: (1fr, 1fr),
    gutter: slide-margin,
    [
      - The original 2D functional connectivity matrix is $N times N$, where $N$ is the number of ROIs.

      - For the GNN input, that matrix is converted into a graph $G$:
        - Nodes: $V$ = ROIs
        - Edges: $E$ = functional connections between ROIs
          - An edge exists only if the correlation between two nodes is $>=$ _threshold_. We set _threshold_=0.2.
        - Node features: $X$ = connectivity profile of each ROI (its row of the FC matrix)
    ],
    [
      - The key difference is:
        - The 2D matrix is a dense table of pairwise correlations.
        - The GNN input is a graph object built from that matrix letting graph convolutions aggregate information over neighboring ROIs.

      - The model input is multiple graphs for one subject, arranged as a visit sequence.
        - $[G_1, G_2, dots, G_m],$ where $m$ is the number of visits.
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
    columns: (1fr, 1fr),
    gutter: slide-margin,
    [
      - For every node $i$:

        $ x_i = ["corr"(i, R_1), "corr"(i, R_2), dots, "corr"(i, R_N)] $

        - We aggregate neighbor features:

          $ m_i = 1 / abs(cal(N)(i)) sum_(j in cal(N)(i)) x_j $

        - Combine node features with neighbor features:

          $ h_i = sigma(x_i W_"self"^T + m_i W_"neigh"^T + b) $
    ],
    [
      - $h_i in RR^(1 times d)$: updated node embedding for node $i$

      - $sigma$: activation function

      - $W_"self" in RR^(d times N)$: learned weight matrix for the node's own features

      - $W_"neigh" in RR^(d times N)$: learned weight matrix for the aggregated neighbor features

      - $b in RR^(1 times d)$: learned bias

      - We do this for all $N$ nodes.
        - Input: $X = [x_1, x_2, dots, x_N] in RR^(N times N)$

        - Output: $H = [h_1, h_2, dots, h_N] in RR^(N times d)$
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
    columns: (1fr, 1fr),
    gutter: slide-margin,
    [
      - Input: $H = [h_1, h_2, dots, h_N] in RR^(N times d)$

      - GraphNorm normalizes the node embeddings within that one graph. In simple terms, it asks:
        - Are some node features unusually large or small compared with the rest of the graph?

      - Then it rescales them, so the graph is easier for the next layers to process.

      - Each node is normalized:
        $ hat(h)_i = (h_i - mu) / (sigma + epsilon) $

        - $epsilon$ is a small constant to prevent division by zero.
    ],
    [
      $ mu = 1 / N sum_(i=1)^N h_i in RR^d $

      $ sigma = sqrt(1 / N sum_(i=1)^N (h_i - mu)^2) in RR^d $

      - GraphNorm also learns a small rescaling and shifting for each feature:
        $ h'_i = gamma dot.o hat(h)_i + beta $

        - $gamma, beta in RR^(1 times d)$: learned parameters
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
    columns: (1fr, 1fr),
    gutter: slide-margin,
    [
      - Input: $H' = [h'_1, h'_2, dots, h'_N] in RR^(N times d)$

      - Dropout is regularization technique to prevent overfitting.

      - During training, a random subset of neurons is deactivated.

      - For each node $i$ and feature $k$, we have a mask:
        $ m_(i,k) ~ "Bernoulli"(1-p), $
        where $p$ is the dropout probability.

        $ h''_(i,k) = (m_(i,k) dot h'_(i,k)) / (1-p) $
    ],
    [
      - Therefore:
        $ H'' = (H' dot.o M) / (1-p) $

      - Output:
        $ H'' = [h''_1, h''_2, dots, h''_N] in RR^(N times d) $
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
    columns: (1fr, 1fr),
    gutter: slide-margin,
    [
      - Input: $H'' = [h''_1, h''_2, dots, h''_N] in RR^(N times d)$

      - TopK pooling keeps only the "most important" nodes and removes the rest.

      - The model learns a score for each node. Top $K$ highest-scoring nodes are kept; the rest are discarded.

      - First, TopK pooling learns a projection vector $p in RR^d$:
        $ s_i = (h''_i^T p) / (||p||) in RR $

      - Nodes are ranked based on their scores, and the top $K$ nodes are selected.
    ],
    [
      - The model keeps only the top $K$ nodes:
        $ K=[r N], $
        where $r$ is the pooling ratio (we use $r=0.3$).

      - For the kept nodes, TopK pooling also gates their embeddings using the score:
        $ h^("pool")_i = h_i dot tanh(s_i) in RR^d $

      - Output:
        $ H^("pool") = [h^("pool")_1, h^("pool")_2, dots, h^("pool")_K] in RR^(K times d) $
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
    columns: (1fr, 1fr),
    gutter: slide-margin,
    [
      - Input:
      $ H^("pool") = [h^("pool")_1, h^("pool")_2, dots, h^("pool")_K] in RR^(K times d) $

      - Mean pooling averages the values across nodes:
        $ h^("mean") = 1/K sum_(i=1)^K h^("pool")_i in RR^(1 times d) $

      - Max pooling takes the maximum value across nodes, separately for each feature:
        $ h^("max") = max_(i=1)^K h^("pool")_i in RR^(1 times d) $
    ],
    [
      - We concatenate the mean and max pooled representations to form the final graph representation:
        $ g = [h^("mean"), h^("max")] in RR^(1 times 2d) $


      Example:

      #grid(
        align: (center, center),
        columns: (1fr, 1fr),
        gutter: slide-margin,
        [
          #set math.mat(delim: "[")
          $H^("pool")=mat(
            1, 4, 2, 0;
            3, 2, 5, 1;
            2, 6, 2, 2;
          ) ==>$
        ],
        [$h^("mean") = [2, 4, 3, 1],$

          $h^("max") = [3, 6, 5, 2]$],
      )

      $ g = [2, 4, 3, 1, 3, 6, 5, 2] $

    ],
  )
]

#slide[
  #slide-title("Pretraining")
  #v(slide-margin)
  - Using 20% of the data

    #align(horizon)[
      #figure(
        image("assets/pretraining.png"),
        caption: "Model architecture",
        gap: 1em,
      )
    ]
]

#slide[
  #slide-title("Challenges")
  #v(slide-margin)
  - Missing visits:
    - Some visits are missing fMRI but have data for other modalities (sMRI, cognitive scores, PET, etc.)
]

#section-slide("Thank you!")
