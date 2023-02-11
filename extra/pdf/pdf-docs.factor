! Copyright (C) 2011-2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: help.markup help.syntax strings ;

IN: pdf

HELP: text-to-pdf
{ $values { "str" string } { "pdf" string } }
{ $description "Converts " { $snippet "str" } " into PDF instructions." } ;

HELP: file-to-pdf
{ $values { "path" string } { "encoding" "an encoding" } }
{ $description "Converts " { $snippet "path" } " into a PDF, saving to " { $snippet "path.pdf" } "." } ;
