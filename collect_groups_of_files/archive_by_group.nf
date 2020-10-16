// NXF_VER=20.07.1 nextflow run example.nf -c local.config

params.output_folder = 'outputs'
params.batchfile = 'manifests/manifest.csv'

Channel.from(file(params.batchfile))
    .splitCsv(header: true, sep: ",")
    .map { sample ->[sample.name, sample.group, file(sample.filename)] }
    .set{ input_channel }

process make_lowercase {

    tag "MAKE ALL LINES LOWERCASE"

	label "nolabel"
   
    memory '1 GB'
    
    cpus 1

    errorStrategy 'finish'
    
    input: 
    	set name, group, file(filename) from input_channel
    
    output: 
        //file("${filename}.lowercase.tsv") into output_channel
    	tuple val(group), file("${filename}.lowercase.tsv") into output_channel

    script:
    """
    make_lowercase.py ${filename}
    """
}



process tar_files_by_group {

    tag "COMNBINE FILES BY GROUP"
    
    label "nolabel"

    publishDir params.output_folder, mode: 'copy', overwrite: true
    
    memory '1 GB'
    
    cpus 1

    errorStrategy 'finish'
    
    input: 
        set val(group), file_list from output_channel.groupTuple()
    
    output: 
       file("${group}.tar.gz") into final_output_channel

    script:
    
    """
    mkdir ${group}
    for file in \$(echo ${file_list.join(' ')}); do mv "\$file" ${group}; done
    tar -czvf ${group}.tar.gz ${group}
    """
}

