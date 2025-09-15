#! /usr/bin/env zsh

DOTFILES=${HOME}/.dotfiles
export DOTFILES=${DOTFILES}
export COMPOSER_HOME=${HOME}/.composer/
setopt EXTENDED_GLOB

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Backup old dotfiles directory
if [[ -d ${DOTFILES} ]]; then
  time=`date +%s`
  mv ${DOTFILES} ${HOME}/.dotfiles.$time
fi

echo 'Cloning dotfiles repo'
git clone https://github.com/TXC/dotfiles.git ${DOTFILES}  > /dev/null 2>&1
cd ${DOTFILES}

echo "Done cloning repos"
echo "Setting up submodules"
git submodule update --init --recursive > /dev/null 2>&1

if [[ -f ${HOME}/.zshrc ]]; then
  echo "Backing up ${HOME}/.zshrc to ${HOME}/.zshrc.$time and installing current version"
  mv ${HOME}/.zshrc ${HOME}/.zshrc.${time}
fi
ln -s ${DOTFILES}/conf/zshrc.conf ${HOME}/.zshrc
ln -s ${DOTFILES}/conf/mackup.cgf ${HOME}/.mackup.cfg

if [[ "$OSTYPE" == darwin* ]]; then
  echo "Setting up OSX related shenanigans"
  composerJSON=${DOTFILES}/composer/composer.osx.json

  # Update Homebrew recipes
  cd ${DOTFILES}/install
  brew update
  brew tap homebrew/bundle
  brew bundle
  sh ${DOTFILES}/install/osx.sh
  brew install romkatv/powerlevel10k/powerlevel10k
  cd ${DOTFILES}

elif [[ "$OSTYPE" == linux* ]]; then
  composerJSON = $DOTFILES/composer/composer.nix.json
fi

if [[ -f $composerJSON ]]; then
  echo "Installing Composer stuff"
  echo "composerJSON = ${composerJSON}"
  ln -s $composerJSON ${COMPOSER_HOME}/composer.json
  composer global install > /dev/null 2>&1
fi

function _ssh_config() {
  mkdir -p "${HOME}/.ssh/conf.d"
  chmod 700 "${HOME}/.ssh" "${HOME}/.ssh/conf.d"
  chmod 600 "${HOME}/.ssh/id_*"
  chmod 644 "${HOME}/.ssh/id_*.pub"
  touch "${HOME}/.ssh/authorized_keys" "${HOME}/.ssh/known_hosts"
  chmod 644 "${HOME}/.ssh/authorized_keys" "${HOME}/.ssh/known_hosts"
}

echo "Applying SSH Config"
_ssh_config
if [[ -f ${HOME}/.ssh/config ]]; then
  time=`date +%s`
  mv ${HOME}/.ssh/config ${HOME}/.ssh/config.$time
  ln -s ${DOTFILES}/conf/sshConfig ${HOME}/.ssh/config
fi

echo "Installing vim stuff"
mkdir -p ${HOME}/.vim/backups ${HOME}/.vim/swaps ${HOME}/.vim/undo
ln -s ${DOTFILES}/conf/vim/.vimrc ${HOME}/.vimrc

echo "Setting up git"
git config --global core.excludesfile ~/.dotfiles/conf/gitignore

echo "Everything installed!"
source ${HOME}/.zshrc