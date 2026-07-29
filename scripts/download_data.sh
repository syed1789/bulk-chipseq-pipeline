#!/bin/bash
# Fetches Spt5 ChIP-seq FASTQ (2 IP + 2 matched Input replicates, downsampled
# to 100k read pairs) and the S. cerevisiae reference genome from
# nf-core/test-datasets (chipseq branch), derived from PRJNA315202
# (Baejen et al., Molecular Cell 2017).
set -euo pipefail
cd "$(dirname "$0")/.."

BASE="https://raw.githubusercontent.com/nf-core/test-datasets/chipseq/testdata"
REFBASE="https://raw.githubusercontent.com/nf-core/test-datasets/chipseq/reference"

mkdir -p data/fastq data/reference

for f in SRR5204807_Spt5-ChIP_IP1_SacCer_ChIP-Seq_ss100k_R1 SRR5204807_Spt5-ChIP_IP1_SacCer_ChIP-Seq_ss100k_R2 \
         SRR5204808_Spt5-ChIP_IP2_SacCer_ChIP-Seq_ss100k_R1 SRR5204808_Spt5-ChIP_IP2_SacCer_ChIP-Seq_ss100k_R2 \
         SRR5204809_Spt5-ChIP_Input1_SacCer_ChIP-Seq_ss100k_R1 SRR5204809_Spt5-ChIP_Input1_SacCer_ChIP-Seq_ss100k_R2 \
         SRR5204810_Spt5-ChIP_Input2_SacCer_ChIP-Seq_ss100k_R1 SRR5204810_Spt5-ChIP_Input2_SacCer_ChIP-Seq_ss100k_R2; do
  out="data/fastq/${f}.fastq.gz"
  [ -f "$out" ] && { echo "Already downloaded: $out"; continue; }
  echo "Downloading $out"
  curl -sL --fail -o "$out" "${BASE}/${f}.fastq.gz"
done

if [ ! -f data/reference/genome.fa ]; then
  echo "Downloading S. cerevisiae reference genome"
  curl -sL --fail -o data/reference/genome.fa "${REFBASE}/genome.fa"
fi
if [ ! -f data/reference/genes.bed ]; then
  curl -sL --fail -o data/reference/genes.bed "${REFBASE}/genes.bed"
fi

echo "Done."
