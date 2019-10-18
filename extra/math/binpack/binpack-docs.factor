! Copyright (C) 2008 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: help.syntax help.markup kernel assocs sequences quotations ;

IN: math.binpack

HELP: binpack
{ $values { "items" sequence } { "#bins" "number of bins" } { "bins" "packed bins" } }
{ $description "Packs a sequence of numbers into the specified number of bins." } ;

HELP: map-binpack
{ $values { "items" sequence } { "quot" { $quotation ( item -- weight ) } } { "#bins" "number of bins" } { "bins" "packed bins" } }
{ $description "Packs a sequence of items into the specified number of bins, using the quotation to determine the weight." } ;
