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

// #slide[

//   #slide-title("Weekly Report")
//   #v(slide-margin)

//   #grid(
//     columns: (1fr, 1fr),
//     gutter: slide-margin,
//     [
//       - ADNI only has fMRI starting from ADNI-GO (2009). No ADNI1 (started 2004-09).
//       - A Pipeline for ADNI Resting-State Functional MRI Processing and Quality Control:
//         - This paper suggests a pipeline of cleaning/preprocessing ADNI fMRI.
//         - ADNI rs-fMRI as of 2025, just 5.9% of all ADNI publications!
//         - In 2025 alone, only 48 of 752 ADNI papers (6.4%) used rs-fMRI.
//         - The pipeline currently supports the ADNI GO, ADNI 2, and ADNI 3 datasets.
//     ],
//     [
//       - All fmri data from ADNI: *9789 records*
//       - We need to discard a lot of it:
//         - Arterial Spin Labeling (ASL) images: 4479 records
//         - MoCoSeries:
//           - On Siemens scanners, the console automatically outputs both the raw scan and a MoCoSeries (Motion-Corrected Series).
//           - `relCBF` (1,919)
//           - `Perfusion_Weighted` (1,911)
//           - Every string containing `pCASL` or `PASL` (649 total across 21 `WIP SOURCE - Axial 3D pCASL...`, `SOURCE - Axial 3D pCASL...`, and `Axial 2D/3D PASL...` descriptions)
//         - Diffusion Tensor Imaging / White Matter: 15 records
//           - `Axial MB DTI`, `Axial MB DTI_FA`, `Axial MB DTI_ADC`, `Axial MB DTI_TENSOR_B0`, `Axial MB DTI_TRACEW` (3 each = 15)

//     ],
//   )
// ]




#section-slide("ADNI Visit Tracking")

#split-slide(
  38%,
  [#slide-title([`VISCODE` vs. `VISCODE2`], color: cream)
    #align(bottom)[
      - Participant `002_S_0413` is a #text(weight: "bold")[rollover participant] tracked across ADNI 1, ADNI 2, and ADNI 3.

      - ADNI uses two distinct visit-tracking systems:
        - #text(weight: "bold")[`Visit` (`VISCODE`):] phase-specific protocol label.
        - #text(weight: "bold")[`VISCODE2`:] unified global month code from initial baseline.

      - Example (`master_data_file.csv`, line 7): `Visit = init` means first visit in ADNI 3; `VISCODE2 = m132` means 132 months (11 yrs) since baseline.
    ]
  ],
  [
    1. *`Visit` (`VISCODE`) — Phase-Specific Protocol Visit*
      - *ADNI 1 (2006–2010):* `bl`, `m06`, `m12`, `m24`, `m36`, `m48`
      - *ADNI 2 (2011–2016):* `v06`, `v11`, `v21`, `v31`, `v41`
      - *ADNI 3 (2016–2022):* `init` (initial rollover/enrollment visit), then annual follow-ups `y1`, `y2`, ...
      - *ADNI 4 (2022–present):* `4_init`, `4_m12`, ...
      - On `2017-06-21`, LONI records `Visit = init` because it was `002_S_0413`'s first scan under the ADNI 3 protocol.

    2. *`VISCODE2` — Global Longitudinal Month Code*
      - Continuous timeline measured in elapsed months from the participant's very first ADNI enrollment (`2006-05-10`).
      - `2015-06-02` (ADNI 2 `v41`) #sym.arrow.r `VISCODE2 = m108`
      - `2017-06-21` (ADNI 3 `init`, Line 7) #sym.arrow.r 11 yrs #sym.arrow.r `m132`
      - `2019-08-27` (ADNI 3 `y2`, Line 8) #sym.arrow.r 13.5 yrs #sym.arrow.r `m162`
  ],
)

