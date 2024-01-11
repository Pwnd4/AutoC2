#!/bin/bash

name=$1

# Check if the name is empty
if [ -z "$name" ]; then
    echo "[-] Please enter a name for the operator as an argument!"
    echo "[!] Make sure that you have the password for signing the certificate with the OPS-CA!"
    exit
else
    echo "[+] Operator name:  $name"
    cd EasyRSA-3.1.5_Ops

    echo "[*] Creating the CSR for $name"
    echo ""
    echo "[*] Make sure to input a pass phrase with at least 4 characters!"

    ./easyrsa gen-req $name

    echo "[*] Copying $name.key to Ops-client-config/keys/"
    cp pki/private/$name.key ../Ops-client-configs/keys/

    cp pki/reqs/$name.req ../EasyRSA-3.1.5_Ops-CA/tmp/
    cd ../EasyRSA-3.1.5_Ops-CA

    echo "[*] Preparing $name.req to sign"
    ./easyrsa import-req tmp/$name.req $name

    echo "[*] Signing $name.req with Ops-CA"
    ./easyrsa sign-req client $name
    cp pki/issued/$name.crt ../Ops-client-configs/keys/
    cd ..

    echo "[*] Generating openvpn config file for $name"
    ./make_config.sh $name

    echo "[+] $name.ovpn successfully generated! Please don't forget to add a proper route(s) to the bottom of openvpn config file relate to project(s)!"
    echo "[+] Please find the config file in Ops-client-configs/files/$name.ovpn"
fi
