#!/bin/bash

container_db="/root/Scripts/container_db.txt"

cat $container_db | grep $1 | awk -F "|" '{print $5}' | cut -d " " -f2
