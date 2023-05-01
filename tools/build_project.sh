#!/usr/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <path/to/project/dir>:"
    exit 1
fi

cd $1 && quartus_sh --flow compile de2_115