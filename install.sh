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
    printf "\t btop             Install btop config files\n"
    printf "\t kde              Install kde config files\n"
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
btop_param=false
kde_param=false

function echo_verbose() {
    if $verbose_mode
    then
        echo $1
    fi
}

function create_symbolic_links() {
    if $no_symlinks ; then
        echo_verbose "Skipping symbolic links creation"
    else
        echo "Creating symbolic links..."

        if $zsh_param ; then
            echo_verbose "Creating .zshrc symlink from ~/.zshrc to ~/dotfiles/zsh/.zshrc"
            ln -s ~/dotfiles/zsh/.zshrc ~/.zshrc
        else
            echo_verbose "Skipping zsh symlinks configuration"
        fi

        if $neofetch_param ; then
            echo_verbose "Creating neofetch symlink from ~/.config/neofetch/config.conf to ~/dotfiles/neofetch/config.conf"
            ln -s ~/dotfiles/neofetch/config.conf ~/.config/neofetch/config.conf
        else
            echo_verbose "Skipping neofetch symlink configuration"
        fi

        if $btop_param ; then
            echo_verbose "Creating btop symlink from ~/.config/btop/btop.conf to ~/dotfiles/btop/btop.conf"
            ln -s ~/dotfiles/btop/btop.conf ~/.config/btop/btop.conf
        else
            echo_verbose "Skipping btop symlink configuration"
        fi
        if $kde_param ; then
           echo_verbose "Creating kde symlinks"
           echo_verbose "Creating kdeglobals symlink from ~/.config/kdeglobals to ~/dotfiles/kde/kdeglobals"
	   ln -s ~/dotfiles/kde/kdeglobals ~/.config/kdeglobals
           echo_verbose "Creating kde shortcuts symlink from ~/.config/kglobalshortcutsrc to ~/dotfiles/kde/kglobalshortcutsrc"
           ln -s ~/dotfiles/kde/kglobalshortcutsrc ~/.config/kglobalshortcutsrc
           echo_verbose "Creating kde hotkeys symlink from ~/.config/khotkeysrc to ~/dotfiles/kde/khotkeysrc"
           ln -s ~/dotfiles/kde/khotkeysrc ~/.config/khotkeysrc
        else
           echo_verbose "Skipping kde symlink configuration"
        fi
    fi
}

function create_github_config() {
    if $no_git_creds ; then
        echo_verbose "Skipping github credientials configuration"
    else
        echo "Configuring github credientials"
        echo "Set github credentials email address & username"
        read git_creds_email -p "Email"
        read git_creds_user -p "Username"
        echo_verbose "Creating SSH key"
	ssh-keygen -t ed25519 -C $git_creds_email

        echo_verbose "Starting SSH agent and adding newly generated SSH key"
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519

        echo "Copy the following line and press ENTER to open Github Settings in a browser"
        cat ~/.ssh/id_ed25519.pub
        read -p "Press ENTER to continue to https://www.github.com/settings/ssh/new"
        echo_verbose "Opening github settings page in default browser"
        xdg-open "https://www.github.com/settings/ssh/new"	# xdg-open opens the default browser

        echo_verbose "Setting up git email and username in ~/.gitconfig"
        git config --global user.email $git_creds_email
        git config --global user.name $git_creds_user
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
printf "\tbtop:        $btop_param\n"
printf "\tkde:         $kde_param\n"
fi

return 0;
}




# ---------- MAIN ------------

# Get values of all parameters

# Options:
if [[ "$@" == *"--verbose"* ]] || [[ "$@" == *"-v"* ]] ; then
    verbose_mode=true
    echo $@
fi
if [[ "$@" == *"--help"* ]] || [[ "$@" == *"-h"* ]] ; then
    display_help=true
fi

if [[ "$@" == *"--no-symlinks"* ]] ; then
    no_symlinks=true
fi
if [[ "$@" == *"--no-git-creds"* ]] ; then
    no_git_creds=true
fi

# Parameters
if [[ "$@" == *"zsh"* ]] ; then
    zsh_param=true
    all_param=false
fi
if [[ "$@" == *"git"* ]] ; then
    git_param=true
    all_param=false
fi
if [[ "$@" == *"neofetch"* ]] ; then
    neofetch_param=true
    all_param=false
fi
if [[ "$@" == *"btop"* ]] ; then
    btop_param=true
    all_param=false
fi
if [[ "$@" == *"kde"* ]] ; then
    kde_param=true
    all_param=false
fi


if $all_param ; then
    zsh_param=true
    git_param=true
    neofetch_param=true
    btop_param=true
    kde_param=true
fi


# Call help function or start installation
if $display_help ; then
    show_usage
else
    display_parameters

    create_symbolic_links
    create_github_config
    echo "Enter source ~/.zshrc to configure zsh"
fi
