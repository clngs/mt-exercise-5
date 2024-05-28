#!/bin/bash

# Check if correct number of arguments are provided
if [ "$#" -ne 5 ]; then
    echo "Usage: $0 <file1> <file2> <n> <output_file1> <output_file2>"
    exit 1
fi

# Assigning arguments to variables
file1="$1"
file2="$2"
n="$3"
output_file1="$4"
output_file2="$5"

# Count the number of lines in both files
lines_file1=$(wc -l < "$file1")
lines_file2=$(wc -l < "$file2")

# Check if files have the same number of lines
if [ "$lines_file1" -ne "$lines_file2" ]; then
    echo "Error: Files have different number of lines"
    exit 1
fi

# Check if n is greater than the number of lines
if [ "$n" -gt "$lines_file1" ]; then
    echo "Error: n is greater than the number of lines in the files"
    exit 1
fi

echo "Sampling $n lines from $file1 and $file2"
echo "Output files: $file1 >> $output_file1"
echo "Output files: $file2 >> $output_file2"

# Generate n random line numbers
shuf -i 1-"$lines_file1" -n "$n" | sort -n | while read -r line_num; do
    # Extract the corresponding lines from both files
    line_file1=$(sed -n "${line_num}p" "$file1")
    line_file2=$(sed -n "${line_num}p" "$file2")
    echo "$line_file1" >> "$output_file1"
    echo "$line_file2" >> "$output_file2"
done

echo "Done"