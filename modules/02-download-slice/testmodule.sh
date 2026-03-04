#!/usr/bin/env bash
## This small script runs a module test with the sample data

# remove previous tests
# rm -rf .nextflow.log* work

# remove previous results
rm -rf test/results

# create a results dir
mkdir -p test/results

# run nf script
nextflow run testmodule.nf \
    --chr "chr1" \
    --start "25242393" \
    --end "25390445" \
    --genome "test/reference/GRCh38_full_analysis_set_plus_decoy_hla.fa" \
    -resume \
&& echo "[>>>] Module Test Successful" 
