#!/bin/sh

for i in $(ls ../install/*.64); do 
name=$(echo "$i" | sed 's/.*\///')
base64=$(cat $i)
echo "name: $name"
sed -i "s/$name/$base64/g" ./var.tfvars.json
done