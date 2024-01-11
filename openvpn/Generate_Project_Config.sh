#!/bin/bash

name=$1

# Check if the name is empty
if [ -z "$name" ]; then
    echo "[-] Please enter a name for the asset as an argument!"
    echo "[!] Make sure that you have the password for signing the certificate with the RTP-CA!"
    exit
else
    echo "[+] Asset name:  $name"
    cd EasyRSA-3.1.5_Projects

    echo "[*] Creating the CSR for $name"
    echo ""
    # echo "[*] Make sure to input a pass phrase with at least 4 characters!"

    ./easyrsa gen-req $name nopass

    echo "[*] Copying $name.key to Projects-client-config/keys/"
    cp pki/private/$name.key ../Projects-client-configs/keys/

    cp pki/reqs/$name.req ../EasyRSA-3.1.5_Projects-CA/tmp/
    cd ../EasyRSA-3.1.5_Projects-CA

    echo "[*] Preparing $name.req to sign"
    ./easyrsa import-req tmp/$name.req $name

    echo "[*] Signing $name.req with RTP-CA"
    ./easyrsa sign-req client $name
    cp pki/issued/$name.crt ../Projects-client-configs/keys/
    cd ..

    echo "[*] Generating openvpn config file for $name"
    ./make_config.sh $name

    echo "[+] $name.ovpn successfully generated!"
    echo "[+] Please find the config file in Projects-client-configs/files/$name.ovpn"
    echo "[!] Don't forget to adjust the port number of connecting openvpn server related to the project!"
fi
