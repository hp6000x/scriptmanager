#!/bin/bash
#Skeleton BASH script file

TITLE=""
VERSION=""
THISSCRIPT=$(which "$0")
THISPATH=$(dirname "$THISSCRIPT")
THISFILE=$(basename "$THISSCRIPT")
VERSIONURL="" #"https://raw.githubusercontent.com/hp6000x/ /master/VERSION"
SCRIPTURL="" #"https://raw.githubusercontent.com/hp6000x/ /master/$THISFILE"
DEBUG=false
CONFFILE=""

function showGenericHelp
{
	echo "$TITLE v$VERSION"
	echo
	echo "Usage: $THISSCRIPT <command> [<option> [...]]"
	echo
	echo "Commands:"
	if [[ ! -z "$VERSIONURL" ]]; then
		echo "	u,update		Update this script with new version from github"
	fi
	echo "	h,help			Display this help text"
	echo
	echo "Options:"
	echo "	--config[=]<path to config file>"
	echo "				Load an alternate configuration file"
	echo "	--debug			Run script in debug mode."
	echo "	-h,--help		Give more information about a command"
	echo
}

function showCommandHelp
{
	test -z "$command" && local command="$1"
	echo "$TITLE v$VERSION"
	case $command in
		("u"|"update")		if [[ -z "$VERSIONURL" ]]; then
								echo "Update function not available in this script."
							else
								echo "update: Download new script version from $SCRIPTURL and update."
							fi;;
		(*)					echo "No help available for $command"
	esac
}

function getAvailVersion
{
	local tmpname
	tmpname="$(mktemp)"
	if (wget -q -O "$tmpname" "$VERSIONURL" > /dev/null 2>&1); then
		cat "$tmpname"
		rm "$tmpname"
	else
		echo "Unknown"
	fi
}

function isGreater
{
	test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

function getKey
{
	local key
	read -r -s -n 1 key
	echo $key
}

function updateScript
{
	local gitVersion
	local tmpname
	local inkey
	local readme
	readme="$HOME/Desktop/README.md"
	gitVersion=$(getAvailVersion)
	if isGreater "$gitVersion" "$VERSION"; then 
		echo "Updating $THISSCRIPT to v$gitVersion."
		tmpname="$(mktemp)"
		if (wget -q -O "$tmpname" "$SCRIPTURL" > /dev/null 2>&1); then 
			if (wget -q -o "$readme" "$READMEURL" > /dev/null 2>&1); then
				echo "README file saved to desktop."
			else
				echo "Could not get README file."
			fi
			if [[ -e "$THISSCRIPT.bak" ]]; then
				rm "$THISSCRIPT.bak"
			fi
			mv "$THISSCRIPT" "$THISSCRIPT.bak"
			chmod 755 "$tmpname"
			mv "$tmpname" "$THISSCRIPT"
			if [[ -a "$THISSCRIPT" ]]; then
				echo "Updated script. Hit \"Y\" or Enter to view the README now. Any other key to skip."
				inkey=$(getKey)
				case $inkey in
					("Y"|"y"|"")	less "$readme"
				esac
			else
				echo "Update failed. Restoring backup."
				cp "$THISSCRIPT.bak" "$THISSCRIPT"
			fi
		else #download failed
			echo "Could not get new script file from $SCRIPTURL. Is the repository still there?"
		fi
	elif [[ "$gitVersion" = "$VERSION" ]]; then
		echo "You are already on the latest version ($VERSION)"
	elif isGreater "$VERSION" "$gitVersion"; then
		echo "Your version: $VERSION. Current version: $gitVersion. Can't wait for release, Mr. Developer."
	elif [[ -z "$gitVersion" ]]; then
		echo "Online version information not found."
	fi
}

function loadSettings
{
	if [[ -e "$CONFFILE" ]]; then
		. "$CONFFILE"
		settings_changed=false
	fi
}

function saveSettings
{
	true
}

function Init
{
	local arg
	local opt
	local var
	command="$1"
	shift
	while [[ ! -z "$1" ]]; do
		arg="$1"
		opt="${arg%=*}" #anything before an equals sign goes in opt. If no "=", the whole string goes in.
		var="${arg#*=}" #anything after the "=" goes in var
		case $opt in
			("--config")		if [[ -z "$var" ]]; then
									var="$2"
								fi
								CONFFILE="$var";;
			("--debug")			DEBUG=true;;
			("-h"|"--help")		showCommandHelp "$command"; exit 0;;
			(*)					echo "Unknown option \"$opt\"."; exit 4;;
		esac
		if [[ "$var" = "$2" ]]; then
			shift
		fi
		shift
	done
	loadSettings
}

function Main
{
	case $command in
		("h"|"help")		showGenericHelp;;
		("u"|"update")		if [[ -z "$VERSIONURL" ]]; then
								echo "Update function not available."
							else
								updateScript
							fi;;
		(*)					echo "Unknown command \"$command\"."; exit 5;;
	esac
}

function Done
{
	if $settings_changed; then
		saveSettings
	fi
}

Init $@
Main
Done
