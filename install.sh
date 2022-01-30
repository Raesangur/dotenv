#!/bin/bash

function show_usage() {
    printf "Usage: $0 [option]... parameter... [extra_option]... \n"
    printf "\n"
    printf "\tOptions: \n"
    printf "\t -v | --verbose   Display more informations during execution\n"
    printf "\t -d | --debug     Display even more debug information during execution\n"
    printf "\t -h | --help      Display this menu\n"
    printf "\n"
    printf "\tParameters: \n"
    printf "\tIf no parameters are specified, none of these tools are setup\n"
    printf "\t zsh              Install zsh config files\n"
    printf "\t git              Install git config files and setup credientials on system\n"
    printf "\t neofetch         Install neofetch config files\n"
    printf "\t btop             Install btop config files\n"
    printf "\t kde              Install kde config files\n"
    printf "\t terminology      Install terminology config files\n"
    printf "\t python           Setup python links in /bin\n"
    printf "\t micro            Install micro config files\n"
    printf "\tExtra Options: \n"
    printf "\t --links          Configuration of links (symbolic links, subrepositories etc.)\n"
    printf "\t --git-creds      Configuration of git credentials\n"
    printf "\t --packages       Installation of apt, brew, snap and pip packages, along with other software\n"
    printf "\t --apt-packages   Installation of apt packages\n"
    printf "\t --brew-packages  Installation of brew and brew packages\n"
    printf "\t --snap-packages  Installation of snap and snap packages\n"
    printf "\t --pip-packages   Installation of pip packages\n"
    printf "\t --other-packages Installation of other packages and software\n"
    printf "\t --apt-necessary  Install only necessary apt packages\n"
    printf "\t --apt-extra      Install some extra apt packages\n"
    return 0;
}

# Options
display_help=false
verbose_mode=false
debug_mode=false

# Extra Options
no_links=true
no_git_creds=true
no_apt=true
no_brew=true
no_snap=true
no_pip=true
no_other=true
apt_necessary=false
apt_extra=false

secret_git_param=false

# Parameters
zsh_param=false
git_param=false
neofetch_param=false
btop_param=false
kde_param=false
terminology_param=false
python_param=false
micro_param=false

function echo_verbose() {
    if $verbose_mode ; then
        echo $1
    fi
}

function echo_debug() {
    if $debug_mode ; then
        echo $1
    fi
}

function make_dir() {
    if $debug_mode ; then
        echo "Trying to create $1 directory"
        mkdir $1
    else
        mkdir $1 > /dev/null
    fi
}

function create_subrepo() {
    if [ ! -d "$1" ] || [ ! -d "$1/.git" ] ; then
        echo_verbose "subrepository is not yet configured, downloading"
        git submodule update --init --recursive "$1"
    fi
}

function create_symbolic_link() {
    echo_verbose "Creating $3 symlink from $1 to $2"
    if test -f "$1" ; then
        echo_verbose "File already exists, replacing"
        rm $1
    fi
    ln -s $2 $1
}

