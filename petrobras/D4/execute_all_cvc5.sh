#!/bin/bash

# Current directory
cwd=$(pwd)
cwd+="/*"

# Output table file
OUTPUT_TABLE="output_table.txt"

# Function to execute a file and store its output in the table
execute_file() {
    local file="$1"
    local ack="$2"
    if [ "$2" = "0" ]; then
      #local output=$(time cvc5 "$file")
      local result=$( { time cvc5 "$file"; } 2>&1 )
      local output=$(echo "$result" | grep real | awk '{print $2}')
      local time=$(echo "$result" | grep sat | awk '{print $1}')
      local ackermann="Yes"
    else
      #local output=$(time cvc5 --no-ackermann "$file")
      local result=$( { time cvc5 --no-ackermann "$file"; } 2>&1 )
      local output=$(echo "$result" | grep real | awk '{print $2}')
      local time=$(echo "$result" | grep sat | awk '{print $1}')
      local ackermann="No"
    fi
    echo "$file | $output | $time | $ackermann" >> "$OUTPUT_TABLE"
}

# Main execution
echo "File | Time | Result | Ackermann" > "$OUTPUT_TABLE"
for file in $cwd; do
  echo "$file"
    if [ -f "$file" ]; then
        execute_file "$file" "0"
        execute_file "$file" "1"
    fi
  echo "" >> "$OUTPUT_TABLE"
done

echo "Execution completed. Output saved in $OUTPUT_TABLE"
