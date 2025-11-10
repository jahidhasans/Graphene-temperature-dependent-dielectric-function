#!/bin/bash

folder="alpha_1200K"
#folder="./"
expected_total=729

missing_count=0
empty_count=0
found_count=0

echo "Checking folder: $folder"
echo "------------------------------------"

# Loop through expected files
for i in $(seq 1 $expected_total); do
    file="$folder/q${i}"

    if [ -f "$file" ]; then
        ((found_count++))

        if [ ! -s "$file" ]; then
            echo "File q${i} is empty"
            ((empty_count++))
        fi
    else
        echo "File q${i} is missing"
        ((missing_count++))
    fi
done

# Print summary
echo "------------------------------------"
echo "Total expected files     : $expected_total"
echo "Total files found        : $found_count"
echo "Total missing files      : $missing_count"
echo "Total empty files        : $empty_count"
echo "------------------------------------"
