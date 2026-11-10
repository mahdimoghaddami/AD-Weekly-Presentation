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
    [#text(font: "Libertinus Serif", size: 85pt)[Matilda\ HPC\ Cluster]],
    [#image("assets/cover.png", width: 100%, height: 250pt, fit: "contain")],
  )]
  #v(20pt)
  #align(bottom)[Mahdi Moghaddami]
  #v(-8pt)
  #line(length: 100%, stroke: 0.6pt + cream)
]

#section-slide("Missing Slice Timing")

#split-slide(
  35%,
  [#slide-title([Solution 1], color: cream)
    #align(bottom)[
      - #text(weight: "bold")[Philips (`1,277 / 1,277` missing):] Standard Philips DICOM headers do not store per-slice acquisition timestamps. Rather than guessing the slice acquisition order, `dcm2niix` intentionally omits `SliceTiming` for Philips scans.

      - #text(weight: "bold")[Siemens (`1 / 1,219` missing):] Only a single Siemens scan (`sub-114S6039` / `ses-20170721` / `I879211`, is missing `SliceTiming`.
    ]
  ],
  [
    - *Philips (`1,277 / 1,277` = `100.00%` missing):* Standard Philips DICOM headers do not store per-slice acquisition timestamps. Rather than guessing the slice acquisition order, `dcm2niix` intentionally omits `SliceTiming` for Philips scans.

    - *Siemens (`1 / 1,219` = `0.08%` missing):* Only a single Siemens scan (`sub-114S6039` / `ses-20170721` / `I879211`, Siemens Verio `syngo MR B19`) is missing `SliceTiming`.

    - Fixed *`1,154` out of `1,278` (`90.30%`)*:
      - In `MAYOADIRL_MRI_FMRI_NFQ_29Oct2026.csv`, each entry in `SLICETIMING` is stored as:
      $ t_z^("NFQ") = t_("series_start") + t_z^("rel"), quad z = 0, 1, dots, N - 1 " (inferior to superior)" $

      - Since all our BIDS NIfTI volumes converted by `dcm2niix` have positive $Z$-spacing (`srow_z[2] > 0`, i.e., slice `0` is inferior and slice `N-1` is superior), subtracting the minimum timestamp yields the exact BIDS `SliceTiming` vector:
      $ "SliceTiming"[z] = t_z^("NFQ") - min_(0 <= j < N) t_j^("NFQ") $
  ],
)

#split-slide(
  35%,
  [#slide-title([Solution 2], color: cream)
    #align(bottom)[
      - To confirm our formula is correct, I computed the `SliceTiming` vector for Philips scans that were not missing it, and compared it to the `SliceTiming` vector in the BIDS JSON sidecar. The two vectors were identical for all Philips scans that had `SliceTiming` available.
    ]
  ],
  [
    - Fixed *`124` out of `1,278` (`9.70%`)*:
      - Page 8 of the *ADNI3 MRI Analysis Manual* specifies `2X accelerated (even/odd interleave)` axial EPI-BOLD acquisition.

      - $N$ = number of axial slices in the NIfTI volume (`dim[3]`),
      - $"TR"$ = repetition time (in seconds),
      - $"MB"$ = multiband acceleration factor
        (`ParallelReductionFactorOutOfPlane` in the BIDS JSON sidecar):
        - $"MB" = 1$ for single-band `fcMRI`/`rsfMRI`,
        - $"MB" = 3$ for `ADNI4` `Axial MB rsfMRI (EYES OPEN) (MSV22)`,
          with $N = 51$,
      - $M = N / "MB"$ = number of RF excitations (shots) per $"TR"$,
      - $Delta t = "TR" / M$ = time between consecutive excitations.

      Within each band of $M$ slices ($s in {0, 1, dots.c, M - 1}$), Philips acquires all *even 0-based indices first* ($s = 0, 2, 4, dots.c$, which is $ceil(M / 2)$ excitations: 1-based odd slices $1, 3, 5, dots.c$), followed by all *odd 0-based indices* ($s = 1, 3, 5, dots.c$, which is $floor(M / 2)$ excitations: 1-based even slices $2, 4, 6, dots.c$):

      $
        t_"shot"(s) = cases(
          (s / 2) Delta t "if " s " is even",
          (ceil(M / 2) + (s - 1) / 2) Delta t "if " s " is odd"
        )
      $

      And across the $N$ slices
      ($z = 0, 1, dots.c, N - 1$):

      $ "SliceTiming"[z] = t_"shot"(z mod M) $

  ],
)

#section-slide("Broken Scans")

