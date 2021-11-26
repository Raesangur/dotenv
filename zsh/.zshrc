# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/pascal/.oh-my-zsh"

# zsh theme
#ZSH_THEME="nanotech"
source ~/dotfiles/zsh/prompt

# Disable % eof
unsetopt prompt_cr prompt_sp

# Date format
HIST_STAMPS="yyyy-mm-dd"

# zsh plugins
plugins=(git)

# Apply zsh config
source $ZSH/oh-my-zsh.sh


# User configuration

# Set Software Aliases
source ~/dotfiles/zsh/alias

# Setup ctrl+backspace & ctrl+delete to work in terminal
bindkey '^H' backward-kill-word
bindkey '5~' kill-word

# Setup shortcut to wine 'C:\' folder
hash -d wine=/home/pascal/.wine/drive_c

# Display welcome message on shell startup
#~/scripts/welcome.sh
source ~/dotfiles/zsh/welcome

/etc/update-motd.d/90-updates-available
