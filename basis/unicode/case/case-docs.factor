USING: help.syntax help.markup kernel strings unicode ;
IN: unicode.case

ABOUT: "unicode.case"

ARTICLE: "unicode.case" "Case mapping"
"When considering Unicode in general and not just ASCII or a smaller character set, putting a string in upper case, title case or lower case is slightly more complicated. In most contexts it's best to use the general Unicode routines for case conversion. There is an additional type of casing, case-fold, which is defined as bringing a string into upper case and then lower. This exists because in some cases it is different from simple lower case."
{ $subsections
    >upper
    >lower
    >title
    >case-fold
}
"To test if a string is in a given case:"
{ $subsections
    upper?
    lower?
    title?
    case-fold?
}
"For certain languages (Turkish, Azeri, Lithuanian), case mapping is dependent on locale; To change this, set the following variable to the ISO-639-1 code for your language:"
{ $subsections locale }
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
{ $values { "string" string } { "?" boolean } }
{ $description "Tests if a string is in upper case." } ;

HELP: lower?
{ $values { "string" string } { "?" boolean } }
{ $description "Tests if a string is in lower case." } ;

HELP: title?
{ $values { "string" string } { "?" boolean } }
{ $description "Tests if a string is in title case." } ;

HELP: case-fold?
{ $values { "string" string } { "?" boolean } }
{ $description "Tests if a string is in case-folded form." } ;
