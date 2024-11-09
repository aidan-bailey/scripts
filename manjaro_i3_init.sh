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
i3CONFIGPATH=$HOME/.i3/config

# VERSIONS
PYVERSION=3.9.13

STDOUT='manjaro_i3_setup.log'
STDERR='manjaro_i3_setup.err'

touch $STDOUT 
touch $STDERR

#############
# FUNCTIONS #
#############

log() {
	echo $@ >> $STDOUT 2>> $STDERR
	echo "$@" 
}

updatemirrors() {
	sudo pacman-mirrors $MIRRORFLAGS >> $STDOUT 2>> $STDERR
}

pupgrade () {
	yay -Syu $PFLAGS >> $STDOUT 2>> $STDERR
}

pinstall () {
	yay -S $@ $PFLAGS >> $STDOUT 2>> $STDERR
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
log "Updating mirrors..."
updatemirrors

log "Checking Yay is installed..."
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
log "Upgrading system..."
pupgrade

# PulseAudio
log "Setting up pulsaudio..."
pinstall manjaro-pulse pa-applet-git pavucontrol
msg "writing configuration"
sed -i 's/exec --no-startup-id volumeicon/#exec --no-startup-id volumeicon/g' $i3CONFIGPATH
sed -i 's/bindsym \$mod+Ctrl+m exec terminal -e '\''alsamixer'\''/#bindsym \$mod+Ctrl+m exec terminal -e '\''alsamixer'\''/g' $i3CONFIGPATH
sed -i 's/#exec --no-startup-id pulseaudio/exec --no-startup-id start-pulseaudio-x11/g' $i3CONFIGPATH
sed -i 's/#exec --no-startup-id pa-applet/exec --no-startup-id pa-applet/g' $i3CONFIGPATH
sed -i 's/#bindsym \$mod+Ctrl+m exec pavucontrol/bindsym \$mod+Ctrl+m exec pavucontrol/g' $i3CONFIGPATH

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
log "Setting up terminal editor..."
pinstall neovim
profile 'export EDITOR=/usr/bin/nvim'

# BROWSER
log "Setting up browser..."
pinstall sidekick-browser-stable-bin
profile 'export BROWSER=/usr/bin/brave'

#########
# LANGS #
#########

# SHELL
log "Setting up shell..."
pinstall shfmt aspell-en

# MARKDOWN
log "Setting up markdown..."
pinstall marked

# SCALA
log "Setting up scala..."
pinstall scala scala-docs scala-sources

# JAVA
log "Setting up java..."
pinstall gradle

# PYTHON
log "Setting up python..."
pinstall python tk python-pip python-wheel twine pyenv pyright
bashrc 'export PATH=$HOME/.pyenv/bin:$PATH'
bashrc 'eval "$(pyenv init -)"'
pyenv install $PYVERSION --skip-existing
pyenv global $PYVERSION
#pip3 install --upgrade pip # Can no longer install into global python environment
pinstall install python-wheel python-pyflakes python-isort python-pipenv python-pytest python-pysort python-black python-neovim

# C++
log "Setting up c++..."
pinstall cmake

# JAVASCRIPT
log "Setting up javascript..."
pinstall nodejs npm

# JULIA
log "Setting up julia..."
pinstall julia
julia -e 'using Pkg; Pkg.add("LanguageServer")'

# HASKELL
log "Setting up haskell..."
pinstall ghc ghc-libs ghc-static ghc-filesystem

# RUST
log "Setting up rust..."
pinstall rustup cargo 
log "installing nightly..."
rustup default nightly
log "installing analyzer and composer..."
rustup component add rust-analyzer-preview

# C#
log "Setting up c#..."
pinstall dotnet-sdk mono omnisharp-roslyn

# GO
log "Setting up go..."
pinstall go
go install golang.org/x/tools/gopls@latest

# Latex
log "Setting up latex..."
pinstall texlive-full

#########
# TOOLS #
#########

# Bitwarden
log "Setting up Bitwarden..."
pinstall bitwarden

# Feh
log "Setting up Feh..."
pinstall feh

# THUNDERBIRD
log "Setting up thunderbird..."
pinstall thunderbird

# DBEAVER
log "Setting up dbeaver..."
pinstall dbeaver

# GCLOUD
log "Setting up gcloud..."
pinstall google-cloud-sdk

# DOCKER
log "Setting up docker..."
#pinstall nvidia-container-toolkit
#pinstall docker
#sudo systemctl enable docker
#sudo systemctl start docker
#sudo systemctl enable containerd
#sudo systemctl start containerd
#sudo usermod -aG docker $USERNAME

# SLACK
log "Setting up slack..."
pinstall slack-desktop

# TeamViewer
log "Setting up teamviewer..."
pinstall teamviewer

################
# APPLICATIONS #
################

# STEAM
log "Setting up steam..."
pinstall steam-native-runtime

# DISCORD
log "Setting up discord..."
pinstall discord

# SPOTIFY
log "Setting up spotify..."
pinstall spotify

# Postgress
log "Setting up postgresql..."
pinstall postgresql

# Zotero
log "Setting up zotero..."
pinstall zotero

# QEMU
log "Setting up QEMU..."
pinstall qemu-full qemu-img libvirt virt-install virt-manager virt-viewer \ edk2-ovmf swtpm guestfs-tools libosinfo tuned
sudo systemctl enable libvirtd.service 
sudo virt-host-validate qemu 

# Remmina
log "Setting up Remmina..."
pinstall remmina freerdp

# Texstudio
log "Setting up TexStudio..."
pinstall texstudio

########
# IDEs #
########

# EMACS
log "Setting up emacs..."
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
log "Setting up vscode..."
pinstall visual-studio-code-bin
