#!/usr/bin/env bash
## This small script runs a module test with the sample data

# remove previous tests
rm -rf .nextflow.log* work

# remove previous results
rm -rf test/results

# create a results dir
mkdir -p test/results

# run nf script
nextflow run testmodule.nf \
    --sample_list "test/data/1000G_2504_high_coverage.sequence.index" \
&& echo "[>>>] Module Test Successful" 
