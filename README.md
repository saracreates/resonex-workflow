# Resonex workflow

Runs: 

1) `atlas-utilization`: step 1: create event based outputs;
2) `anomaly_detection`: Reject normal events, keep anomalous ones;
3) `atlas-utilization`: step 2-5: create invariant mass histograms;
4) `BumpNet`: Run GPR and detect bumps.

using Snakemake. 
