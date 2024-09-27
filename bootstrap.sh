#! /bin/bash

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <server|client>"
    exit 1
fi

if [[ $1 == "server" ]]; then
  ansible-playbook -i ./hosts.yaml ./server.yaml --ask-become-pass --ask-pass
elif [[ $1 == "client" ]]; then
  ansible-playbook -i ./hosts.yaml ./client.yaml --ask-become-pass --ask-pass
else
  echo "Usage: $0 <server|client>"
  exit 1
fi