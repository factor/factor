USING: help.markup help.syntax ;
IN: state-parser

ABOUT: { "state-parser" "main" }

ARTICLE: { "state-parser" "main" } "State-based parsing"
    "This module defines a state-based parsing mechanism. It was originally created for libs/xml, but is also used in libs/csv and can be easily used in new libraries or applications."
    { $subsection spot }
    { $subsection skip-until }
    { $subsection take-until }
    { $subsection take-char }
    { $subsection take-string }
    { $subsection next }
    { $subsection state-parse }
    { $subsection get-char }
    { $subsection rest }
    { $subsection string-parse }
    { $subsection expect }
    { $subsection expect-string }
    { $subsection parsing-error } ;

HELP: get-char
{ $values { "char" "the current character" } }
{ $description "Accesses the current character of the stream that is being parsed" } ;

HELP: rest
{ $values { "string" "the rest of the parser input" } }
{ $description "Exausts the stream of the parser input and returns a string representing the rest of the input" } ;

HELP: string-parse
{ $values { "input" "a string" } { "quot" "a quotation ( -- )" } }
{ $description "Calls the given quotation using the given string as parser input" }
{ $see-also state-parse } ;

HELP: expect
{ $values { "ch" "a number representing a character" } }
{ $description "Asserts that the current character is the given ch, and moves to the next spot" }
{ $see-also expect-string } ;

HELP: expect-string
{ $values { "string" "a string" } }
{ $description "Asserts that the current parsing spot is followed by the given string, and skips the parser past that string" }
{ $see-also expect } ;

HELP: spot
{ $var-description "This variable represents the location in the program. It is a tuple T{ spot f char column line next } where char is the current character, line is the line number, column is the column number, and line-str is the full contents of the line, as a string. The contents shouldn't be accessed directly but rather with the proxy words get-char set-char get-line etc." } ;

HELP: skip-until
{ $values { "quot" "a quotation ( -- ? )" } }
{ $description "executes " { $link next } " until the quotation yields false. Usually, the quotation will call " { $link get-char } " in its test, but not always." }
{ $see-also take-until } ;

HELP: take-until
{ $values { "quot" "a quotation ( -- ? )" } { "string" "a string" } }
{ $description "like " { $link skip-until } " but records what it passes over and outputs the string." }
{ $see-also skip-until take-char take-string } ;

HELP: take-char
{ $values { "ch" "a character" } { "string" "a string" } }
{ $description "records the document from the current spot to the first instance of the given character. Outputs the content between those two points." }
{ $see-also take-until take-string } ;

HELP: take-string
{ $values { "match" "a string to match" } { "string" "the portion of the XML document" } }
{ $description "records the document from the current spot to the first instance of the given character. Outputs the content between those two points." }
{ $notes "match may not contain a newline" } ;

HELP: next
{ $description "originally written as " { $code "spot inc" } ", code that would no longer run, this word moves the state of the XML parser to the next place in the source file, keeping track of appropriate debugging information." } ;

HELP: parsing-error
{ $class-description "class to which parsing errors delegate, containing information about which line and column the error occured on, and what the line was. Contains three slots, line, an integer, column, another integer, and line-str, a string" } ;