function create_links() {
    if $no_links ; then
       echo_verbose "Skipping links creation"
    else
        echo "Creating links..."

        if $zsh_param ; then
            create_subrepo       zsh
            create_symbolic_link ~/.zshrc ~/dotfiles/zsh/.zshrc ".zshrc"
            git clone            https://www.github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
        else
            echo_verbose "Skipping zsh symlinks configuration"
        fi

        if $neofetch_param ; then
            create_subrepo       neofetch
            make_dir             ~/.config/neofetch
            create_symbolic_link ~/.config/neofetch/config.conf ~/dotfiles/neofetch/config.conf "neofetch"
        else
            echo_verbose "Skipping neofetch symlink configuration"
        fi

        if $btop_param ; then
            create_subrepo       btop
            make_dir             ~/.config/btop
            create_symbolic_link ~/.config/btop/btop.conf ~/dotfiles/btop/btop.conf "btop"
        else
            echo_verbose "Skipping btop symlink configuration"
        fi

        if $kde_param ; then
           create_subrepo       kde
           create_symbolic_link ~/.config/kdeglobals         ~/dotfiles/kde/kdeglobals         "kdeglobals"
           create_symbolic_link ~/.config/kglobalshortcutsrc ~/dotfiles/kde/kglobalshortcutsrc "kde shortcuts"
           create_symbolic_link ~/.config/khotkeysrc         ~/dotfiles/kde/khotkeysrc         "kde hotkeys"
           create_symbolic_link ~/.local/plasma              ~/dotfiles/kde/plasma             "kde look and feel (icons, wallpapers, extensions)"
        else
           echo_verbose "Skipping kde symlink configuration"
        fi

        if $terminology_param ; then
            create_subrepo terminology
        else
            echo_verbose "Skipping terminology configuration"
        fi

        if $python_param ; then
           echo_verbose "Creating python alternative link to python3 with python"
           if test -f /bin/python ; then
               echo_verbose "/bin/python already exists"
           else
               if test -f /bin/python3 ; then
                   echo_verbose "Creating alternative link to /bin/python3"
                   update-alternatives --install /bin/python python /bin/python3 10
               else
                   echo_verbose "/bin/python3 not found, alternative link not created"
               fi
           fi
        else
           echo_verbose "Skipping python3 link configuration"
        fi

	if $micro_param ; then
            create_subrepo       micro
	    make_dir             ~/.config/micro
	    create_symbolic_link ~/.config/micro/bindings.json ~/dotfiles/micro/bindings.json "micro keybinds"
            create_symbolic_link ~/.config/micro/settings.json ~/dotfiles/micro/settings.json "micro settings"
	else
	    echo_verbose "Skipping micro configuration"
	fi
    fi
}

function create_github_config() {
    if $no_git_creds ; then
        echo_verbose "Skipping github credientials configuration"
    else
        if test -f ~/.ssh/id_ed25519 ; then
            echo "Git credentials seem to be already setup (file ~/.ssh/id_ed25519 exists)"
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

	        echo "Press [ENTER] to continue"
	        pause
        fi
    fi

    if $git_param ; then
        if [[ `cat ~/dotfiles/.git/config | grep url | head -n 1` =~ .*[[:space:]][A-Za-z0-9_\-]+@[A-Za-z0-9_\-]+.[A-Za-z0-9_\-]+:[A-Za-z0-9_\-]+\/[A-Za-z0-9_\-]+ ]] ; then
            echo_verbose "github dotfile repo is properly configured with ssh"
        else
            echo_verbose "github dotfile repo is not properly configured with ssh, downloading the repo properly"

            if $debug_mode ; then
                ~/dotfiles/git/git_clone.sh Raesangur/dotfiles.git ~/dotfiles2
            else
                ~/dotfiles/git/git_clone.sh Raesangur/dotfiles.git ~/dotfiles2 >/dev/null
            fi

            eval "cd ; sleep 2; rm -rf ~/dotfiles ; mv ~/dotfiles2 ~/dotfiles ; chmod +x ~/dotfiles/install.sh ; eval ~/dotfiles/install.sh ${@} --secret_git_param_" & disown
            echo_verbose "restarting installation script"
            exit 0
        fi
    else
        echo_verbose "Skipping github dotfile repo configuration"
        echo_verbose "Some symbolic links might not work without this step"
    fi
}

function install_necessary_apt_packages() {
    echo_verbose "Installing necessary apt packages"
    if $debug_mode ; then
        xargs -a ~/dotfiles/packages/apt-packages-necessary sudo apt-get install -y
    else
        xargs -a ~/dotfiles/packages/apt-packages-necessary sudo apt-get install -y > /dev/null
    fi
}

