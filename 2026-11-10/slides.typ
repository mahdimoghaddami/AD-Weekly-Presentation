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

#section-slide("Salvaging Scans")

#split-slide(
  35%,
  [#slide-title([Salvaging Broken Scans], color: cream)
    #align(bottom)[
      - I salvaged 170 broken fMRI scans!
    ]
  ],
  [
    - These scans were previously unusable due to technical issues.
    - I managed to recover the data and make it available for further analysis.
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
