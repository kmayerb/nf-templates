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
    	tuple val(group),  val(name), file("${filename}.lowercase.tsv") into output_channel

    script:
    """
    make_lowercase.py ${filename}
    """
}

// Consider the value of sorting
//output_channel.groupTuple(sort: { it[1]} ).view()
//output_channel.groupTuple().view()

process combine_files_by_group {

    tag "WORK ON GROUPS OF FILES WITH PYTHON"
    
    label "nolabel"

    publishDir params.output_folder, mode: 'copy', overwrite: true
    
    memory '1 GB'
    
    cpus 1

    errorStrategy 'finish'
    
    input: 
        set val(group), val(name), file_list from output_channel.groupTuple(sort: { it[1]} )
    
    output: 
       file("${group}.tsv") into final_output_channel

    script:
    """
    concat.py ${file_list.join(' ')} > ${group}.tsv
    """
}
