/* Inititate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { SPLITIDX }    from './main.nf'

/* declare input channel for testing */
    Channel
        .fromPath( "${params.sample_list}" )
//	.view( )
        .set { idx_channel }

/* declare scripts channel for testing */
split_script = Channel.fromPath( "scripts/01-splitlines.sh" )

workflow {
  SPLITIDX( idx_channel, split_script )
}