function install_apt_packages() {
    echo_verbose "Installing apt packages..."
    if $debug_mode ; then
        xargs -a ~/dotfiles/packages/apt-packages sudo apt-get install -y
    else
        xargs -a ~/dotfiles/packages/apt-packages sudo apt-get install -y > /dev/null
    fi
}

function install_extra_apt_packages() {
    echo_verbose "Installing extra apt-packages"
    if $debug_mode ; then
        echo_debug "Adding handbreak ppa repository (handbreak compression software)"
        sudp add-apt-repository ppa:stebbins/handbrake-releases
        sudo apt-get update

        xargs -a ~/dotfiles/packages/apt-packages-extra sudo apt-get install -y
    else
        xargs -a ~/dotfiles/packages/apt-packages-extra sudo apt-get install -y > /dev/null
    fi
}

function install_brew() {
    if ! command -v brew &> /dev/null ; then
        echo_verbose "Brew not found, installing brew..."
        if $debug_mode ; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" > /dev/null
        fi
    else
        echo_verbose "Brew found"
    fi
}

function install_brew_packages() {
    echo_verbose "Installing brew packages..."
    if $debug_mode ; then
        xargs -a ~/dotfiles/packages/brew-packages sudo brew install
    else
        xargs -a ~/dotfiles/packages/brew-packages sudo brew install > /dev/null
    fi
}

function install_snap() {
    if ! command -v snap &> /dev/null ; then
        echo_verbose "Snap not found, installing snap..."
        sudo snap set system experimental.parallel-instances=true
        if $debug_mode ; then
            sudo apt-get install snapd -y
        else
            sudo apt-get install snapd -y > /dev/null
        fi
    else
        echo_verbose "Snap found"
    fi
}

function install_snap_packages() {
    echo_verbose "Installing snap packages..."
    sudo snap set system experimental.parallel-instances=true
    if $debug_mode ; then
        xargs -a ~/dotfiles/packages/snap-packages sudo snap install
    else
        xargs -a ~/dotfiles/packages/snap-packages sudo snap install > /dev/null
    fi
}

function install_pip_packages() {
    echo_verbose "Installing pip packages..."
    if $debug_mode ; then
        xargs -a ~/dotfiles/packages/pip-packages sudo pip install -r
    else
        xargs -a ~/dotfiles/packages/pip-packages sudo pip install -r > /dev/null
    fi
}

