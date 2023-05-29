#!/bin/bash

set -eo pipefail

# VARS
USERNAME=$(id -u -n)

# FLAGS
MIRRORFLAGS='--geoip'
PFLAGS='--noconfirm --needed --quiet --disable-download-timeout --norebuild --noredownload'
EMACSFLAGS='--without-compress-install --with-native-compilation --with-json --with-pgtk'
DOOMFLAGS='--config --env --install --fonts --hooks'

# PATHS
BASHRCPATH=$HOME/.zshrc
PROFILEPATH=$HOME/.profile

# VERSIONS
PYVERSION=3.11.3

#############
# FUNCTIONS #
#############

updatemirrors() {
	sudo pacman-mirrors $MIRRORFLAGS
}

pupgrade () {
	yay -Syu $PFLAGS
}

pinstall () {
	yay -S $@ $PFLAGS
}

bashrc () {
	if ! grep -x "$1" $BASHRCPATH >> /dev/null; then
		echo "$1" >> $BASHRCPATH
	fi
}

profile () {

	if ! grep -x "$1" $PROFILEPATH >> /dev/null; then
		echo "$1" >> $PROFILEPATH
	fi

}

########
# INIT #
########

# Set mirrors
updatemirrors

# Yay Package Manager
if ! which yay >> /dev/null; then
	cd /tmp
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si
	cd --
	cd --
fi

# Upgrade
pupgrade

# PulseAudio
# install_pulse

# SwapEscape
bashrc 'setxkbmap -option caps:swapescape'
bashrc 'eval $(ssh-agent) > /dev/null 2> /dev/null'
profile 'export SHELL=/usr/bin/zsh'

# Fonts
# pinstall noto-fonts-emoji

#######
# ENV #
#######

# TERMINAL EDITOR
echo "Setting up terminal editor..."
pinstall neovim
profile 'export EDITOR=/usr/bin/nvim'

# BROWSER
echo "Setting up browser..."
pinstall brave-browser
profile 'export BROWSER=/usr/bin/brave'

#########
# LANGS #
#########

# SHELL
echo "Setting up shell..."
pinstall shfmt aspell-en

# MARKDOWN
echo "Setting up markdown..."
pinstall marked

# SCALA
echo "Setting up scala..."
pinstall scala scala-docs scala-sources

# JAVA
echo "Setting up java..."
pinstall gradle

# PYTHON
echo "Setting up python..."
pinstall python python-pip python-wheel twine pyenv pyright
bashrc 'export PATH=$HOME/.pyenv/bin:$PATH'
bashrc 'eval "$(pyenv init -)"'
pyenv install $PYVERSION --skip-existing
pyenv global $PYVERSION
pip3 install --upgrade pip
pip3 install wheel pyflakes isort pipenv pytest pysort black neovim

# C++
echo "Setting up c++..."
pinstall cmake

# JAVASCRIPT
echo "Setting up javascript..."
pinstall nodejs npm

# JULIA
echo "Setting up julia..."
pinstall julia
julia -e 'using Pkg; Pkg.add("LanguageServer")'

# HASKELL
echo "Setting up haskell..."
pinstall ghc ghc-libs ghc-static ghc-filesystem haskell-language-server stack

# RUST
echo "Setting up rust..."
pinstall rustup cargo 
rustup default nightly
rustup component add rust-analyzer-preview

# C#
echo "Setting up c#"
pinstall dotnet-sdk mono omnisharp-roslyn

#########
# TOOLS #
#########

# THUNDERBIRD
echo "Setting up thunderbird..."
pinstall thunderbird

# DBEAVER
echo "Setting up dbeaver..."
pinstall dbeaver

# GCLOUD
echo "Setting up gcloud..."
pinstall google-cloud-sdk

# DOCKER
echo "Setting up docker..."
#pinstall nvidia-container-toolkit
#pinstall docker
#sudo systemctl enable docker
#sudo systemctl start docker
#sudo systemctl enable containerd
#sudo systemctl start containerd
#sudo usermod -aG docker $USERNAME

# SLACK
echo "Setting up slack..."
pinstall slack-desktop

################
# APPLICATIONS #
################

# STEAM
echo "Setting up steam..."
pinstall steam-native-runtime

# DISCORD
echo "Setting up discord..."
pinstall community/discord

# SPOTIFY
#echo "Setting up spotify..."
pinstall spotify

# Postgress
echo "Setting up postgresql..."
pinstall postgresql

########
# IDEs #
########

# EMACS
echo "Setting up emacs..."
pinstall ripgrep fd libgccjit
if ! which emacs >> /dev/null 2> /dev/null ; then
	cd /tmp
	git clone https://github.com/emacs-mirror/emacs.git
	cd emacs
	git checkout emacs-28
	./autogen.sh
    	./configure $EMACSFLAGS
    	make -j$(nproc)
	sudo make install
	cd --
	cd --
fi

if ! which doom >> /dev/null 2> /dev/null ; then
	git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
	~/.emacs.d/bin/doom install $DOOMFLAGS
	bashrc 'export PATH=$HOME/.emacs.d/bin:$PATH'
fi

# VSCODE
echo "Setting up vscode..."
pinstall visual-studio-code-bin
