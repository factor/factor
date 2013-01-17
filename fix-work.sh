#!/bin/bash

if [[ ! -L ./work ]] ; then
	if [[ -e ./work ]] ; then
		rm -fr ./work
	fi
	ln -s ../FactorWork work
fi
