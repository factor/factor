! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup strings ;
IN: unicode.data

ABOUT: "unicode.data"

ARTICLE: "unicode.data" "Unicode data tables"
"The " { $vocab-link "unicode.data" "unicode.data" } " vocabulary contains core Unicode data tables and code for parsing this from files."
{ $subsection canonical-entry }
{ $subsection combine-chars }
{ $subsection combining-class }
{ $subsection non-starter? }
{ $subsection name>char }
{ $subsection char>name }
{ $subsection property? } ;

HELP: canonical-entry
{ $values { "char" "a code point" } { "seq" string } }
{ $description "Finds the canonical decomposition (NFD) for a code point" } ;

HELP: combine-chars
{ $values { "a" "a code point" } { "b" "a code point" } { "char/f" "a code point" } }
{ $description "If a followed by b can be combined in NFC, this returns the code point of their combination." } ;

HELP: compatibility-entry
{ $values { "char" "a code point" } { "seq" string } }
{ $description "This returns the compatibility decomposition (NFKD) for a code point" } ;

HELP: combining-class
{ $values { "char" "a code point" } { "n" "an integer" } }
{ $description "Finds the combining class of a code point." } ;

HELP: non-starter?
{ $values { "char" "a code point" } { "?" "a boolean" } }
{ $description "Returns true if the code point has a combining class." } ;

HELP: char>name
{ $values { "char" "a code point" } { "name" string } }
{ $description "Looks up the name of a given code point. Warning: this is not optimized for speed, to save space." } ;

HELP: name>char
{ $values { "name" string } { "char" "a code point" } }
{ $description "Looks up the code point corresponding to a given name." } ;

HELP: property?
{ $values { "char" "a code point" } { "property" string } { "?" "a boolean" } }
{ $description "Tests whether the code point is listed under the given property in PropList.txt in the Unicode Character Database." } ;