#slide[
  #slide-title("Longitudinal Timeline: Participant 002_S_0413")
  #v(14pt)
  #set text(size: 13pt)
  #table(
    columns: (1.05fr, 0.9fr, 1.05fr, 0.95fr, 1.45fr, 2.3fr),
    inset: (x: 8pt, y: 7pt),
    stroke: 0.5pt + rgb("d0d4c8"),
    fill: (col, row) => if row == 0 { olive } else if row == 7 { rgb("eef1e6") } else if calc.odd(row) { rgb("f9faf7") } else { cream },
    table.header(
      text(fill: cream, weight: "bold")[Study Date],
      text(fill: cream, weight: "bold")[Phase],
      text(fill: cream, weight: "bold")[`Visit` (`VISCODE`)],
      text(fill: cream, weight: "bold")[`VISCODE2`],
      text(fill: cream, weight: "bold")[Elapsed Time],
      text(fill: cream, weight: "bold")[Notes],
    ),
    [*2006-05-10*], [ADNI 1], [`bl`], [`bl`], [*0 months*], [Initial baseline enrollment],
    [*2011-06-16*], [ADNI 2], [`v06`], [`m60`], [*60 months* (5 yrs)], [First fMRI protocol visit],
    [*2012-05-15*], [ADNI 2], [`v11`], [`m72`], [*72 months* (6 yrs)], [Line 3 in `master_data_file.csv`],
    [*2013-05-10*], [ADNI 2], [`v21`], [`m84`], [*84 months* (7 yrs)], [Line 4 in `master_data_file.csv`],
    [*2014-05-01*], [ADNI 2], [`v31`], [`m96`], [*96 months* (8 yrs)], [Line 5 in `master_data_file.csv`],
    [*2015-06-09*], [ADNI 2], [`v41`], [`m108`], [*108 months* (9 yrs)], [Line 6 in `master_data_file.csv`],
    [*2017-06-21*], [*ADNI 3*], [*`init`*], [*`m132`*], [*132 months (11 yrs)*], [*Line 7: First visit under ADNI 3 protocol*],
    [*2019-08-27*], [*ADNI 3*], [*`y2`*], [*`m162`*], [*162 months (13.5 yrs)*], [Line 8: Year 2 follow-up in ADNI 3],
  )
]

#section-slide("fMRIPrep Pipeline & Slurm")

#slide[
  #slide-title([Slurm Job Configuration (`scripts/run_fmriprep.sh`)])
  #v(10pt)
  #set text(size: 12.5pt)
  #table(
    columns: (0.45fr, 1.9fr, 3.4fr),
    inset: (x: 8pt, y: 6pt),
    stroke: 0.5pt + rgb("d0d4c8"),
    fill: (col, row) => if row == 0 { olive } else if calc.odd(row) { rgb("f9faf7") } else { cream },
    table.header(
      text(fill: cream, weight: "bold")[Line],
      text(fill: cream, weight: "bold")[`#SBATCH` Directive],
      text(fill: cream, weight: "bold")[Purpose & Why This Value Was Chosen],
    ),
    [2], [`--job-name=adni_fmriprep`], [Identifies jobs in `squeue` for monitoring or cancellation.],
    [3], [`--nodes=1`], [Keeps all cores on one physical node (`fMRIPrep` uses shared-memory threads, not multi-node MPI).],
    [4], [`--ntasks=1`], [Launches 1 main container process per job, which spawns internal worker threads.],
    [5], [`--cpus-per-task=8`], [Sweet spot for speed vs. queue throughput; FreeSurfer `recon-all` plateaus above 8 cores (2-hemisphere bottleneck).],
    [6], [`--mem=32G`], [Single-band needs \~14 GB, but ADNI3/4 multiband (`976` vols) + ANTs + `91k` CIFTI spike to 22–28 GB; prevents OOM kills.],
    [7], [`--time=12:00:00`], [Most sessions finish in 3.5–6 h; atrophy/motion scans in `mris_fix_topology` can take 7–10 h.],
    [8], [`--array=1-2`], [Job array assigning `$SLURM_ARRAY_TASK_ID` (`1–2` pilot; later `3-3218%80`).],
    [9–10], [`--output` / `--error` (`_%A_%a`)], [Separate `.out`/`.err` logs per session (`%A` = master array ID, `%a` = task `1..3218`).],
  )
]

