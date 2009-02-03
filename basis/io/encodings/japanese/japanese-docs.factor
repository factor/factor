! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: io.encodings.japanese

ARTICLE: "io.encodings.japanese" "Japanese text encodings"
"The " { $vocab-link "io.encodings.japanese" } " vocabulary implements Japanese-specific text encodings. Several encodings are used for Japanese text besides the standard UTF encodings for Unicode strings. These are mostly based on the character set defined in the JIS X 208 standard. Current coverage of encodings is incomplete."
{ $subsection shift-jis }
{ $subsection windows-31j } ;

ABOUT: "io.encodings.japanese"

HELP: windows-31j
{ $class-description "The encoding descriptor Windows-31J, which is sometimes informally called Shift JIS. This is based on Code Page 932." }
{ $see-also "encodings-introduction" shift-jis } ;

HELP: shift-jis
{ $class-description "The encoding descriptor for Shift JIS, or JIS X 208:1997 Appendix 1. Microsoft extensions are not included." }
{ $see-also "encodings-introduction" windows-31j } ;
