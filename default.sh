#!/bin/bash
#Skeleton BASH script file

TITLE=""
VERSION=""
THISSCRIPT=$(which "$0")
THISPATH=$(dirname "$THISSCRIPT")
THISFILE=$(basename "$THISSCRIPT")
VERSIONURL="" #"https://raw.githubusercontent.com/hp6000x/ /master/VERSION"
SCRIPTURL="" #"https://raw.githubusercontent.com/hp6000x/ /master/$THISFILE"

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

function Init
{
	true
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
	true
}

#get arguments before anything else loads or runs
echoDebug "Getting command line arguments"
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
unset arg
unset opt
unset var

Init
Main
Done
