import os 
from snakemake.utils import min_version
from math import ceil
min_version("6.0")

configfile: "resonex_workflow/config.yaml"
base_dir = config["base_dir"]

# -------- ATLAS UTILIZATION ------------

# atlas-util directories and paths
dir_atlas_util = os.path.join(base_dir, config["paths"]["atlas_util"]) # general dir to run in
atlas_util_config_path = os.path.abspath(os.path.join("./atlas-utilization/", config["paths"]["atlas_util_config"])) # config for atlas-utilization code
events_output = os.path.join(base_dir, config["paths"]["parsed_data_output"]) # output dir for parsed events (step 1)

# Calculate how many jobs to submit for atlas-util
total_files = config["atlas_util_sub"]["total_files"]
files_per_job = config["atlas_util_sub"]["files_per_job"]
num_jobs = ceil(total_files / files_per_job) # TODO: might be a problem later if run on existing mode. 
batches = [i+1 for i in range(num_jobs)]

# --------- ANOMALY DETECTION ------------

parsed_data_path = os.path.join(dir_atlas_util, "parsed_data") # output dir 
if config["event_source"] == "existing":
    events_output_4AD = os.path.abspath(config["event_source_path"])
elif config["event_source"] == "new":
    events_output_4AD = events_output
else:
    raise ValueError("Invalid event_source specified in config.yaml: Must be 'existing' or 'new'")

# --------- BUMPNET ------------

dir_bumpnet = os.path.join(base_dir, "bumpnet")
module BumpNet:
    snakefile:
        "../BumpNet/snakemake/workflow/compare_predictions.smk"
    # config: # if not specified, uses it's own config.yaml - ok!
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

# create final output from BumpNet workflow
rule all:
    input:
        rules.bumpnet_all.input
    default_target: True