#split-slide(
  38%,
  [#slide-title([Singularity & Mounts], color: cream)
    #align(bottom)[
      - #text(weight: "bold")[Why `SINGULARITYENV_TEMPLATEFLOW_HOME`?]
        - `--cleanenv` wipes host variables so Matilda's Python/libraries cannot leak into the container.
        - Variables prefixed with `SINGULARITYENV_` pass through `--cleanenv`.
        - Sets `TEMPLATEFLOW_HOME="/opt/templateflow"` inside the container so offline compute nodes read local atlases without internet access.
    ]
  ],
  [
    *Singularity Bind Mounts (`-B host:container`, lines 43–62):*
    - `--cleanenv`: Isolates container from host environment variables.
    - `-B "${BIDS_DIR}:/data:ro"`: Mounts `/scratch/users/moghaddami/fmriprep-ready` as *read-only (`:ro`)* so raw BIDS data can never be modified.
    - `-B "${SES_DERIV}:/out"`: Session-specific output derivatives folder.
    - `-B "${SES_FSDIR}:/fsdir"`: Isolated FreeSurfer directory per session.
    - `-B "${WORK_DIR}:/work"`: Temporary Nipype working directory (15–25 GB; deleted at line 70 on success).
    - `-B "${FS_LICENSE}:/opt/freesurfer/license.txt:ro"`: FreeSurfer license at the default container lookup path.
    - `-B "${TEMPLATEFLOW_DIR}:/opt/templateflow"`: Cached TemplateFlow brain atlases.
  ],
)

#split-slide(
  38%,
  [#slide-title([fMRIPrep Flags & Safety], color: cream)
    #align(bottom)[
      - #text(weight: "bold")[Longitudinal ADNI Safeguard:]
        - `--bids-filter-file /work/bids_filter.json` restricts `fMRIPrep` to #text(weight: "bold")[only `ses-${SES}`].
        - Without it, `fMRIPrep` averages all longitudinal T1w scans of a subject into one static template, erasing atrophy across visits.
      - #text(weight: "bold")[Safe Cleanup (lines 86–90):]
        - Deletes `SES_FSDIR` only after verifying `aseg.stats` is non-empty in `/projects`.
    ]
  ],
  [
    - `/data /out participant --participant-label "${SUB}"`
    - `--skip-bids-validation`: Avoids failing on `master_data_file.csv` / `"SliceTimingSource"` and stops 80 jobs from crawling 12,872 files on `/scratch`.
    - `--fs-subjects-dir /fsdir`: Keeps `recon-all` enabled (no `--fs-no-reconall`) in an isolated per-session directory.
    - `--nprocs 8 --omp-nthreads 8 --mem-mb 30000`: Matches 8 CPUs; leaves a 2 GB buffer below Slurm's 32 GB cap.
    - `--output-spaces MNI152NLin2009cAsym:res-2 T1w`: 2 mm standard MNI space (Schaefer/AAL/Shen) + native T1w space.
    - `--cifti-output 91k`: HCP `fsLR` `91k` grayordinates (`.dtseries.nii`) for surface atlases (Glasser 360 / surface Schaefer).
    - *Slice timing & offline:* No `--ignore slicetiming` (runs `3dTshift`); `--notrack` prevents telemetry hangs on offline compute nodes.
  ],
)

#section-slide("Outputs & GNN Features")

