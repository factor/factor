! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.syntax help.markup kernel assocs sequences quotations ;

IN: math.binpack 

HELP: binpack
{ $values { "assoc" assoc } { "n" "number of bins" } { "bins" "packed bins" } }
{ $description "Packs the (key, value) pairs into the specified number of bins, using the value as a weight." } ;

HELP: binpack*
{ $values { "items" sequence } { "n" "number of bins" } { "bins" "packed bins" } } 
{ $description "Packs a sequence of numbers into the specified number of bins." } ;

HELP: binpack!
{ $values { "items" sequence } { "quot" quotation } { "n" "number of bins" } { "bins" "packed bins" } } 
{ $description "Packs a sequence of items into the specified number of bins, using the quotatino to determine the weight." } ;

