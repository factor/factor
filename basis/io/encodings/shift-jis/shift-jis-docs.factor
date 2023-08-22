! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: io.encodings.shift-jis

ARTICLE: "io.encodings.shift-jis" "Shift JIS"
"Shift JIS is a text encoding for Japanese. There are multiple versions, depending on whether the official standard or the modified Microsoft version is required."
{ $subsections
    shift-jis
    windows-31j
} ;

ABOUT: "io.encodings.shift-jis"

HELP: windows-31j
{ $class-description "The encoding descriptor Windows-31J, which is sometimes informally called Shift JIS. This is based on Code Page 932." }
{ $see-also "encodings-introduction" shift-jis } ;

HELP: shift-jis
{ $class-description "The encoding descriptor for Shift JIS, or JIS X 208:1997 Appendix 1. Microsoft extensions are not included." }
{ $see-also "encodings-introduction" windows-31j } ;
