#!/usr/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <new_project_name>:"
    exit 1
fi

cp -r example/ $1