#split-slide(
  38%,
  [#slide-title([FreeSurfer & Session Outputs], color: cream)
    #align(bottom)[
      - Keeping FreeSurfer `recon-all` enabled permanently saves both #text(weight: "bold")[GNN structural node features] and the #text(weight: "bold")[Euler number] for QC:
        $ "Euler" = 2 - 2 times "holes" $
      - `surf/` & `label/` meshes (#box[`?h.white`], #box[`?h.pial`], #box[`?h.thickness`], #box[`?h.sphere.reg`]) also allow projecting functional atlases onto the cortex.
    ]
  ],
  [
    *A. Backed up in `/projects/.../extracted_freesurfer_stats/` (\~540 KB/session):*
    - `lh/rh.aparc*.stats`: Regional cortical thickness (`ThickAvg/Std`), `GrayVol`, `SurfArea`, and curvature across Desikan-Killiany (`68`), DKT (`62`), and Destrieux (`148`) atlases.
    - `aseg.stats`: Subcortical volumes (Hippocampus, Amygdala, Thalamus, Lateral Ventricles, `eTIV`) + `lhSurfaceHoles` / `rhSurfaceHoles`.
    - `*_desc-confounds_timeseries.tsv`: `FD`, `dvars`, 24 motion regressors, WM/CSF/global signal, `a_comp_cor`, `non_steady_state_outlier_XX`.

    *B. Stored on `/scratch/.../fmriprep-output/` (\~1.6 GB/session):*
    - `*_space-MNI152NLin2009cAsym_res-2_desc-preproc_bold.nii.gz` (\~540 MB): 4D MNI BOLD (unfiltered; `nilearn` handles bandpass & denoising).
    - `*_space-fsLR_den-91k_bold.dtseries.nii` (\~50 MB): 91k surface + subcortical grayordinates.
    - `anat/` & `freesurfer/<SESSION>.tar` (\~770 MB): T1w, segmentations, GIFTI thickness maps, `.tar` archive.
  ],
)

#slide[
  #slide-title("Pipeline Outputs: What We Use vs. Ignore")
  #v(14pt)
  #set text(size: 13pt)
  #table(
    columns: (2.4fr, 0.8fr, 3.2fr),
    inset: (x: 9pt, y: 8pt),
    stroke: 0.5pt + rgb("d0d4c8"),
    fill: (col, row) => if row == 0 { olive } else if calc.odd(row) { rgb("f9faf7") } else { cream },
    table.header(
      text(fill: cream, weight: "bold")[Output File / Folder],
      text(fill: cream, weight: "bold")[Action],
      text(fill: cream, weight: "bold")[Why / How It Is Used],
    ),
    [`*_res-2_desc-preproc_bold.nii.gz` (or `91k` CIFTI)], [*USE*], [Passed to `nilearn` (`NiftiLabelsMasker`) to extract ROI BOLD time series and compute the $N times N$ connectivity matrix (`.npz`).],
    [`*_desc-confounds_timeseries.tsv`], [*USE*], [1) Motion QC: drop sessions with `>30%` frames `FD > 0.5 mm` or `<5 min` usable data. 2) Denoising: 24 motion + WM/CSF/Global Signal regressors.],
    [`stats/aseg.stats` + `lh/rh.aparc*.stats`], [*USE*], [1) Structural QC via Euler number (`SurfaceHoles`). 2) GNN structural node features (cortical thickness, GM volume, surface area, subcortical volumes).],
    [`*_boldref.nii.gz`, `*_hmc_xfm.txt`, `*_coreg_xfm.txt`, `*_xfm.h5`], [*IGNORE*], [Intermediate registration references and warp matrices already applied by `fMRIPrep` to produce the MNI/CIFTI BOLD outputs.],
    [Unused columns in `confounds_timeseries.tsv`], [*IGNORE*], [`fMRIPrep` exports \~100+ confound columns; we select \~9–36 denoising regressors and ignore the rest.],
  )
]

