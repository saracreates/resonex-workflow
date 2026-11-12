
if ad_method == "none":
    rule none:
        input: events_output_4AD
        output: directory(parsed_data_path)
        container: None
        shell:
            r"""
            echo 'Creating symlink of files in {input} to {output}'
            mkdir -p {output}
            ln -s {input}/parsed_data/* {output}/
            """
if ad_method == "dummycut":
    rule dummycut:
        input: events_output_4AD
        output: directory(parsed_data_path)
        container: None
        shell:
            r"""
            {LCG_SETUP}
            echo 'Performing dummy AD cut on {input} to create {output}'
            mkdir -p {output}
            cd anomaly_detection
            python select_anomalous_events.py --input {input}/parsed_data/ --output {output}
        """
