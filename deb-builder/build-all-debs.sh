#!/bin/bash

for file in ./products/*-config
do
  echo "Building deb for" $file
  ./build-deb.sh $file
done


