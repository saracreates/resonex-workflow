import os 
from snakemake.utils import min_version
from math import ceil
import yaml
min_version("6.0")

resonex_workflow_yaml = "resonex_workflow/config.yaml"
configfile: resonex_workflow_yaml
base_dir = config["base_dir"]

# -------- ATLAS UTILIZATION ------------

# atlas-util directories and paths
dir_atlas_util = os.path.join(base_dir, config["paths"]["atlas_util"]) # general dir to run in
atlas_util_config_path = os.path.abspath(os.path.join("./atlas-utilization/", config["paths"]["atlas_util_config"])) # config for atlas-utilization code
events_output = os.path.join(base_dir, config["paths"]["parsed_data_output"]) # output dir for parsed events (step 1)

# Calculate how many jobs to submit for atlas-util
total_files = config["atlas_util_sub"]["total_files"]
files_per_job = config["atlas_util_sub"]["files_per_job"]
num_jobs = ceil(total_files / files_per_job) 
batches = [i+1 for i in range(num_jobs)]

# --------- ANOMALY DETECTION ------------

parsed_data_path = os.path.join(dir_atlas_util, "parsed_data") # output dir 
ad_method = config["anomaly_detection"]["method"]
# check which input files to use for AD (=event_output)
if config["event_source"] == "existing":
    events_output_4AD = os.path.abspath(config["event_source_path"])
    # get number of files in the existing event source path
    num_jobs = len([f for f in os.listdir(events_output_4AD + "/parsed_data/") if f.endswith('.root')])
    batches = [i+1 for i in range(num_jobs)]
elif config["event_source"] == "new":
    events_output_4AD = events_output
else:
    raise ValueError("Invalid event_source specified in config.yaml: Must be 'existing' or 'new'")

# --------- BUMPNET ------------

dir_bumpnet = os.path.join(base_dir, "bumpnet")

# load BumpNet config
with open("./BumpNet/configs/snakemake.yaml", "r") as f:
    bumpnet_config = yaml.safe_load(f)
    bumpnet_config["directory"] = dir_bumpnet # overwrite output dir
    bumpnet_config["container"] = config["bumpnet"]["container_path"] # overwrite container path
    bumpnet_config["dm_ckpt"] = config["bumpnet"]["bumpnet_model"] # overwrite model checkpoint path

# load and override BumpNet analysis config if specified
if "analysis_overrides" in config["bumpnet"]:
    with open(bumpnet_config["analysis_config"], "r") as f:
        bumpnet_analysis_config = yaml.safe_load(f)
    # only update those keys
    for key, values in config["bumpnet"]["analysis_overrides"].items():
        bumpnet_analysis_config[key].update(values)
    # save the updated analysis config to a new file
    os.makedirs(dir_bumpnet, exist_ok=True)
    analysis_config_path = os.path.join(dir_bumpnet, "analysis_overrides.yaml")
    with open(analysis_config_path, "w") as f:
        yaml.dump(bumpnet_analysis_config, f, sort_keys=False)
    bumpnet_config["analysis_config"] = analysis_config_path

module BumpNet:
    snakefile:
        "../BumpNet/snakemake/workflow/compare_predictions.smk"
    config: bumpnet_config
if config["mass_hist_source"] == "existing":
    hist_input = os.path.abspath(config["mass_hist_source_path"])
elif config["mass_hist_source"] == "new":
    hist_input = os.path.join(dir_atlas_util, "histograms/atlas_opendata_full_bumpnet.root")
else:
    raise ValueError("Invalid mass_hist_source specified in config.yaml: Must be 'existing' or 'new'")

# -------- RULES OF RESONEX WORKFLOW ------------

# use atlas-util rules
include: "rules/histograms.smk"

# use anomaly detection rules
include: "rules/anomaly.smk"

# use BumpNet rules - but with different input to 'smooth'
use rule * from BumpNet as bumpnet_*
use rule smooth from BumpNet as bumpnet_smooth with:
    input:
        input_path= hist_input

# copy config.yaml to the final output directory
rule copy_config:
    input: resonex_workflow_yaml
    output: os.path.join(base_dir, "config.yaml")
    shell:
        r"""
        cp {input} {output}
        """
# set which final plots to create
bumpnet_plots = [
    path for path in rules.bumpnet_all.input
    if any(f"/{variant}/" in path for variant in config["bumpnet"]["plot_variants"])
]

# create final output from BumpNet workflow
rule all:
    input:
        data=bumpnet_plots,
        config=f"{base_dir}/config.yaml"
    default_target: True

# which jobs to NOT run on cluster bc small
localrules: none, copy_config, all
