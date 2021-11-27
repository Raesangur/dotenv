#!/bin/bash

function show_usage() {
    printf "Usage: $0 [option]... parameter... [extra_option]... \n"
    printf "\n"
    printf "\tOptions: \n"
    printf "\t -v | --verbose   Display more informations during execution\n"
    printf "\t -h | --help      Display this menu\n"
    printf "\t -p | --path      Change path (~/dotfiles assumed)\n"
    printf "\n"
    printf "\tParameters: \n"
    printf "\tIf no parameters are specified, all tools are setup\n"
    printf "\t -zsh             Install zsh config files\n"
    printf "\t -git             Install git config files and setup credientials on system\n"
    printf "\t -neofetch        Install neofetch config files\n"
    printf "\tExtra Options: \n"
    printf "\t --no-symlinks    Skip configuration of symbolic links\n"
    printf "\t --no-git-creds   Skip configuration of git credentials\n"

    return 0;
}

# Options
display_help=false
verbose_mode=false
path="~/dotfiles"

# Extra Options
no_symlinks=false
no_git_creds=false

# Parameters
zsh=true
git=true
neofetch=true


function create_symbolic_links() {
    echo "Creating symbolic links..."
    ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc
    ln -s ~/dotfiles/neofetch/config.conf ~/.config/neofetch/config.conf
}

function display_parameters() {
if $verbose_mode; 
then

printf "Verbose mode, options and parameters:\n"
printf "\tHelp:        $display_help\n"
printf "\tVerbose:     $verbose_mode\n"
printf "\tPath:        $path\n"
printf "\t-----\n"
printf "\tno-symlinks: $no_symlinks\n"
printf "\tno-git-creds:$no_git_creds\n"
printf "\t-----\n"
printf "\tzsh:         $zsh\n"
printf "\tgit:         $git\n"
printf "\tneofetch:    $neofetch\n"
fi

return 0;
}




# ---------- MAIN ------------

# Get values of all parameters

# Fetch all arguments
if [[ "$@" == *"--verbose"* ]] || [[ "$@" == *"-v"* ]]
then
    verbose_mode=true
fi

if [[ "$@" == *"--help"* ]] || [[ "$@" == *"-h"* ]]
then
    display_help=true
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
