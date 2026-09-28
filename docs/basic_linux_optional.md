# Optional Linux, software, and HPC extensions

Complete the [main Linux lesson](basic_linux.md) first. These sections are independent references for later analyses; they are not a sequence of commands to paste into a login node. Use Slurm for substantial computations.

## Symbolic links

A symbolic link names another file or directory without making a second copy. Try this inside your practice directory:

```bash
cd ~/scratch.bioi611/linux_practice
ln -s ../data/sequences.fasta results/sequences_link.fasta
ls -l results/sequences_link.fasta
readlink -f results/sequences_link.fasta
cat results/sequences_link.fasta
unlink results/sequences_link.fasta
ls data/sequences.fasta
```

A relative link target is interpreted from the directory containing the link. Here it is relative to `results/`. `unlink` removes this link, leaving the target file in `data/` intact. If the target moves or disappears, the link becomes broken. A link is not a backup and does not bypass permissions or storage quotas.

## Install software only when needed

First inspect the cluster's software library:

```bash
module list
module avail python
module load python
python3 --version
```

Discover the available module names and versions rather than copying another cluster's module list. Record the exact loaded version for reproducibility. Follow [UMD's module reference](https://hpcc.umd.edu/kb/utilities/) and [software installation guidance](https://hpcc.umd.edu/software/installing_sw/).

### Install Miniforge3 in your personal scratch space

Do this only if you need a personal Conda installation and have not already set one up for this course. Use **Miniforge3**; Mambaforge has been retired. Installation and package caches can consume substantial space, so place them in your own scratch directory rather than filling home. SHELL is not suitable for software that must run on compute nodes.

This example pins the Linux x86_64 installer to [Miniforge3 26.7.2-0](https://github.com/conda-forge/miniforge/releases/tag/26.7.2-0). Check the architecture first:

```bash
uname -m
```

Continue with this installer only when the result is `x86_64`. If the installation prefix below already exists, reuse it instead of reinstalling over it.

```bash
cd ~/scratch.bioi611
mkdir -p software/downloads software/envs software/conda_pkgs
cd software/downloads
wget https://github.com/conda-forge/miniforge/releases/download/26.7.2-0/Miniforge3-26.7.2-0-Linux-x86_64.sh
bash Miniforge3-26.7.2-0-Linux-x86_64.sh -b -p "$HOME/scratch.bioi611/software/miniforge3"
source "$HOME/scratch.bioi611/software/miniforge3/etc/profile.d/conda.sh"
conda --version
```

Check that the download and installation complete successfully before continuing. `source` makes the activation function available in the current shell; repeat it when opening a new terminal. This approach does not require automatically activating Conda from `.bashrc`.

### Create a course environment

The following environment includes Python, FastQC, and STAR, so the alignment example below does not depend on software missing from its installation instructions. The versions are explicit course examples, not a claim that they are the newest releases.

```bash
export CONDA_PKGS_DIRS="$HOME/scratch.bioi611/software/conda_pkgs"
conda create --prefix "$HOME/scratch.bioi611/software/envs/bioi611" \
    --override-channels --channel conda-forge --channel bioconda \
    --strict-channel-priority python=3.11 fastqc=0.12.1 star=2.7.11b
conda activate "$HOME/scratch.bioi611/software/envs/bioi611"
python3 --version
fastqc --version
STAR --version
```

Confirm Conda's proposed transaction when prompted and wait for it to finish. Do not proceed to a batch job if a package cannot be resolved or its version check fails. The channel order follows [Bioconda's current recommendations](https://bioconda.github.io/).

Record the requested packages and the resolved environment:

```bash
conda env export --from-history > "$HOME/scratch.bioi611/software/bioi611-requested.yml"
conda list --explicit > "$HOME/scratch.bioi611/software/bioi611-linux-64-explicit.txt"
```

The history export captures requested dependencies; the explicit export records resolved package builds for the same platform. Keep these small files with your analysis scripts and preserve a separate copy. Scratch installations are not backed up. In each batch script, source the same `conda.sh` and activate the same environment explicitly.

## An RNA-seq job with STAR

This is a **later-course template**, not part of the tiny first-day exercise. Before submitting it, you need all of the following:

- The environment installed above, with `STAR --version` working.
- A scratch analysis directory containing `STAR_ref/`, a completed STAR genome index for the correct reference assembly.
- A matching single-end FASTQ file at `raw_data/N2_day1_rep1.fastq.gz`. This filename is an example: change it to your real sample.
- Enough project storage, available compute allocation, and memory/time appropriate for your reference and dataset.

The synthetic sequences in the main lesson are **not** substitutes for an RNA-seq reference or FASTQ input. Follow the [RNA-seq lab](bulkRNAseq_lab.md) for reference and input preparation. Index construction is itself a compute job.

Save the following as `s1_star.sh` in your scratch RNA-seq analysis directory:

```bash
#!/bin/bash
#SBATCH --job-name=s1_star_aln
#SBATCH --account=bioi611-class
#SBATCH --partition=standard
#SBATCH --time=40:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --mem=32G
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

source /etc/profile
source "$HOME/scratch.bioi611/software/miniforge3/etc/profile.d/conda.sh" || exit 1
conda activate "$HOME/scratch.bioi611/software/envs/bioi611" || exit 1
set -euo pipefail
cd "$SLURM_SUBMIT_DIR"
command -v STAR
STAR --version
test -s STAR_ref/Genome
test -s raw_data/N2_day1_rep1.fastq.gz
mkdir -p STAR_align
STAR --genomeDir STAR_ref \
    --outSAMtype BAM SortedByCoordinate \
    --twopassMode Basic \
    --quantMode TranscriptomeSAM GeneCounts \
    --readFilesCommand zcat \
    --outFileNamePrefix STAR_align/N2_day1_rep1. \
    --runThreadN "$SLURM_CPUS_PER_TASK" \
    --readFilesIn raw_data/N2_day1_rep1.fastq.gz
```

The 20 CPUs, 32 GB, and 40-hour limit are example requests; choose values suitable for the analysis, and review actual usage afterward. A large reference or BAM sorting may require more memory. Paired-end data require both FASTQ filenames. Each sample or concurrent run needs its own output prefix/directory so results are not overwritten.

From the analysis directory that contains the script, index, and input:

```bash
pwd
ls STAR_ref/Genome raw_data/N2_day1_rep1.fastq.gz
mkdir -p logs
sbalance
sbatch s1_star.sh
```

`$SLURM_CPUS_PER_TASK` keeps the program's thread count consistent with the allocation. Job paths are interpreted from the submission directory; `#SBATCH` directives do not expand shell variables such as `$HOME`. See [UMD's submission guide](https://hpcc.umd.edu/kb/submitting-jobs/).

## Download a real gene-count table

The main lesson uses fixed synthetic data so everyone sees the same answers. For a later exercise, download the **GSE102537** table with a matching filename:

```bash
cd ~/scratch.bioi611/linux_practice
mkdir -p data/geo
wget -O data/geo/GSE102537_raw_counts_GRCh38.p13_NCBI.tsv.gz \
    'https://www.ncbi.nlm.nih.gov/geo/download/?type=rnaseq_counts&acc=GSE102537&format=file&file=GSE102537_raw_counts_GRCh38.p13_NCBI.tsv.gz'
gzip -t data/geo/GSE102537_raw_counts_GRCh38.p13_NCBI.tsv.gz
zcat data/geo/GSE102537_raw_counts_GRCh38.p13_NCBI.tsv.gz | head -n 5
```

Inspect the header and sample metadata before selecting columns. A count threshold is a data-manipulation demonstration, not a differential-expression analysis. For a table with one header line, a tab-separated numeric filter can explicitly exclude it:

```bash
zcat data/geo/GSE102537_raw_counts_GRCh38.p13_NCBI.tsv.gz \
    | awk -F '\t' 'NR > 1 && $2 > 500 && $3 > 500' \
    | wc -l
```

Record the accession, filename, download date, and checksum alongside your analysis. External data can change, so do not reuse the synthetic dataset's expected counts here. On large real datasets, run substantial processing through Slurm. In a script using `pipefail`, a preview ending in `head` can cause an upstream command to report a broken pipe after `head` exits early.

## Containers

A container packages software and dependencies. It helps keep software environments consistent, but identical scientific results still depend on inputs, parameters, software versions, random seeds, and sometimes hardware. Docker commonly uses a privileged daemon, although rootless Docker also exists. HPC sites often provide Apptainer or Singularity for running containers without a Docker daemon.

Check what Zaratan currently provides:

```bash
module avail singularity
module avail apptainer
```

Load an available module using its actual name. The commands below use `singularity`; if your instructor provides Apptainer instead, use `apptainer` with the corresponding commands. Do not assume a module name from a different cluster is available here.

After loading the runtime, download a versioned Trim Galore image into scratch:

```bash
cd ~/scratch.bioi611
mkdir -p software/containers software/container_cache
export SINGULARITY_CACHEDIR="$HOME/scratch.bioi611/software/container_cache"
export APPTAINER_CACHEDIR="$HOME/scratch.bioi611/software/container_cache"
cd software/containers
singularity pull trimgalore_v0.6.10.sif docker://quay.io/biocontainers/trim-galore:0.6.10--hdfd78af_0
singularity exec trimgalore_v0.6.10.sif trim_galore --help
```

A `.sif` file is a Singularity/Apptainer image; the `docker://` reference names an image in a registry. Keep the image tag and checksum with your analysis record. If that tag is unavailable, check the BioContainers registry rather than silently using an unversioned image.

To expose your own scratch directory at a predictable path inside the container:

```bash
singularity exec -B "$HOME/scratch.bioi611:/work" trimgalore_v0.6.10.sif ls /work
```

Here `-B` binds the host directory to `/work` in the container. Paths in analysis commands must match the paths visible inside the container. Checking help or listing a small directory is a lightweight check; actual read trimming still belongs in a Slurm job. Containers do not allocate CPUs or memory on their own.

## Build from source

Use a provided module, Conda environment, or course container first. When building from source is necessary, follow the project's own build instructions, record a release or commit, and install under your own scratch space. A compiler and development libraries may be required; do not use `sudo` on the cluster.

For example, after checking [BWA's build instructions](https://github.com/lh3/bwa) and loading any required compiler module:

```bash
cd ~/scratch.bioi611
mkdir -p software/src
cd software/src
git clone https://github.com/lh3/bwa.git
cd bwa
git rev-parse HEAD
make
```

Save the commit ID with your analysis notes. For a reproducible course environment, use the instructor's selected release/commit before building. Do not start genome indexing on a login node after compilation: prepare a Slurm job with the real reference path and suitable resources.

## Inspect cluster resources

These commands report changing cluster state, so their output will differ between sessions:

```bash
sinfo -s
scontrol show partition standard
squeue -u "$USER"
```

For a job of your own, replace `123456` with its ID:

```bash
scontrol show job 123456
sacct -j 123456 --format=JobID,State,ExitCode,Elapsed,AllocCPUS,MaxRSS
```

Inspect a node with `scontrol show node NODE_NAME`, replacing `NODE_NAME` with a real name from `sinfo` or your job information. Available node resources do not describe your personal allocation balance; use `sbalance` for that. Start with your job state and logs before interpreting detailed node configuration.
