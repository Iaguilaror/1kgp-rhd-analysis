/* Initiate DSL2 */
nextflow.enable.dsl=2

/* load functions for testing env */
// NONE

/* define the fullpath for the final location of the outs */
params.intermediates_dir = params.results_dir = "test/results"

/* load workflows for testing env */
include { DESCRIBE }    from './main.nf'

/* declare input channel for testing */
    Channel
        .fromPath( "test/cnv_1kgp/all_covratio.tsv" )
//	.view( )
        .set { cnv_channel }

/* declare input channel for testing */
    Channel
        .fromPath( "test/snv_1kgp/1kgp_RHD_500kb_upanddown_window_gts_unrelated.tsv.gz" )
//	.view( )
        .set { snv_channel }

/* declare input channel for testing */
    Channel
        .fromPath( "test/reference/1kgp_samplepops.tsv" )
//	.view( )
        .set { ref_channel }


/* declare scripts channel for testing */
marker_script = Channel.fromPath( "scripts/06-describe.R" )

workflow {
  DESCRIBE( marker_script, cnv_channel, snv_channel, ref_channel )
}
