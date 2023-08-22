! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: help.markup help.syntax layouts math sequences ;
IN: math.cardinality

HELP: trailing-zeros
{ $values { "m" number } { "n" number } }
{ $description "Counts the number of trailing 0 bits in " { $snippet "m" } ", returning " { $link fixnum-bits } " if the number is zero." } ;

HELP: estimate-cardinality
{ $values { "seq" sequence } { "k" number } { "n" number } }
{ $description "Estimates the number of unique elements in " { $snippet "seq" } "." $nl "The number " { $snippet "k" } " controls how many bits of hash to use, creating " { $snippet "2^k" } " buckets." } ;
