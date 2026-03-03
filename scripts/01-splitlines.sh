#!/bin/bash
grep -v "#" "$1" \
    | cut -f1 \
    | split \
        -l 1 \
        -d \
        --additional-suffix=.txt - "sample_"
