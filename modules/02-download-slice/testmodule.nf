/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { DWBAM }    from './main.nf'

/* declare input channel for testing */
    Channel
        .fromPath( "test/data/*.txt" )
//	.view( )
        .set { link_channel }

/* declare scripts channel for testing */
NONE

workflow {
  DWBAM( link_channel )
}
