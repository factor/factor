USING: help.syntax help.markup strings ;
IN: unicode.case

ABOUT: "unicode.case"

ARTICLE: "unicode.case" "Case mapping"
"When considering Unicode in general and not just ASCII or a smaller character set, putting a string in upper case, title case or lower case is slightly more complicated. In most contexts it's best to use the general Unicode routines for case conversion. There is an additional type of casing, case-fold, which is defined as bringing a string into upper case and then lower. This exists because in some cases it is different from simple lower case."
{ $subsection >upper }
{ $subsection >lower }
{ $subsection >title }
{ $subsection >case-fold }
"There are analogous routines which operate on individual code points, but these should " { $emphasis "not be used" } " in general as they have slightly different behavior. In some cases, for example, they do not perform the case operation, as a single code point must expand to more than one."
{ $subsection ch>upper }
{ $subsection ch>lower }
{ $subsection ch>title }
"To test if a string is in a given case:"
{ $subsection upper? }
{ $subsection lower? }
{ $subsection title? }
{ $subsection case-fold? }
"For certain languages (Turkish, Azeri, Lithuanian), case mapping is dependent on locale; To change this, set the following variable to the ISO-639-1 code for your language:"
{ $subsection locale }
"This is unnecessary for most locales." ;

HELP: >upper
{ $values { "string" string } { "upper" string } }
{ $description "Converts a string to upper case." } ;

HELP: >lower
{ $values { "string" string } { "lower" string } }
{ $description "Converts a string to lower case." } ;

HELP: >title
{ $values { "string" string } { "title" string } }
{ $description "Converts a string to title case." } ;

HELP: >case-fold
{ $values { "string" string } { "fold" string } }
{ $description "Converts a string to case-folded form." } ;

HELP: upper?
{ $values { "string" string } { "?" "a boolean" } }
{ $description "Tests if a string is in upper case." } ;

HELP: lower?
{ $values { "string" string } { "?" "a boolean" } }
{ $description "Tests if a string is in lower case." } ;

HELP: title?
{ $values { "string" string } { "?" "a boolean" } }
{ $description "Tests if a string is in title case." } ;

HELP: case-fold?
{ $values { "string" string } { "?" "a boolean" } }
{ $description "Tests if a string is in case-folded form." } ;

HELP: ch>lower
{ $values { "ch" "a code point" } { "lower" "a code point" } }
{ $description "Converts a code point to lower case." }
{ $warning "Don't use this unless you know what you're doing! " { $code ">lower" } " is not the same as " { $code "[ ch>lower ] map" } "." } ;

HELP: ch>upper
{ $values { "ch" "a code point" } { "upper" "a code point" } }
{ $description "Converts a code point to upper case." }
{ $warning "Don't use this unless you know what you're doing! " { $code ">upper" } " is not the same as " { $code "[ ch>upper ] map" } "." } ;

HELP: ch>title
{ $values { "ch" "a code point" } { "title" "a code point" } }
{ $description "Converts a code point to title case." }
{ $warning "Don't use this unless you know what you're doing! " { $code ">title" } " is not the same as " { $code "[ ch>title ] map" } "." } ;
