#!/bin/bash

# Script to update GitHub Actions secrets with AWS Credentials

declare -A secrets

while IFS= read -r line; do
  if [[ $line == '[default]' ]]; then
    continue
  fi

  IFS='='
  read -r -a array <<<"$line"
  key=${array[0]^^}
  value=${array[1]}

  secrets[$key]=$value
done <~/.aws/credentials

for key in "${!secrets[@]}"; do
  gh secret set $key -b ${secrets[$key]}
done
