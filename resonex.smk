import os 
from snakemake.utils import min_version
min_version("6.0")

configfile: "resonex_workflow/config.yaml"
base_dir = config["base_dir"]

module BumpNet:
    snakefile:
        "/export/nfs0home/saumille/resonex/BumpNet/snakemake/workflow/compare_predictions.smk"
    # config: # if not specified, uses it's own config.yaml - ok!

use rule * from BumpNet as bumpnet_* 


rule all:
    # create final output from BumpNet workflow
    input:
        rules.bumpnet_all.input

# overwrite bumpnets smooth rule because we want an other input now!
rule smooth:
    input:
        # input_path="/DFS-L/DATA/whiteson/saumille/output_histcreation/atlas_full_fixComb_fixCut_20260919_113627/histograms/atlas_opendata_full_bumpnet.root",
        input_path= "/DFS-L/DATA/whiteson/saumille/output_histcreation/test.root"
    output:
        directory(f"{base_dir}/smoothed_hybrid/DM/{{sys}}"),
    shell:
        r"""
        python BumpNet/sample_generation/smooth.py \
            --config BumpNet/configs/analysis.yaml \
            --input_path {input.input_path} \
            --output_dir {output} \
            --smooth_method ""
        """
