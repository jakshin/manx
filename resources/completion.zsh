#compdef manx
# shellcheck disable=all

function _manx() {
	# Iff the first non-option argument is a section (digit or "n"),
	# we should complete man pages for the second non-option argument
	local word val="" arg2=""
	for word in "${words[@]:1}"; do  # Magic variable set by zsh, first word is "manx"
		if [[ $val == @ ]]; then
			val=""
		elif [[ $word == -M || $word == -S ]]; then
			val=@
		elif [[ $word != -* ]]; then
			[[ $word =~ ^[1-9n]$ ]] && arg2="2:: :.manx_complete_pages"
			break
		fi
	done

	_arguments : \
		"1: :.manx_complete_pages" $arg2 \
		+ '(view)' \
			{-d,--direct}'[View the man page directly in the terminal, with colors]' \
			{-h,--html}'[View the man page as HTML in your default browser]' \
			'--browser=-[View the man page as HTML in a specific browser]' \
			{-p,--pdf}'[View the man page as PDF in your default viewer]' \
			'--pdf-viewer=-[View the man page as PDF in a specific viewer]' \
			{-t,--text}'[View the man page as text in your default editor]' \
			'--editor=-[View the man page as text in a specific editor]' \
			{-x,--x-man-page}'[View the man page in a special popup Terminal window]' \
		+ '(manpath)' \
			{-M+,--manpath=-}'[Manual directories to search, separated by colons]: :_dir_list' \
		+ '(sections)' \
			{-S+,--sections=-}'[Manual sections to search, separated by colons]: :.manx_complete_sections' \
		+ '(cache)' \
			'--clear-cache[Remove cached generated HTML/PDF/text files]' \
		+ '(comp)' \
			'--completion[Outout zsh completion script and exit]' \
		+ '(help)' \
			'--help[Show usage information and exit]'
}

function .manx_complete_sections() {
	# Figure out which sections exist in the current manpath (man* subdirectories)
	declare -A descs=(
		[1]="General commands"
		[2]="System calls"
		[3]="Library routines"
		[4]="Device drivers, Special files and sockets"
		[5]="File formats"
		[6]="Games and fun stuff"
		[7]="Miscellaneous"
		[8]="System management"
		[9]="Kernel development"
		[n]="Tcl/Tk"
	)

	declare -a exists=()
	declare -a sects=("${(k)descs[@]}")

	local mpath="$(.manx_get_optval -M --manpath)"
	[[ -n $mpath ]] || mpath=$MANPATH
	[[ -n $mpath ]] || mpath="$(/usr/bin/manpath)"

	declare -a dirs
	IFS=":" read -rA dirs <<< "$mpath"

	local sect dir
	for sect in "${sects[@]}"; do
		for dir in "${dirs[@]}"; do
			if [[ -d "${dir}/man${sect}" ]]; then
				# We don't need to avoid duplicates, compadd handles that for us
				exists+=("$sect:$descs[$sect]")
				break
			fi
		done
	done

	_sequence -s : _describe -t sections 'Manual section' exists
}

function .manx_complete_pages() {
	if [[ $words[$CURRENT] == */* ]]; then
		# Complete a path to a manual file, rather than a page by name
		_files -g '*.(?|<->*)' "$@"
		return
	fi

	local msect="$(.manx_get_optval -S --sections)"
	[[ -n $msect ]] || msect=$MANSECT  # Could still be empty

	local sects=${msect//:/|}  # Wildcard for matching man* subdirectories
	[[ -n $sects ]] || sects='*'

	local mpath="$(.manx_get_optval -M --manpath)"
	[[ -n $mpath ]] || mpath=$MANPATH
	[[ -n $mpath ]] || mpath="$(/usr/bin/manpath)"

	declare -a dirs
	IFS=":" read -rA dirs <<< "$mpath"

	# In each directory in the manual path, retaining any spaces in directories' paths [$^dirs],
	# in each possible man* subdirectory for any requested manual section [eval and man($sects)],
	# list files one-per line [%s\\n] as just their extensionless basename [:r:t],
	# with null_glob enabled in case a directory doesn't exist or is empty [(N)],
	# and glob_dots enabled to handle man pages like .rhosts.5 [(D)],
	# and split by lines into an array [${(f)...}]
	local pages=(${(f)"$(eval printf '%s\\n' $^dirs/"man($sects)/*(ND:r:t)")"})

	compadd "$@" -a -- pages
}

function .manx_get_optval() {
	local short=$1 long=$2

	local word arg1 val=""
	for word in "${words[@]:1}"; do  # Magic variable set by zsh, first word is "manx"
		if [[ $val == @ ]]; then
			val=$word
		elif [[ $word == $short* ]]; then
			val=${word:2}
			[[ -n $val ]] || val=@
		elif [[ $word == $long=* ]]; then
			val=${word/*=}
		elif [[ $word != -* && -n $word && -z $arg1 ]]; then
			arg1=$word
			if [[ $short == -S && $word =~ ^[1-9n]$ ]]; then
				val=$word  # Section in optional first argument
			fi
		fi
	done

	[[ $val != @ ]] || val=""
	echo "$val"
}

_manx "$@"