#split-slide(
  38%,
  [#slide-title([Multimodal GNN + RNN], color: cream)
    #align(bottom)[
      - Each visit $t$ is a brain graph:
        $ cal(G)_t = (cal(V), cal(E), bold(X)_t, bold(A)_t) $
      - #text(weight: "bold")[Edge matrix $bold(A)_t in RR^(N times N)$:] functional connectivity (Pearson $r_(i j)$ or Fisher $z_(i j) = "arctanh"(r_(i j))$).
      - #text(weight: "bold")[RNN Visit-Level Features:]
        - `Age`, `Sex`, elapsed time $Delta t$, and normalized lateral ventricle volume (`Lateral-Ventricle / eTIV`).
    ]
  ],
  [
    *Node Feature Vector $bold(x)_(i,t) in RR^F$ per Brain Region $i$:*
    1. *Functional Features (fMRI):*
      - *Connectivity profile:* Row $bold(r)_i in RR^N$ of the correlation matrix.
      - *Regional BOLD activity:* ALFF / fALFF ($0.01–0.08 "Hz"$ power) and temporal SD ($sigma_i$).
      - *Local graph topology:* Node degree/strength ($sum_j |A_(i j)|$), clustering coefficient, local efficiency, eigenvector/PageRank centrality.
    2. *Structural Atrophy Features (FreeSurfer `stats/`):*
      - `ThickAvg` & `ThickStd` (cortical thinning in entorhinal/temporal/parietal regions).
      - Normalized volume (`GrayVol / eTIV`), surface area (`SurfArea / eTIV`), curvature (`MeanCurv`, `FoldInd`), plus subcortical volumes (Hippocampus, Amygdala, Thalamus, Caudate, Putamen).
    3. *Spatial & Network Identity:*
      - 3D MNI centroid $(x_i, y_i, z_i)$ and one-hot canonical network (DMN, Limbic, Frontoparietal, Salience, etc.).
  ],
)

#split-slide(
  38%,
  [#slide-title([Brain Atlas Flexibility], color: cream)
    #align(bottom)[
      - `fMRIPrep` does #text(weight: "bold")[not] lock us into a single brain atlas.
      - `MNI152NLin2009cAsym:res-2` and `fsLR 91k` are #text(weight: "bold")[coordinate systems], not ROI parcellations.
      - Extracting a 2D matrix in `nilearn` takes only seconds per scan, so multiple atlases can be compared later without re-running `fMRIPrep`.
    ]
  ],
  [
    *Three Downstream Options Available Without Re-running `fMRIPrep`:*
    1. *Functional Atlas + FreeSurfer `stats/` Features:*
      - Compute $100 times 100$ or $200 times 200$ fMRI connectivity in `nilearn` using *Schaefer-100/200*, paired with regional cortical thickness and hippocampal volumes from `extracted_freesurfer_stats/`.
    2. *FreeSurfer Anatomical Atlas (`aparcaseg_dseg.nii.gz`):*
      - Pass `fMRIPrep`'s aligned segmentation mask to `nilearn` for an exact *1-to-1 node match* (84-node Desikan-Killiany or 164-node Destrieux) between fMRI edges and `stats/` structural features.
    3. *Surface-Based Schaefer / Glasser Atlas:*
      - Combine `91k` CIFTI BOLD (`.dtseries.nii`) with saved vertex-wise cortical thickness maps (`*_thickness.shape.gii`) directly on the cortical surface.
  ],
)

#section-slide("Pilot Run & Scaling")

