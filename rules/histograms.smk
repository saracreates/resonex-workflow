LCG_SETUP = """
echo 'Setting up LCG environment...'
set +eu
export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
source $ATLAS_LOCAL_ROOT_BASE/user/atlasLocalSetup.sh --quiet
lsetup "views LCG_106a_ATLAS_1 x86_64-el9-gcc14-opt"
set -eu
"""

rule parse_data:
    input: atlas_util_config_path
    output: directory(events_output)
    container: None
    shell:
        r"""
        {LCG_SETUP}
        echo 'Parsing data...'
        cd atlas-utilization/
        python main.py --tasks parsing --run-dir {events_output} --config {input}
        """

rule masscalc_postproc:
    input: 
        data=parsed_data_path, 
        config=atlas_util_config_path,
    output: dir_atlas_util + "/im_arrays_processed/processed_batch_{n}.sqlite"
    container: None
    shell:
        r"""
        {LCG_SETUP}
        echo 'Atlas-util: mass calculation post-processing...'
        cd atlas-utilization/
        python main.py --tasks mass_calculating,post_processing --batch-job-index {wildcards.n} --total-batch-jobs {num_jobs} --run-dir {dir_atlas_util} --config {input.config}
        """
rule scan:
    input: 
        data=expand(dir_atlas_util + "/im_arrays_processed/processed_batch_{n}.sqlite", n=batches), 
        config=atlas_util_config_path,
    output: dir_atlas_util + "/logs/global_ranges.json"
    container: None
    shell:
        r"""
        {LCG_SETUP}
        echo 'Atlas-util: scanning...'
        cd atlas-utilization/
        python main.py 	--scan-only --run-dir {dir_atlas_util} --config {input.config}
        """
rule histograms:
    input: 
        data=dir_atlas_util + "/logs/global_ranges.json",
        config=atlas_util_config_path,
    output: temp(dir_atlas_util + "/histograms/batch_{n}.root") # temp = don't remake just because it's gone, it's an intermediate file
    container: None
    shell:
        r"""
        {LCG_SETUP}
        echo 'Atlas-util: generating histograms...'
        cd atlas-utilization/
        python main.py --tasks histogram_creation --batch-job-index {wildcards.n} --total-batch-jobs {num_jobs} --run-dir {dir_atlas_util} --config {input.config}
        """
rule merge:
    input: 
        data=expand(dir_atlas_util + "/histograms/batch_{n}.root", n=batches),
        config=atlas_util_config_path,
    output: dir_atlas_util + "/histograms/atlas_opendata_full_bumpnet.root"
    container: None
    shell:
        r"""
        {LCG_SETUP}
        echo 'Atlas-util: merging histograms...'
        cd atlas-utilization/
        python main.py --merge-only --run-dir {dir_atlas_util} --config {input.config}
        """
