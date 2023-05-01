#!/bin/bash

# list of file extensions to keep
keep_ext=("v" "sh" "qpf" "qsf" "py")

# list of files to exclude
exclude_files=(".gitignore" "README.md" "TODO.txt")

# list of directories to exclude
exclude_dirs=(".git" "playground" "vpi" "font")

# function to check if a file should be deleted
should_delete() {
    local file="$1"
    local ext="${file##*.}"
    if [[ -f "$file" && ! " ${keep_ext[@]} " =~ " $ext " ]]; then
        return 0
    else
        return 1
    fi
}

# function to delete files recursively
delete_files() {
    local dir="$1"
    local exclude_args=""
    for item in "${exclude_files[@]}"; do
        exclude_args+=" ! -path \"$dir/$item\""
    done
    for item in "${exclude_dirs[@]}"; do
        exclude_args+=" ! -path \"$dir/$item/*\" ! -path \"$dir/$item\""
    done
    eval find "$dir" -type f $exclude_args -print0 | while read -d $'\0' file; do
        if should_delete "$file"; then
            echo "Delete file: $file"
            rm "$file"
        fi
    done
    # delete empty directories
    eval find "$dir" -type d -empty $exclude_args | while read dir; do
      echo "Delete dir: $dir"
      rmdir "$dir"
    done
}

# run the script on each directory specified
for dir in "."; do
    delete_files "$dir"
done