#split-slide(
  36%,
  [#slide-title([2-Session Pilot Verified], color: cream)
    #align(bottom)[
      - #text(weight: "bold")[`sessions_list.tsv`:] all `3,218` sessions queued.
      - #text(weight: "bold")[Backed-up files (21/session):]
        - `19` FreeSurfer `.stats` files (`aseg`, `aparc`, `DKTatlas`, `a2009s`, `wmparc`, etc.)
        - `recon-all.log` (\~350 KB)
        - `confounds_timeseries.tsv` (\~280 KB, `140` timepoints)
      - #text(weight: "bold")[`slurm_logs/`:] clean `.out` logs and `0`-byte `.err` files.
    ]
  ],
  [
    *Quality Check on Pilot Sessions (Parsed from `aseg.stats` & Confounds):*
    #v(8pt)
    #set text(size: 12.5pt)
    #table(
      columns: (1.5fr, 1fr, 1fr),
      inset: (x: 8pt, y: 7pt),
      stroke: 0.5pt + rgb("d0d4c8"),
      fill: (col, row) => if row == 0 { olive } else if calc.odd(row) { rgb("f9faf7") } else { cream },
      table.header(
        text(fill: cream, weight: "bold")[Metric],
        text(fill: cream, weight: "bold")[`sub-002S0295`\ `ses-20120510`],
        text(fill: cream, weight: "bold")[`sub-002S0413`\ `ses-20120515`],
      ),
      [*Euler Number* (`lh` / `rh` holes)], [`-42` (`8` / `14` holes)], [`-32` (`7` / `10` holes)],
      [*Intracranial Vol (`eTIV`)*], [`1,687,174 mm³`], [`1,305,151 mm³`],
      [*BOLD Volumes*], [`140`], [`140`],
      [*Mean Motion (`FD`)*], [`0.173 mm`], [`0.123 mm`],
      [*Frames `FD > 0.5 mm`*], [*`0.0%` (Pass)*], [*`0.0%` (Pass)*],
    )
    #v(8pt)
    Both pilot sessions passed all structural and functional QC criteria with `0%` high-motion frames.
  ],
)

#split-slide(
  38%,
  [#slide-title([Scaling to 3,218 Sessions], color: cream)
    #align(bottom)[
      - Two operational adjustments before submitting the remaining `3,216` sessions (`--array=3-3218%80`).
    ]
  ],
  [
    1. *Keep 4D BOLD NIfTIs on `/scratch` & Extract Compact Matrices on Matilda:*
      - Preprocessed 4D BOLD files (\~540 MB/session #sym.arrow.r \~3.2 TB total) remain on `/scratch`.
      - A fast Python/`nilearn` script on Matilda will read each 4D BOLD + confounds TSV and save compact *2D functional connectivity matrices (`.npz`, \~80 KB/session)* into `/projects`.

    2. *Update `.gitignore` Before Full Array Run:*
      - Across all `3,218` sessions, `extracted_freesurfer_stats/` and `slurm_logs/` will reach *\~74,000 files (\~3.2 GB)*, exceeding GitHub's 2 GB push limit.
      - Re-enable both folders in `.gitignore` while keeping permanent copies in `/projects/adresearch/moghaddami/gnn-connectivity-matrix/` on Matilda, then compile all `3,218` `stats/` folders into a single \~5 MB summary CSV for GitHub.
  ],
)

#section-slide("Diagnosis")