#split-slide(
  35%,
  [
    #slide-title("Missing Slices", color: cream)
    #align(bottom)[
      - 35 failed fMRI scans (`9` GE + `26` Philips):
        - Failed `dcm2niix` with return code `1` due to either an erroneous per-slice GE private tag `(0019,10A2)` (`Raw data run number`), isolated single-slice PACS transfer dropouts, or truncated series uploads.

      - I salvaged 24/35 scans.
    ]
  ],
  [
    1. `GE Private Tag (0019,10A2) Bug` (5 scans, Salvageable $arrow.r$ 200 vols):
      - Site `007` GE Signa HDxt scans (`I680900`, `I638776`, `I631785`, `I695057`, `I680924`) have **all 9,600 files (`48 slices × 200 volumes = 100.0%`), but GE private tag `(0019,10A2)` was incremented per slice (`48` unique values instead of `1`), confusing `dcm2niix`'s volume indexer.

    2. Full-Brain (48 Slices) with 1-9 Isolated Single-Slice Dropouts (13 scans: 11 Philips + 2 GE, Salvageable $arrow.r$ 197-200 vols):
      - Temporal linear interpolation of the `1–9` missing single slices from immediate neighbors `(t-1, t+1)`.

    3. Full-Brain (48 Slices) Truncated at End (4 scans: 2 GE + 2 Philips, Salvageable $arrow.r$ 98-167 vols):
      - Staging only the contiguous complete volumes `[Best_Start...Best_End]` recovers clean 48-slice 4D volumes with zero interpolation.

    4. Near-Complete Axial Slab (2 Philips scans, Salvageable $arrow.r$ 132-200 vols):
      - Philips exports 2D-slice fMRI in *slice-major order* (all timepoints of slice 1, then slice 2, etc.).

    - The remaining 11 scans were unrecoverable:
      - `10` Philips scans were truncated in slice-major order with only `1` to `41` axial slices present (`1.9%–85.4%` of files, missing `23 mm` to `155 mm` of brain tissue) or massive random dropouts (`I659915`, only 2 contiguous volumes), and `1` scan (`006_S_6500 I1028502`) is missing two internal slices inside the cortex (`Z = 70.40 mm` to `80.57 mm`, a `10.17 mm` internal spatial gap).
  ],
)

#split-slide(
  35%,
  [
    #slide-title("Temporal Interpolation", color: cream)
    #align(bottom)[
      - What is temporal interpolation in our context?

      - Why temporal interpolation instead of spatial interpolation?
    ]
  ],
  [
    - In rs-fMRI, adjacent axial slices ($z-1$ and $z+1$) are $3.3 "mm"$ apart and pass through different anatomical structures (e.g., gray matter vs. CSF/ventricle), so averaging spatially blurs anatomy.

    - By contrast, the *exact same slice location $z$* at volume $t-1$ ($3 "s"$ earlier) and volume $t+1$ ($3 "s"$ later) images the *exact same brain tissue*, and the BOLD hemodynamic response varies slowly over a $~6-10 "s"$ timescale (`< 0.1 Hz`).

    1. *Locate the Missing `(z, t)` Slot:*
      - Every DICOM file in the series is mapped by its axial coordinate `z = round("ImagePositionPatient"[2], 2)` (48 unique positions) and its volume index $t = "TemporalPositionIdentifier" (1 dots.c N)$.
      - If slot `(z, t)` is missing, we find the closest existing volume before it
        ($t_"prev"$, usually $t - 1$) and after it
        ($t_"next"$, usually $t + 1$) *at that exact same slice coordinate $z$*.

    2. *Compute the missing slice (2D Matrix):*
      $
        I(x, y, z, t) =
        floor(
          frac(
            I(x, y, z, t_"prev") +
            I(x, y, z, t_"next"),
            2
          )
        )
      $
  ],
)

#section-slide("Quality Control")

#split-slide(
  40%,
  [
    #slide-title("Heuristics to Discard Scans", color: cream)
    #align(bottom)[
      - Some scans are corrupted or aborted due to scanning errors.

      - Running fMRIPrep on these scans will result in errors and wasted time.

      - I used heuristics to discard these scans.
    ]
  ],
  [
    1. Ultra-Slow / Misconfigured Repetition Time (`TR >= 5.0 s`)
      - `28` Philips scans (`27` in `ADNIGO/ADNI2`, `1` in `ADNI3`) were acquired with `TR ≈ 6.02 s` (`6.015 s` to `6.024 s`), twice the standard `3.0 s` ADNI single-band protocol.

    2. Severe Partial-Brain Coverage:
      - `14` Philips scans
        - $36 "slices" times 3.3125 "mm" = 119.25 "mm depth"$, TR = 2.0 s
      - `1` Siemens scan (`sub-023S4502/ses-20140423`):
        - $36 " slices" times 3.50 " mm" = 126.00 " mm"$ depth, $"TR" = 2.00 " s"$, series description `epi_2s_resting_state`.

    3. Aborted / Severely Truncated Acquisitions:
      - 4 Siemens ADNI3 sessions terminated prematurely mid-scan:
        - `sub-007S4272/ses-20230117` (`I1663969`):
          $9 "volumes" times 0.607 "s" = 5.46 "s"$  (expected `976` volumes)
        - `sub-116S6100/ses-20200129` (`I1281553`):
          $46 "volumes" times 3.00 "s" = 138.0 "s"$
          ($2.30 "min"$; expected `197` volumes)
        - `sub-020S6901/ses-20220314` (`I1557905`):
          $66 "volumes" times 3.00 "s" = 198.0 "s"$
          ($3.30 " min"$; expected `197` volumes)
        - `sub-082S6629/ses-20200205` (`I1516241`):
          $72 "volumes" times 3.00 "s" = 216.0 "s"$
          ($3.60 "min"$; expected `197` volumes)

      4. Non-Standard Body Receive Coil:
        - `sub-098S4003/ses-20200220` (`I1293825`, GE): `CoilString = "BODY"`
        - `sub-131S5148/ses-20130418` (`I367728`, Philips): `CoilString = "Q-Body"`
  ],
)


