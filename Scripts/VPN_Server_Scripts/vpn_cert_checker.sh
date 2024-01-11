#!/bin/bash
container_db="/root/Scripts/container_db.txt"
vpn_cert_db="/root/Scripts/vpn_cert_db.txt"

# Check if the correct number of arguments is supplied
if [ "$#" -ne 3 ]; then
    echo "You must enter exactly three arguments: project_name, role, and requested_by"
    exit 1
fi

# Convert arguments to lowercase
project_name=$(echo "$1" | tr '[:upper:]' '[:lower:]')
role=$(echo "$2" | tr '[:upper:]' '[:lower:]')
requested_by=$(echo "$3" | tr '[:upper:]' '[:lower:]')
cert_name="${project_name}-${role}"

md5_hash_project_name=$(echo -n "$project_name" | md5sum | awk '{ print $1 }')
containerName=$(grep "$md5_hash_project_name" "$container_db" | awk '{ print $3 }')
if [ "$containerName" == "" ]; then
    echo "The project does not exist!"
    exit 1
fi

#containerID=$(grep "$md5_hash_project_name" "$container_db" | awk '{ print $1 }')
networkID=$(grep "$md5_hash_project_name" "$container_db" | awk '{ print $5 }' | cut -d "." -f1-3)
addressID=$(($(cat "$vpn_cert_db" | grep "$md5_hash_project_name" | wc -l)+2))
IP_Address="$networkID.$addressID"

# Compute the MD5 hash of the string
md5_hash_total=$(echo -n "$cert_name" | md5sum | awk '{ print $1 }')

# Check if the MD5 hash already exists in DB_File.txt
if grep -q "$md5_hash_total" $vpn_cert_db; then
    echo "Error: An entry with the same $project_name and $role already exists!"
    exit 1
fi

# Get the current date
current_date=$(date +'%Y-%m-%d %H:%M:%S')

lxc exec "$containerName" -- bash -c "echo 'ifconfig-push $IP_Address 255.255.255.0' | tee /etc/openvpn/server/Project/ccd/$cert_name"

# Append the information to the vpn_cert_db.txt
printf "%-13s | %-32s | %-13s | %-15s | %-13s | %-32s | %-19s\n" "$project_name" "$md5_hash_project_name" "$role" "$IP_Address" "$requested_by" "$md5_hash_total" "$current_date" >> $vpn_cert_db

echo "Information stored successfully!"