function install_other_packages() {
    echo_verbose "Installing other packages..."

    echo_verbose "micro: "
    read -p "Do you want to install micro text editor? [y/n] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]] ; then
        echo_verbose "Installing micro"
        if $debug_mode ; then
            curl https://getmic.ro | bash
            chmod +x micro/micro
            mv micro/micro ~/.local/bin
            rmdir micro
        else
            curl https://getmic.ro | bash >> /dev/null
            chmod +x micro/micro >> /dev/null
            mv micro/micro ~/.local/bin >> /dev/null
            rmdir micro
        fi
    else
        echo_verbose "Skipping micro installation"
    fi

    echo_verbose "Docker: "
    read -p "Do you want to install docker? [y/n] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]] ; then
        echo_verbose "Installing docker"
        echo_debug "Installing docker's official GPG key (https://download.docker.com/linux/ubuntu/gpg)"
        if $debug_mode ; then
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
            apt-get install docker-ce docker-ce-cli containerd.io -y
        else
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get install docker-ce docker-ce-cli containerd.io -y > /dev/null
        fi
    else
        echo_verbose "Skipping docker installation"
    fi


    echo_verbose "JetBrains Toolbox: "
    read -p "Do you want to install JetBrains Toolbox? [y/n] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]] ; then
        echo_verbose "Installing toolbox"
        echo_debug "Downloading unofficial installation script ()"
        curl https://gist.githubusercontent.com/jen20/218642f3c2cd0e2ce8b6b95ca59e0538/raw/ce378727c8531502b4156a2be37d6149b31710ee/install-jetbrains-toolbox.sh > ./install-jetbrains-toolbox.sh
        if $debug_mode ; then
            source ./install-jetbrains-toolbox.sh
            rm install-jetbrains-toolbox.sh
        else
            source ./install-jetbrains-toolbox.sh > /dev/null
            rm install-jetbrains-toolbox.sh > /dev/null
        fi
    else
        echo_verbose "Skipping docker installation"
    fi

    echo_verbose "Sublime Text: "
    read -p "Do you want to install Sublime Text? [y/n] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]] ; then
        echo_verbose "Installing Sublime Text"
        echo_debug "Downloading GPG key"
        if $debug_mod ; then
            wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
            echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
            apt-get update
            apt-get install sublime-text -y
        else
            wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add - > /dev/null
            echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list > /dev/null
            apt-get update > /dev/null
            apt-get install sublime-text -y > /dev/null
        fi
    else
        echo_verbose "Skipping sublime text installation"
    fi


    echo_verbose "Steam: "
    read -p "Do you want to install and login into Steam? [y/n] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]] ; then
        echo_verbose "Installing Steam"
        echo_debug "Adding \"multiverse\" repository (steam)"
        if $debug_mod ; then
            sudo add-apt-repository multiverse
            sudo apt update
            sudo apt install steam -y
        else
            sudo add-apt-repository multiverse > /dev/null
            sudo apt update > /dev/null
            sudo apt install steam -y > /dev/null
        fi

        read -p "Do you want to login into steam now (exit steam to continue installation)? [y/n] " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]] ; then
	        echo "EXIT STEAM TO CONTINUE INSTALLATION"
	        steam
	    fi
    else
        echo_verbose "Skipping steam installation"
    fi    
}

function install_packages() {
    if $no_apt ; then
        echo_verbose "Skipping apt-packages installation"
        echo_verbose "Some of the installation script may fail without some of the necessary packages"
        echo_verbose "See --apt-necessary option"
    else
        echo_verbose "Setting up dpkg applications..."
        if $debug_mode ; then
            dpkg --configure -a
        else
            dpkg --configure -a > /dev/null
        fi

        echo_verbose "Updating apt repository..."
        if $debug_mode ; then
            sudo apt-get update
            sudo apt-get upgrade -y
        else
            sudo apt-get update > /dev/null
            sudo apt-get upgrade -y > /dev/null
        fi

        install_necessary_apt_packages
        if $apt_necessary ; then
            echo_verbose "Skipping installation of non-necessary apt-packages"
        else
            install_apt_packages
        fi
        if $apt_extra ; then
            install_extra_apt_packages
        else
            echo_verbose "Skipping installation of extra apt-packages"
        fi
    fi

    if $no_brew ; then
        echo_verbose "Skipping installation of brew application and brew packages"
    else
        install_brew
        install_brew_packages
    fi

    if $no_snap ; then
        echo_verbose "Skipping installation of snap application and snap packages"
    else
        install_snap
        install_snap_packages
    fi

    if $no_pip ; then
        echo_verbose "Skipping installation of pip packages"
    else
        install_pip_packages
    fi

    if $no_other ; then
	echo_verbose "Skipping installation of other packages"
    else
	install_other_packages
    fi
}

function setup_kde() {
    if $kde_param ; then
        if ! command -v konsave &> /dev/null ; then
            echo "konsave not found, please install konsave using pip install konsave, and add it to PATH"
        else
            konsave -i ~/dotfiles/kde/Raesangur.knsv
            konsave -a Raesangur
        fi
    else
        echo_verbose "Skipping setup of KDE profiles and settings"
    fi
}

