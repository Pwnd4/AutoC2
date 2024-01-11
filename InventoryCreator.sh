#!/bin/bash

# Get the current directory assuming the script is run from the repo directory
repo_dir=$(pwd)

# List existing projects in the inventories directory
echo "Existing projects:"
for file in "$repo_dir"/inventories/*.yml; do
    filename=$(basename -- "$file")
    project_name="${filename%.*}"
    echo " - $project_name"
done

# Ask the user for inputs
read -rp "Enter the project name: " project_input
project_name=$(echo "$project_input" | tr '[:upper:]' '[:lower:]')

read -rp "Enter the group (e.g. TeamServer, Redirector, etc.): " group_input
group=$(echo "$group_input" | tr '[:upper:]' '[:lower:]')

read -rp "Enter the hostname or IP: " hostname_input
hostname=$(echo "$hostname_input" | tr '[:upper:]' '[:lower:]')

read -rp "Enter the ssh user: " ssh_user
read -rp "Enter the ssh port: " ssh_port

# Path to the inventory file
inventory_file="$repo_dir/inventories/${project_name}.yml"

# Confirmations for new project or group
if [[ ! -f "$inventory_file" ]]; then
    read -rp "The project $project_name does not exist, do you want to create it? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then exit 1; fi
fi

# If the inventory file doesn't exist, bypass the group existence check
if [[ ! -f "$inventory_file" ]]; then
    echo "The inventory file $inventory_file does not exist, it will be created."
else
    # Check and confirm if the group doesn't exist in the inventory file
    if ! grep -q "^    ${group}:" "$inventory_file"; then
        read -rp "The group $group does not exist, do you want to create it? (y/n): " confirm
        if [[ "$confirm" != "y" ]]; then exit 1; fi
    fi
fi

# Show the user what will be created and ask for confirmation
echo "This will be added to $inventory_file:"
echo "  $group:"
echo "    $hostname:"
echo "      ansible_ssh_user: $ssh_user"
echo "      ansible_port: $ssh_port"
read -rp "Do you agree? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then exit 1; fi

# Before adding the host, check if the inventory file exists
if [[ -f "$inventory_file" ]]; then
    # If the inventory file exists, check if the group exists and append the host to it
    if grep -q "^    ${group}:" "$inventory_file"; then
        # If group exists, append the host to it
        sed -i "/^    ${group}:/{N; s/\n      hosts:/\n      hosts:\n        ${hostname}:\n\ \ \ \ \ \ \ \ \ \ ansible_ssh_user: ${ssh_user}\n\ \ \ \ \ \ \ \ \ \ ansible_port: ${ssh_port}/;}" "$inventory_file"
    else
        # If group doesn't exist, add the group and the host to the end of the file
        echo -e "    ${group}:\n      hosts:\n        ${hostname}:\n          ansible_ssh_user: ${ssh_user}\n          ansible_port: ${ssh_port}" >> "$inventory_file"
    fi
else
    # If the inventory file doesn't exist, create it and add the group and host
    echo -e "all:\n  children:\n    ${group}:\n      hosts:\n        ${hostname}:\n          ansible_ssh_user: ${ssh_user}\n          ansible_port: ${ssh_port}" > "$inventory_file"
fi
