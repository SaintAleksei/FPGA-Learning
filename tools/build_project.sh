#!/usr/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <name_of_project>"
    exit 1
fi

cd projects/$1 && quartus_sh --flow compile de2_115
