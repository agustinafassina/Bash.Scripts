#!/bin/bash
#1- instruction
#jupyter execute notebook.ipynb
bash FirstInstruction.sh

#2- instruction
# Verificar si se ejecutó correctamente el index.sh
if [ $? -eq 0 ]; then
    echo "2 - Instruction two"
fi