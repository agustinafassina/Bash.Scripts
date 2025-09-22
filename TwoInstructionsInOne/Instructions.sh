#!/bin/bash
#1- instruction
bash FirstInstruction.sh

#2- instruction
# Check if FirstInstruction.sh was executed correctly
if [ $? -eq 0 ]; then
    echo "2 - Instruction two"
fi