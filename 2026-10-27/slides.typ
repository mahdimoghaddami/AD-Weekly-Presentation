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


#slide[

  #slide-title("Weekly Report")
  #v(slide-margin)

  #grid(
    columns: (1fr, 1fr),
    gutter: slide-margin,
    [
      - ADNI only has fMRI starting from ADNI-GO (2009). No ADNI1 (started 2004-09).
      - A Pipeline for ADNI Resting-State Functional MRI Processing and Quality Control:
        - This paper suggests a pipeline of cleaning/preprocessing ADNI fMRI.
        - ADNI rs-fMRI as of 2025, just 5.9% of all ADNI publications!
        - In 2025 alone, only 48 of 752 ADNI papers (6.4%) used rs-fMRI.
        - The pipeline currently supports the ADNI GO, ADNI 2, and ADNI 3 datasets.
    ],
    [
      - All fmri data from ADNI: *9789 records*
      - We need to discard a lot of it:
        - Arterial Spin Labeling (ASL) images: 4479 records
        - MoCoSeries:
          - On Siemens scanners, the console automatically outputs both the raw scan and a MoCoSeries (Motion-Corrected Series).
          - `relCBF` (1,919)
          - `Perfusion_Weighted` (1,911)
          - Every string containing `pCASL` or `PASL` (649 total across 21 `WIP SOURCE - Axial 3D pCASL...`, `SOURCE - Axial 3D pCASL...`, and `Axial 2D/3D PASL...` descriptions)
        - Diffusion Tensor Imaging / White Matter: 15 records
          - `Axial MB DTI`, `Axial MB DTI_FA`, `Axial MB DTI_ADC`, `Axial MB DTI_TENSOR_B0`, `Axial MB DTI_TRACEW` (3 each = 15)

    ],
  )
]


#section-slide("Thank you!")
