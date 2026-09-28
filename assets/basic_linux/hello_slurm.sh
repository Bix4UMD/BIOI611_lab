#!/bin/bash
#SBATCH --job-name=bioi611_hello
#SBATCH --account=bioi611-class
#SBATCH --partition=standard
#SBATCH --time=00:02:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

source /etc/profile
set -euo pipefail
cd "$SLURM_SUBMIT_DIR"
printf 'Job ID: %s\n' "$SLURM_JOB_ID"
printf 'Host: '
hostname
date
printf 'Working directory: '
pwd
grep -c '^>' data/sequences.fasta > results/sequence_count.txt
printf 'Sequences: '
cat results/sequence_count.txt
