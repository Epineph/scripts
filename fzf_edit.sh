#!/bin/bash

function fzf_edit() {
    local bat_style='--color=always --line-range :500'
    if [[ $1 == "no_line_number" ]]; then
        bat_style+=' --style=grid'
    fi

    local file
    file=$(fd --type f | fzf --preview "bat $bat_style {}" --preview-window=right:60%:wrap)
    if [[ -n $file ]]; then
        sudo nvim "$file"
    fi
}

fzf_edit

