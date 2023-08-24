! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax help.markup kernel math strings unicode ;
IN: unicode.data

ABOUT: "unicode.data"

ARTICLE: "unicode.data" "Unicode data tables"
"The " { $vocab-link "unicode.data" } " vocabulary contains core Unicode data tables and code for parsing this from files. The following words access these data tables."
{ $subsections
    canonical-entry
    combine-chars
    combining-class
    non-starter?
    name>char
    char>name
    property?
    category
    ch>upper
    ch>lower
    ch>title
    special-case
} ;

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
{ $values { "char" "a code point" } { "n" integer } }
{ $description "Finds the combining class of a code point." } ;

HELP: non-starter?
{ $values { "char" "a code point" } { "?" boolean } }
{ $description "Returns true if the code point has a combining class." } ;

HELP: char>name
{ $values { "char" "a code point" } { "name" string } }
{ $description "Looks up the name of a given code point. Warning: this is not optimized for speed, to save space." } ;

HELP: name>char
{ $values { "name" string } { "char" "a code point" } }
{ $description "Looks up the code point corresponding to a given name." } ;

HELP: property?
{ $values { "char" "a code point" } { "property" string } { "?" boolean } }
{ $description "Tests whether the code point is listed under the given property in PropList.txt in the Unicode Character Database." } ;

HELP: category
{ $values { "char" "a code point" } { "category" string } }
{ $description "Returns the general category of a code point, in the form of a string. This will always be a string within the ASCII range of length two. If the code point is unassigned, then it returns " { $snippet "Cn" } "." } ;

HELP: ch>upper
{ $values { "ch" "a code point" } { "upper" "a code point" } }
{ $description "Returns the simple upper-cased version of the code point, if it exists. This does not handle context-sensitive or locale-dependent properties of linguistically accurate case conversion, and does not correctly handle characters which become multiple characters on conversion to this case." } ;

HELP: ch>lower
{ $values { "ch" "a code point" } { "lower" "a code point" } }
{ $description "Returns the simple lower-cased version of the code point, if it exists. This does not handle context-sensitive or locale-dependent properties of linguistically accurate case conversion, and does not correctly handle characters which become multiple characters on conversion to this case." } ;

HELP: ch>title
{ $values { "ch" "a code point" } { "title" "a code point" } }
{ $description "Returns the simple title-cased version of the code point, if it exists. This does not handle context-sensitive or locale-dependent properties of linguistically accurate case conversion, and does not correctly handle characters which become multiple characters on conversion to this case." } ;

HELP: special-case
{ $values { "ch" "a code point" } { "casing-tuple" { "a tuple, or " { $link f } } } }
{ $description "If a code point has special casing behavior, returns a tuple which represents that information." } ;
