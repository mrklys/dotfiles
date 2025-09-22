#!/bin/bash

linkFolder() {
    for file in $(find $1 -type f); do
        [ ! -d "$(dirname "../../../$file")" ] && mkdir -p "$(dirname "../../../$file")"
        ln -svf "$(pwd)/$file" "../../../$file"
    done
}

# Check PWD
if [[ $PWD = */home/*/.local/share/dotfiles ]]; then
    # Link .bashrc
    ln -svf "$(pwd)/.bashrc" "../../../.bashrc"
    # Link .config
    linkFolder .config
    # Link .local
    linkFolder .local

    echo "Successfully linked"
else
    echo "ERROR: dotfiles should be located in ~/.local/share/dotfiles"
fi
