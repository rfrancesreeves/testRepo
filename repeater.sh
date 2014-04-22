#!/bin/bash


for i in {1..10000}
do
     cat json.txt >> json_big.txt
     echo "Welcome $i times"
     git commit -a -m 'add big_json'
done




