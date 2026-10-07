# Resonex workflow

Runs: 

1) `atlas-utilization`: step 1: create event based outputs;
2) `anomaly_detection`: Reject normal events, keep anomalous ones;
3) `atlas-utilization`: step 2-5: create invariant mass histograms;
4) `BumpNet`: Run GPR and detect bumps.

using Snakemake. 

# Usage

Create snakemake env (once):

```
conda create --name snakemake python=3.12
conda activate snakemake

pip install pulp==2.6.0                       # scheduler dependency, pinned for compatibility
pip install snakemake                         # tested with 9.21.0
pip install snakemake-executor-plugin-slurm   # only needed for cluster runs (--profile)
conda install -c conda-forge graphviz         # optional: DAG plots via `snakemake --dag | dot -Tpng > dag.png`
```

Currently only the local setup works: 

```
# from the parent folder run:
conda activate snakemake
snakemake -s resonex_workflow/resonex.smk
```

# Set-up of repositories

Install 
- [BumpNet](https://gitlab.cern.ch/saaumill/resonex-built-from-bump-net/-/tree/smoothing_prediction?ref_type=heads) - `smoothing_predictions` branch
- [atlas-utilization](https://github.com/saracreates/atlas-utilization/tree/resonex-dataprep) - `resonex-dataprep` branch
- [anomaly_detection](https://github.com/saracreates/anomaly-detection)
- resonex_workflow (this repo)

next to each other in the same folder. 
