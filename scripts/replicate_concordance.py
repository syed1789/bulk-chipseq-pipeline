#!/usr/bin/env python3
"""Snakemake script: peak-overlap concordance between the two biological
replicates -- the standard first-line ChIP-seq reproducibility check."""
import csv


def load_peaks(path):
    peaks = []
    with open(path) as f:
        for line in f:
            p = line.strip().split("\t")
            peaks.append((p[0], int(p[1]), int(p[2])))
    return peaks


def overlaps(a, peaks_b):
    c, s, e = a
    return any(c == c2 and s < e2 and s2 < e for c2, s2, e2 in peaks_b)


rep1 = load_peaks(snakemake.input.rep1)
rep2 = load_peaks(snakemake.input.rep2)

rep1_in_rep2 = sum(1 for p in rep1 if overlaps(p, rep2))
rep2_in_rep1 = sum(1 for p in rep2 if overlaps(p, rep1))

rows = [
    {"replicate": "rep1", "n_peaks": len(rep1), "n_overlapping_other_rep": rep1_in_rep2,
     "pct_overlapping_other_rep": round(100 * rep1_in_rep2 / len(rep1), 1)},
    {"replicate": "rep2", "n_peaks": len(rep2), "n_overlapping_other_rep": rep2_in_rep1,
     "pct_overlapping_other_rep": round(100 * rep2_in_rep1 / len(rep2), 1)},
]

with open(snakemake.output[0], "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()), delimiter="\t")
    writer.writeheader()
    writer.writerows(rows)

for r in rows:
    print(f"{r['replicate']}: {r['n_peaks']} peaks, {r['pct_overlapping_other_rep']}% "
          f"overlap a peak in the other replicate")
