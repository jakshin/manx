#!/bin/bash
# Uninstalls manx, either from the passed directory,
# or by attempting to find it in the command search path or /usr/local/bin.

function failed() {
	echo
	echo "Uninstallation failed, sorry. :-/"
	exit 1
}

trap 'failed' ERR

# if the user requested help, show some o' that
if [[ $1 == "-h" || $1 == "--help" ]]; then
	echo "Usage: $(basename "$0") [uninstall_from_dir]"
	echo
	echo "The install_to_dir argument is optional."
	echo "By default, the first instance of manx in the PATH will be uninstalled."
	echo "Its man page, if located, will also be uninstalled."
	exit 1
fi

# figure out where we should uninstall from
function trim() {
	# read -rd '' var_name < <(echo "$1")
	read -rd '' $1 <<<"${!1}"
}

uninstall_from_dir="$1"
trim uninstall_from_dir && echo

if [[ $uninstall_from_dir ]]; then
	# strip all trailing slashes
	pattern='^(.*[^/])/*$'
	[[ $uninstall_from_dir =~ $pattern ]]
	bin_dir="${BASH_REMATCH[1]}"

	bin_file="${bin_dir}/manx"
	man_file="${bin_dir%/*}/share/man/man1/manx.1"
else
	bin_file=`\which manx`  # search the PATH first
	if [[ -z "$bin_file" ]]; then
		bin_file=/usr/local/bin/manx  # fall back to our default installation directory
	fi

	# look for the man page in the obvious location
	bin_dir=`\dirname "$bin_file"`
	man_file="${bin_dir%/*}/share/man/man1/manx.1"

	if [[ ! -f "$man_file" ]]; then
		# try to find manx.1 if the obvious location doesn't exist
		maybe="$(man --path manx 2>/dev/null)"
		if [[ "$maybe" ]]; then
			man_file="$maybe"
		fi
	fi
fi

# remove the files interactively
no_bin_file=x
no_man_file=x

if [[ -f "$bin_file" || -f "$man_file" ]]; then
	sudo echo -n  # prompt for password
fi

echo "Uninstalling $bin_file"
if [[ -f "$bin_file" ]]; then
	sudo rm -i "$bin_file"
else
	echo "File not found: $bin_file"
	no_bin_file=y
fi

echo "Uninstalling $man_file"
if [[ -f "$man_file" ]]; then
	sudo rm -i "$man_file"
else
	echo "File not found: $man_file"
	no_man_file=y
fi

# remove the cache unilaterally
rm -rf ~/Library/Caches/manx

echo
echo "Uninstallation complete!"

# if either directory is now empty, mention that
empty_dirs=""
dir_is_str="directory is"

if [[ $no_bin_file != "y" && -d "$bin_dir" ]]; then
	files="$(\ls -A "$bin_dir")"
	if [[ $files == "" || $files == ".DS_Store" ]]; then
		empty_dirs="'$bin_dir'"
	fi
fi

man_dir=`\dirname "$man_file"`
if [[ $no_man_file != "y" && -d "$man_dir" ]]; then
	files="$(\ls -A "$man_dir")"
	if [[ $files == "" || $files == ".DS_Store" ]]; then
		if [[ "$empty_dirs" ]]; then
			empty_dirs+=" and "
			dir_is_str="directories are"
		fi
		
		empty_dirs+="'$man_dir'"
	fi
fi

if [[ "$empty_dirs" ]]; then
	echo
	echo "Note that the $empty_dirs $dir_is_str now empty."
fi
