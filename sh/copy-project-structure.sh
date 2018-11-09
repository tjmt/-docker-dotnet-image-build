#!/bin/bash

echo "Copiando estrutra da pasta"

IFS=';' read -r -a array <<< $PATHS

for element in "${array[@]}"
do
    echo "$element"
done