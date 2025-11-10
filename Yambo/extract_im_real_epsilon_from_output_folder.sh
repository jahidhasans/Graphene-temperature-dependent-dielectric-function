#!/bin/bash

# Output files
imag_output="imag_eps_matrix.dat"
real_output="real_eps_matrix.dat"
energy_output="energy_values.dat" 

# Temporary files to store column data
temp_dir="./temp_columns"
mkdir -p $temp_dir

# Loop through files q1 to q729
for i in {1..729}; do
    file="eps_750K_harmonic/q$i"   #change the folder name
    
    if [[ -f "$file" ]]; then
        awk '$1 ~ /^[0-9.+-eE]+$/ && $2 ~ /^[0-9.+-eE]+$/ && $3 ~ /^[0-9.+-eE]+$/ {print $2}' "$file" > "$temp_dir/imag_$i.tmp"
        awk '$1 ~ /^[0-9.+-eE]+$/ && $2 ~ /^[0-9.+-eE]+$/ && $3 ~ /^[0-9.+-eE]+$/ {print $3}' "$file" > "$temp_dir/real_$i.tmp"
    else
        echo "Warning: $file not found, skipping..."
    fi
done

# Extract energy values from first valid file (e.g., q1) and save as row
awk '$1 ~ /^[0-9.+-eE]+$/ && $2 ~ /^[0-9.+-eE]+$/ && $3 ~ /^[0-9.+-eE]+$/ {print $1}' "eps_750K_harmonic/q1" > "$energy_output"   #change the folder name
echo "" >> "$energy_output"  # Add newline at the end
# Initialize empty output files
> "$imag_output"
> "$real_output"

# Use paste one file at a time to build output safely
for i in {1..729}; do
    imag_col="$temp_dir/imag_$i.tmp"
    real_col="$temp_dir/real_$i.tmp"
    
    if [[ -f "$imag_col" && -f "$real_col" ]]; then
        if [[ $i -eq 1 ]]; then
            cp "$imag_col" "$imag_output"
            cp "$real_col" "$real_output"
        else
            paste "$imag_output" "$imag_col" > "$imag_output.tmp" && mv "$imag_output.tmp" "$imag_output"
            paste "$real_output" "$real_col" > "$real_output.tmp" && mv "$real_output.tmp" "$real_output"
        fi
    fi
done

# Cleanup
rm -r "$temp_dir"

echo " Done: Imag alpha  $imag_output | Real alpha  $real_output | Energy (eV)  $energy_output"