function display_parameters() {
    if $debug_mode ; then
        printf "Verbose mode, options and parameters:\n"
        printf "\tHelp:        $display_help\n"
        printf "\tVerbose:     $verbose_mode\n"
        printf "\tDebug:       $debug_mode\n"
        printf "\t-----\n"
        printf "\tno-links:    $no_symlinks\n"
        printf "\tno-git-creds:$no_git_creds\n"
        printf "\tno-apt:      $no_apt\n"
        printf "\tno_brew:     $no_brew\n"
        printf "\tno_snap:     $no_snap\n"
        printf "\tno_pip:      $no_pip\n"
        printf "\tapt_necess:  $apt_necessary\n"
        printf "\t-----\n"
        printf "\tzsh:         $zsh_param\n"
        printf "\tgit:         $git_param\n"
        printf "\tneofetch:    $neofetch_param\n"
        printf "\tbtop:        $btop_param\n"
        printf "\tkde:         $kde_param\n"
        printf "\tterminology: $terminology_param\n"
        printf "\tpython:      $python_param\n"
	printf "\tmicro:       $micro_param\n"
        printf "\tsecret:      $secret_git_param\n"
    fi
}




# ---------- MAIN ------------

# Get values of all parameters

# Options:
if [[ "$@" == *"--debug"* ]] || [[ "$@" == *"-d"* ]] ; then
    debug_mode=true
    verbose_mode=true
    echo $@
fi
if [[ "$@" == *"--verbose"* ]] || [[ "$@" == *"-v"* ]] ; then
    verbose_mode=true
    echo $@
fi
if [[ "$@" == *"--help"* ]] || [[ "$@" == *"-h"* ]] ; then
    display_help=true
fi

if [[ "$@" == *"--links"* ]] ; then
    no_links=false
fi
if [[ "$@" == *"--git-creds"* ]] ; then
    no_git_creds=false
fi
if [[ "$@" == *"--packages"* ]] ; then
    no_apt=false
    no_brew=false
    no_snap=false
    no_pip=false
    no_other=false
fi
if [[ "$@" == *"--apt-packages"* ]] ; then
    no_apt=false
fi
if [[ "$@" == *"--brew-packages"* ]] ; then
    no_brew=false
fi
if [[ "$@" == *"--snap-packages"* ]] ; then
    no_snap=false
fi
if [[ "$@" == *"--pip-packages"* ]] ; then
    no_pip=false
fi
if [[ "$@" == *"--other-packages"* ]] ; then
    no_other=false
fi
if [[ "$@" == *"--apt-necessary"* ]] ; then
    apt_necessary=true
    no_apt=false
fi
if [[ "$@" == *"--apt-extra"* ]] ; then
    apt_extra=true
    no_apt=false
    if $apt_necessary ; then
        echo "Conflict: option --apt-necessary and --apt-extra incompatible"
        echo "Installing extra packages"
    fi
fi

# Parameters
if [[ "$@" == *" zsh"* ]] ; then
    zsh_param=true
fi
if [[ "$@" == *" git"* ]] ; then
    git_param=true
fi
if [[ "$@" == *" neofetch"* ]] ; then
    neofetch_param=true
fi
if [[ "$@" == *" btop"* ]] ; then
    btop_param=true
fi
if [[ "$@" == *" kde"* ]] ; then
    kde_param=true
fi
if [[ "$@" == *" terminology"* ]] ; then
    terminology_param=true
fi
if [[ "$@" == *" python"* ]] ; then
    python_param=true
fi
if [[ "$@" == *" micro"* ]] ; then
    micro_param=true
fi
if [[ "$@" == *"--secret_git_param_"* ]] ; then
    secret_git_param=true
fi

# Call help function or start installation
if $display_help ; then
    show_usage
else
    display_parameters

    if ! $secret_git_param ; then
        install_packages
        create_github_config $@
    else
        echo "param received"
    fi

    create_links
    setup_kde

    if $zsh_param ; then
        echo_verbose "Making zsh default shell"
        chsh -s $(which zsh)
        echo "Enter source ~/.zshrc to configure zsh"
    fi
    echo "    "
fi