#split-slide(
  38%,
  [#slide-title([Stable & Pure Progression], color: cream)
    #align(bottom)[
      - #text(weight: "bold")[Stable:] `1,178` subjects (`631` multi-scan)

      - #text(weight: "bold")[Pure Progression:] `110` subjects (vs. `53` converters in SPIE)

      - #text(weight: "bold")[Pure Reversion:] `23` subjects

      - #text(weight: "bold")[Fluctuating / Multi-Step:] `15` subjects
    ]
  ],
  [
    *Stable (`1,178` subjects):*
    #v(4pt)
    #set text(size: 13pt)
    #table(
      columns: (1.5fr, 1.2fr, 1.2fr),
      inset: (x: 8pt, y: 6pt),
      stroke: 0.5pt + rgb("d0d4c8"),
      fill: (col, row) => if row == 0 { olive } else if calc.odd(row) { rgb("f9faf7") } else { cream },
      table.header(
        text(fill: cream, weight: "bold")[Diagnosis],
        text(fill: cream, weight: "bold")[Multi-Scan],
        text(fill: cream, weight: "bold")[Total],
      ),
      [Stable `CN`], [`333`], [`642`],
      [Stable `MCI`], [`222`], [`392`],
      [Stable `AD`], [`76`], [`144`],
    )

    #v(10pt)
    #set text(size: 15pt)
    *Pure Progression (`110` subjects — SPIE: `53` converters):*
    #v(4pt)
    #set text(size: 13pt)
    #table(
      columns: (1.8fr, 1.1fr, 1.1fr),
      inset: (x: 8pt, y: 6pt),
      stroke: 0.5pt + rgb("d0d4c8"),
      fill: (col, row) => if row == 0 { olive } else if calc.odd(row) { rgb("f9faf7") } else { cream },
      table.header(
        text(fill: cream, weight: "bold")[Trajectory],
        text(fill: cream, weight: "bold")[ADNI fMRI],
        text(fill: cream, weight: "bold")[SPIE],
      ),
      [`MCI` #sym.arrow.r `AD`], [`62`], [`37`],
      [`CN` #sym.arrow.r `MCI`], [`43`], [`16`],
      [`CN` #sym.arrow.r `MCI` #sym.arrow.r `AD`], [`5`], [—],
      [`CN` #sym.arrow.r `AD` (direct)], [`3`], [—],
    )
  ],
)

#split-slide(
  38%,
  [#slide-title([Reversion & Fluctuating], color: cream)
    #align(bottom)[
      - #text(weight: "bold")[Pure Reversion (`23` subjects):]
        - Patients whose diagnosis improved over follow-up (`MCI` #sym.arrow.r `CN`, `AD` #sym.arrow.r `MCI`, `AD` #sym.arrow.r `CN`).

      - #text(weight: "bold")[Open Question / Idea:]
        - Can we use the #text(weight: "bold")[reversed sequence] of a reversion case (e.g., `CN` #sym.arrow.r `MCI`) as an additional conversion sample?

      - #text(weight: "bold")[Fluctuating / Multi-Step (`15` subjects):]
        - Non-monotonic diagnostic changes across visits.
    ]
  ],
  [
    *Pure Reversion (`23` subjects):*
    #v(4pt)
    #set text(size: 13pt)
    #table(
      columns: (2.2fr, 1fr),
      inset: (x: 8pt, y: 6pt),
      stroke: 0.5pt + rgb("d0d4c8"),
      fill: (col, row) => if row == 0 { olive } else if calc.odd(row) { rgb("f9faf7") } else { cream },
      table.header(
        text(fill: cream, weight: "bold")[Trajectory],
        text(fill: cream, weight: "bold")[Subjects],
      ),
      [`MCI` #sym.arrow.r `CN`], [`21`],
      [`AD` #sym.arrow.r `MCI`], [`1`],
      [`AD` #sym.arrow.r `CN`], [`1`],
    )

    #v(10pt)
    #set text(size: 15pt)
    *Fluctuating / Multi-Step (`15` subjects):*
    #v(4pt)
    #set text(size: 13pt)
    #table(
      columns: (2.2fr, 1fr),
      inset: (x: 8pt, y: 5.5pt),
      stroke: 0.5pt + rgb("d0d4c8"),
      fill: (col, row) => if row == 0 { olive } else if calc.odd(row) { rgb("f9faf7") } else { cream },
      table.header(
        text(fill: cream, weight: "bold")[Trajectory],
        text(fill: cream, weight: "bold")[Subjects],
      ),
      [`MCI` #sym.arrow.r `CN` #sym.arrow.r `MCI`], [`5`],
      [`MCI` #sym.arrow.r `CN` #sym.arrow.r `MCI` #sym.arrow.r `CN`], [`4`],
      [`MCI` #sym.arrow.r `AD` #sym.arrow.r `MCI`], [`2`],
      [`CN` #sym.arrow.r `MCI` #sym.arrow.r `CN`], [`2`],
      [`MCI` #sym.arrow.r `CN` #sym.arrow.r `AD`], [`1`],
      [`MCI` #sym.arrow.r `AD` #sym.arrow.r `MCI` #sym.arrow.r `AD`], [`1`],
    )
  ],
)

#section-slide("Thank you!")
