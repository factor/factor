! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel help.markup help.syntax ;
IN: prettyprint.custom

HELP: pprint*
{ $values { "obj" object } }
{ $contract "Adds sections to the current block corresponding to the prettyprinted representation of the object." }
$prettyprinting-note ;
