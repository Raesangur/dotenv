#!/bin/bash

function show_usage() {
    printf "Usage: $0 [option]... parameter... [extra_option]... \n"
    printf "\n"
    printf "\tOptions: \n"
    printf "\t -v | --verbose   Display more informations during execution\n"
    printf "\t -h | --help      Display this menu\n"
    printf "\n"
    printf "\tParameters: \n"
    printf "\tIf no parameters are specified, all tools are setup\n"
    printf "\t zsh              Install zsh config files\n"
    printf "\t git              Install git config files and setup credientials on system\n"
    printf "\t neofetch         Install neofetch config files\n"
    printf "\tExtra Options: \n"
    printf "\t --no-symlinks    Skip configuration of symbolic links\n"
    printf "\t --no-git-creds   Skip configuration of git credentials\n"

    return 0;
}

# Options
display_help=false
verbose_mode=false

# Extra Options
no_symlinks=false
no_git_creds=false

# Parameters
all_param=true
zsh_param=false
git_param=false
neofetch_param=false


function create_symbolic_links() {
    if $no_symlinks
    then
        if $verbose_mode
        then
            echo "Skipping symbolic links creation"
        fi
    else
        echo "Creating symbolic links..."

        if $verbose_mode
        then
            echo "Creating .zshrc symlink from ~/.zshrc to ~/dotfiles/zsh/.zshrc"
        fi
        ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc

        if $verbose_mode
        then
            echo "Creating neofetch symlink from ~/.config/neofetch/config.conf to ~/dotfiles/neofetch/config.conf"
        fi
        ln -s ~/dotfiles/neofetch/config.conf ~/.config/neofetch/config.conf
    fi
}

function display_parameters() {
if $verbose_mode; 
then

printf "Verbose mode, options and parameters:\n"
printf "\tHelp:        $display_help\n"
printf "\tVerbose:     $verbose_mode\n"
printf "\t-----\n"
printf "\tno-symlinks: $no_symlinks\n"
printf "\tno-git-creds:$no_git_creds\n"
printf "\t-----\n"
printf "\tzsh:         $zsh_param\n"
printf "\tgit:         $git_param\n"
printf "\tneofetch:    $neofetch_param\n"
fi

return 0;
}




# ---------- MAIN ------------

# Get values of all parameters

# Options:
if [[ "$@" == *"--verbose"* ]] || [[ "$@" == *"-v"* ]]
then
    verbose_mode=true
fi
if [[ "$@" == *"--help"* ]] || [[ "$@" == *"-h"* ]]
then
    display_help=true
fi

if [[ "$@" == *"--no-symlinks"* ]]
then
    no_symlinks=true
fi
if [[ "$@" == *"--no-git-creds"* ]]
then
    no_git_creds=true
fi

# Parameters
if [[ "$@" == *"zsh"* ]]
then
    zsh_param=true
    all_param=false
fi
if [[ "$@" == *"git"* ]]
then
    git_param=true
    all_param=false
fi
if [[ "$@" == *"neofetch"* ]]
then
    neofetch_param=true
    all_param=false
fi


if $all_param
then
    zsh_param=true
    git_param=true
    neofetch_param=true
fi


# Call help function or start installation
if $display_help;
then
    show_usage
else
    display_parameters

    create_symbolic_links
    echo "Enter source ~/.zshrc to configure zsh"
fi
