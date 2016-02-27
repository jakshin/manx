#!/bin/bash
# Installs manx, either into the passed directory, or /usr/local/bin by default;
# its man page is also installed, in the appropriate directory (/usr/local/share/man/man1 by default)

function failed() {
	echo "Installation failed, sorry. :-/"
	exit 1
}

trap 'failed' ERR

# if the user requested help, show some o' that
if [[ $1 == "-h" || $1 == "--help" ]]; then
	echo "Usage: $(basename "$0") [install_to_dir]"
	echo "By default, manx will be installed to /usr/local/bin."
	exit 1
fi

# figure out where we should install to
function trim() {
	# read -rd '' var_name < <(echo "$1")
	read -rd '' $1 <<<"${!1}"
}

install_to_dir="$1"
trim install_to_dir && echo

if [[ $install_to_dir ]]; then
	# strip all trailing slashes
	pattern='^(.*[^/])/*$'
	[[ $install_to_dir =~ $pattern ]]
	bin_dir="${BASH_REMATCH[1]}"

	# must begin with slash
	if [[ "$bin_dir" != /* ]]; then
		echo "Invalid installation directory: $install_to_dir"
		echo "Please use an absolute path. You may not install to the root directory."
		exit 1
	fi
else
	bin_dir=/usr/local/bin
fi

man_dir="${bin_dir%/*}/share/man/man1"

# download first, since it seems like the most likely installation step to fail
tmp_dir="${TMPDIR:-/private/tmp}"

sudo curl -fsSL https://raw.githubusercontent.com/jakshin/manx/master/manx -o "$tmp_dir/manx"
sudo curl -fsSL https://raw.githubusercontent.com/jakshin/manx/master/manx.1 -o "$tmp_dir/manx.1"

# create the target directories, if needed
if [[ ! -d "$bin_dir" ]]; then
	sudo mkdir -p "$bin_dir"
fi

if [[ ! -d "$man_dir" ]]; then
	sudo mkdir -p "$man_dir"
fi

# move the downloaded files into the target directories
echo "Installing $bin_dir/manx"
sudo mv -i "$tmp_dir/manx" "$bin_dir"

echo "Installing $man_dir/manx.1"
sudo mv -i "$tmp_dir/manx.1" "$man_dir"

echo
echo "Installation complete!"

# if manx wasn't installed to a directory which is in the path, mention that
if [[ ":$PATH:" != *":$bin_dir:"* ]]; then
	echo
	echo "Note that the '$bin_dir' directory isn't in your command search path."
	echo "Consider putting a line like this into your .bash_profile and/or .zshenv:"
	echo "export PATH=\$PATH:$bin_dir"
fi
