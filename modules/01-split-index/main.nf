/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process splitidx {

    publishDir "${params.results_dir}/01-${task.process.replaceAll(/.*:/, '')}/", mode:"symlink"

    input:
      path idx_channel
      path split_script

    output:
        path "*", emit: results_splitidx

    script:
    """
    bash $split_script $idx_channel
    """

}

/* name a flow for easy import */
workflow SPLITIDX {

 take:
    idx_channel
    split_script

 main:

    splitidx ( idx_channel, split_script ) 

  emit:
    splitidx.out[0]

}