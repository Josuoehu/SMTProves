#!/bin/bash

# Current directory
cwd=$(pwd)
cwd+="/${1}/"

# Output table file
OUTPUT_TABLE="output_table.txt"

# Function to execute a file and store its output in the table
execute_file() {
    local file="$1"
    local ack="$2"
    local solver="$3"
    short_file=$(echo "$file" | sed 's/\/home[\/a-zA-Z0-9_\.]*\/SMTProves\/[^\/]*//g')
    if [ "$solver" = "Z3" ]; then
      if [ "$ack" = "0" ]; then
        # Execute with Z3
        local result=$( { time z3 "$file"; } 2>&1 )
        #local output=$(echo "$result" | grep real | awk '{print $2}')
        #local time=$(echo "$result" | grep sat | awk '{print $1}')
        local ackermann="Yes"
      else
        #local output=$(time cvc5 --no-ackermann "$file")
        local result=$( { time z3 ackermannization.eager=false "$file"; } 2>&1 )
        #local output=$(echo "$result" | grep real | awk '{print $2}')
        #local time=$(echo "$result" | grep sat | awk '{print $1}')
        local ackermann="No"
      fi
    elif [ "$solver" = "mathSAT" ]; then
      if [ "$ack" = "0" ]; then
      #local output=$(time cvc5 "$file")
        local result=$( { time mathsat "$file"; } 2>&1 )
        #local output=$(echo "$result" | grep real | awk '{print $2}')
        #local time=$(echo "$result" | grep sat | awk '{print $1}')
        local ackermann="Yes"
      else
        #local output=$(time cvc5 --no-ackermann "$file")
        local result=$( { time mathsat -theory.euf.dyn_ack=0 "$file"; } 2>&1 )
        #local output=$(echo "$result" | grep real | awk '{print $2}')
        #local time=$(echo "$result" | grep sat | awk '{print $1}')
        local ackermann="No"
      fi
    elif [ "$solver" = "cvc5" ]; then
      if [ "$ack" = "0" ]; then
        #local output=$(time cvc5 "$file")
        local result=$( { time cvc5 "$file"; } 2>&1 )
        #local output=$(echo "$result" | grep real | awk '{print $2}')
        #local time=$(echo "$result" | grep sat | awk '{print $1}')
        local ackermann="Yes"
      else
        #local output=$(time cvc5 --no-ackermann "$file")
        local result=$( { time cvc5 --no-ackermann "$file"; } 2>&1 )
        #local output=$(echo "$result" | grep real | awk '{print $2}')
        #local time=$(echo "$result" | grep sat | awk '{print $1}')
        local ackermann="No"
      fi
    else
      echo "The file does not exist, try again"
    fi
    local output=$(echo "$result" | grep real | awk '{print $2}')
    local time=$(echo "$result" | grep sat | awk '{print $1}')
    echo -e "$short_file\t$output\t$solver\t$time\t$ackermann" >> "$OUTPUT_TABLE"
}

# Main execution
echo -e "File\tResult\tSolver\tTime\tAckermann" > "$OUTPUT_TABLE"
for folder in "$cwd"*; do
  if [ -d "$folder" ]; then
    for file in "$folder"/*; do
      #echo "$file"
      short_file=$(echo "$file" | sed 's/\/home[\/a-zA-Z0-9_\.]*\/SMTProves\/[^\/]*//g')
      echo "$short_file"
        if [ -f "$file" ]; then
          execute_file "$file" "0" "Z3"
          execute_file "$file" "1" "Z3"
          execute_file "$file" "0" "cvc5"
          execute_file "$file" "1" "cvc5"
          execute_file "$file" "0" "mathSAT"
          execute_file "$file" "1" "mathSAT"
        fi
      echo "" >> "$OUTPUT_TABLE"
    done
  fi
done 

echo "Execution completed. Output saved in $OUTPUT_TABLE"
