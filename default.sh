#!/bin/bash
#Skeleton BASH script file

DEBUG=false
VERSION=""
THISSCRIPT=$(which "$0")
THISPATH=$(dirname "$THISSCRIPT")
VERSIONURL="https://github.com/hp6000x/ /raw/master/VERSION"
SCRIPTURL="https://github.com/hp6000x/ /raw/master/ "
FUNCTSURL="https://github.com/hp6000x/useful-functions/raw/master/functions.sh"
FUNCTIONS="$THISPATH/functions.sh"

function Init
{
	if [[ ! -e "$FUNCTIONS" ]]; then
		echo "functions.sh not found. Do you want to download it to $THISPATH? (Y/n)"
		read -rs inkey
		if [[ "$inkey" = "y" ]] | [[ "$inkey" = "" ]]; then
			tmpfile=$(mktemp)
			if (wget -O "$tmpfile" "$FUNCTSURL"); then
				if (mv "$tmpfile" "$FUNCTIONS"); then
					chmod 755 "$FUNCTIONS"
					unset tmpfile
					. "$FUNCTIONS"
				else
					echo "Could not create $FUNCTIONS"
					exit 2
				fi
			else
				echo "Couldn't download functions.sh"
				exit 1
			fi
		else
			echo "Aborted by user"
			exit 1
		fi
		unset inkey
	else
		. "$FUNCTIONS"
	fi
}

function Main
{
	true
}

function Done
{
	true
}

Init
Main
Done