#section-slide("Running fMRIPrep")


#split-slide(
  40%,
  [#slide-title([Personal Computer], color: cream)
    #align(bottom)[
      - Running fMRIPrep on my PC was slow and inefficient due to limited resources.
    ]
  ],
  [
    - It takes 5 to 6 hours per session.
    - We have 3218 sessions, 1322 subjects.
    - Total preprocessing time on my PC would be unreasonably long, I looked for alternatives to speed up the process.

    - Preprocessing time:
      - PC: 235 days
      - Google Cloud: ~\$903
      - HPC Cluster: ~4.7 days

    - HPC looks like the best option.
  ],
)

#split-slide(
  40%,
  [#slide-title([Matilda HPC Cluster], color: cream)
    #align(bottom)[
      - A Linux-based cluster for workloads that do not fit on an individual computer.

      - More than 2,000 CPU cores across standard, high-throughput, big-memory, hybrid, and GPU nodes.

      - All nodes are connected by 100 Gbps HDR100 InfiniBand.

      - Buy-in nodes are funded by a specific department or research group. We can use them only if our PI or group has access.
    ]
  ],
  [
    - *Standard compute:* 40 nodes; 40 CPU cores and 192 GB RAM per node.

    - *High throughput:* 10 nodes; 8 CPU cores and 192 GB RAM per node.

    - *Big memory:* 4 nodes; 40 CPU cores and 768 GB RAM per node.

    - *GPU:* 3 nodes; 4 NVIDIA Tesla V100 16 GB GPUs, 48 CPU cores, and 192 GB RAM per node.

    - *Specialized buy-in nodes:*
      - Chemistry: 1 node with 1.5 TB RAM.
      - SECS: 2 nodes with NVIDIA RTX Pro 6000 Blackwell GPUs and 512 GB RAM.
      - Availability depends on PI or research-group allocation; they are not automatically available to every user.
  ],
)

#split-slide(
  40%,
  [#slide-title([Storage and File Structure], color: cream)
    #align(bottom)[
      - #text(weight: "bold")[Home:] personal files and configuration.

      - #text(weight: "bold")[Projects:] shared research data and collaboration.

      - #text(weight: "bold")[Scratch:] fast temporary working space for jobs.

      - Home and project storage is backed up; scratch is not.
    ]
  ],
  [
    - `/home/m/moghaddami:` #h(1fr) 50 GB; backed up and replicated

    - `/projects/adresearch:` #h(1fr) 1 TB; permanent; shared with lab members

    - `/scratch/users/moghaddami:` #h(1fr) 10 TB; 100 Gbps InfiniBand

    - `/scratch/projects/adresearch:` #h(1fr) 10 TB; shared with group

    - Scratch files are automatically deleted after 45 days if not modified.
  ],
)

#split-slide(
  40%,
  [#slide-title([File Transfer], color: cream)
    #align(bottom)[
      - There are multiple ways to transfer files to and from the cluster, including:

        - #text(weight: "bold")[SCP:] secure copy over SSH.

        - #text(weight: "bold")[SFTP:] secure file transfer protocol.

        - #text(weight: "bold")[rsync:] fast incremental file transfer.

        - #text(weight: "bold")[Globus:] high-performance data transfer service.
    ]
  ],
  [
    - Cloned `gnn-connectivity-matrix` repository from GitHub to `/home/m/moghaddami`.

    - To transfer the 321GB of data, other methods were not feasible:
      - SCP and SFTP are slow for large datasets.
      - SCP does not have a resume feature, so if the transfer is interrupted, it has to start over.
      - `rsync` is not available on Windows.
    - Globus is recommended by the Matilda HPC documentation. It is fast and reliable, especially for large datasets.

    - The transfer was not rudimentary at all:
      - I had to set up a Globus endpoint on my PC
      - Configure transfer settings: increase path size for Windows, give access to the `D` drive
      - Initiate the transfer through the Globus web interface.
      - Total time: ~3 hours for 321GB of data
      - Average transfer speed: ~30 MB/s

  ],
)





#section-slide("Thank you!")
