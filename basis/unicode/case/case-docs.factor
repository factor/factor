USING: help.syntax help.markup ;
IN: unicode.case

ABOUT: "unicode.case"

ARTICLE: "unicode.case" "Case mapping"
"When considering Unicode in general and not just ASCII or a smaller character set, putting a string in upper case, title case or lower case is slightly more complicated. In most contexts it's best to use the general Unicode routines for case conversion. There is an additional type of casing, case-fold, which is defined as bringing a string into upper case and then lower. This exists because in some cases it is different from simple lower case."
{ $subsection >upper }
{ $subsection >lower }
{ $subsection >title }
{ $subsection >case-fold }
"To test if a string is in a given case:"
{ $subsection upper? }
{ $subsection lower? }
{ $subsection title? }
{ $subsection case-fold? }
"For certain languages (Turkish, Azeri, Lithuanian), case mapping is dependent on locale; To change this, set the following variable to the ISO-639-1 code for your language:"
{ $subsection locale }
"This is unnecessary for most languages." ;
