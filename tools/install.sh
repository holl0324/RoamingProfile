#!/bin/bash

set OLD_PATH=$PATH

# We need to be in our home directory to run this.
pushd ~

# Clone the roaming profile repo, or pull changes
if [[ -d ~/.roaming_profile ]]; then
	echo "Roaming profile found, leaving untouched."
	pushd .roaming_profile
	git fetch
	popd
else
	env git clone https://github.com/mceyberg/RoamingProfile.git ~/.roaming_profile
fi

# All the config files
configs=( ".bash_aliases" ".gitconfig" ".gitignore" ".pryrc" ".vimrc" ".warprc" ".zshrc" )

# Create soft links for all configuration files in .roaming_profile.
# Back the specified file up if a copy exists already with the .backup suffix
for config_file in ${configs[*]}; do
  # File is a symbolic link. Remove and replace it.
  [ -h ~/${config_file} ] && rm ~/${config_file}

  # File already exists. Add .backup suffix.
  [ -f ~/${config_file} ] && mv ~/${config_file} ~/${config_file}.backup
  ln -s .roaming_profile/${config_file}
done

# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install Vundle
env git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

vim +source % +qall
# Run the 'PluginInstall' command to load all the plugins set in .vimrc
vim +PluginInstall +qall

# If we are running OS X, deploy Sublime and ITerm settings
if [[ "uname" == 'Darwin' ]]; then
  sublime_app_dir="Library/Application\ Support/Sublime\ Text\ 3/Packages/User"
  ln -s $sublime_app_dir/Default\ \(OSX\).sublime-keymap ~/$sublime_app_dir/
  ln -s $sublime_app_dir/Preferences.sublime-settings ~/$sublime_app_dir/
fi

popd

