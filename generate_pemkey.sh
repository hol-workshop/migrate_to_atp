#!/bin/bash

function generate_key() {
  ssh-keygen -t rsa -N "" -b 2048 -f ~/.ssh/oci
}

function generate_private_api_key() {
  openssl genrsa -out ~/.ssh/oci_api_key.pem 2048
}

function generate_public_api_key() {
  openssl rsa -pubout -in ~/.ssh/oci_api_key.pem -out ~/.ssh/oci_api_key_public.pem
}

function generate_fingerprint() {
   openssl rsa -pubout -outform DER -in ~/.ssh/oci_api_key.pem | openssl md5 -c | awk '{print $2}' > ~/.ssh/oci_api_key.fingerprint
   echo "-----------------------------------------------"
   echo "  Now copy the below output as instructed"
   cat ~/.ssh/oci_api_key_public.pem
}

generate_key
sleep 3
generate_private_api_key
sleep 2
generate_public_api_key
sleep 1
generate_fingerprint
sleep 1
