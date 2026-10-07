
rule none:
    input: events_output_4AD
    output: directory(parsed_data_path)
    shell:
        r"""
        echo 'Creating symlink of files in {input} to {output}'
        mkdir -p {output}
        ln -s {input}/parsed_data/* {output}/
        """
