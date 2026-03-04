/* Inititate DSL2 */
nextflow.enable.dsl=2

/* Define the main processes */
process gather {

    publishDir "${params.results_dir}/05-${task.process.replaceAll(/.*:/, '')}/", mode:"symlink"

    input:
      path( gather_script )
      path( idx_channel )
      path( sum_channel )

    output:
        path "*", emit: results_gather

    script:
    """
    Rscript --vanilla *.R $idx_channel
    """

}

/* name a flow for easy import */
workflow GATHER {

 take:
    gather_script
    idx_channel
    sum_channel

 main:

    gather( gather_script, idx_channel, sum_channel )

  emit:
    gather.out[0]

}
