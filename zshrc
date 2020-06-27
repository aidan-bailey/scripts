
#################
##_ANTIGEN SETUP_##
#################

source ~/.antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle heroku
antigen bundle pip
antigen bundle lein
antigen bundle command-not-found

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Autosuggestions
antigen bundle zsh-users/zsh-autosuggestions

# Autocompletions
antigen bundle zsh-users/zsh-completions

# Load the theme.
antigen theme robbyrussell

# Tell Antigen that you're done.
antigen apply

#############
##_ALIASES_##
#############

alias zshconfig="nvim ~/.zshrc"
alias vim="nvim"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ls='lsd --group-dirs first'
#alias ls="ll"

#############
##_EXPORTS_##
#############

export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'
