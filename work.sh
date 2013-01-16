#!/bin/bash

if [[ ! -L ./work ]] ; then
	ln -s ../FactorWork work
fi
