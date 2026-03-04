#!/bin/bash

# RHD 5' coordinate: 25302393
# RHD 3' coordinate: 25360445
# sample example url: https://ftp.sra.ebi.ac.uk/vol1/run/ERR324/ERR3241661/HG00380.final.cram

chr="$1"
start="$2"
end="$3"
url="$4"
ref="$5"

samtools view -b \
  -T $ref \
  "$url" \
  "$chr:"$start"-"$end > "$(basename $url .final.cram)"_subset.bam

samtools index "$(basename $url .final.cram)"_subset.bam

rm *.crai

# Rscript --vanilla plot_cov.R results/"$(basename $url .final.cram)"_subset.bam
