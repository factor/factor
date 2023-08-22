! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.xo
USING: arrays calendar help.markup help.syntax kernel math strings ;
IN: calendar.english

HELP: month-names
{ $values { "value" object } }
{ $description "Returns an array with the English names of all the months." }
{ $warning "Do not use this array for looking up a month name directly. Use " { $link month-name } " instead." } ;

HELP: month-name
{ $values { "obj" { $or integer timestamp } } { "string" string } }
{ $description "Looks up the month name and returns it as a string. January has an index of 1 instead of zero." } ;

HELP: month-abbreviations
{ $values { "value" array } }
{ $description "Returns an array with the English abbreviated names of all the months." }
{ $warning "Do not use this array for looking up a month name directly. Use " { $link month-abbreviation } " instead." } ;

HELP: month-abbreviation
{ $values { "n" integer } { "string" string } }
{ $description "Looks up the abbreviated month name and returns it as a string. January has an index of 1 instead of zero." } ;

HELP: day-names
{ $values { "value" array } }
{ $description "Returns an array with the English names of the days of the week." } ;

HELP: day-name
{ $values { "obj" { $or integer timestamp } } { "string" string } }
{ $description "Looks up the day name and returns it as a string." } ;

HELP: day-abbreviations2
{ $values { "value" array } }
{ $description "Returns an array with the abbreviated English names of the days of the week. This abbreviation is two characters long." } ;

HELP: day-abbreviation2
{ $values { "n" integer } { "string" string } }
{ $description "Looks up the abbreviated day name and returns it as a string. This abbreviation is two characters long." } ;

HELP: day-abbreviations3
{ $values { "value" array } }
{ $description "Returns an array with the abbreviated English names of the days of the week. This abbreviation is three characters long." } ;

HELP: day-abbreviation3
{ $values { "n" integer } { "string" string } }
{ $description "Looks up the abbreviated day name and returns it as a string. This abbreviation is three characters long." } ;

{
    day-name day-names
    day-abbreviation2 day-abbreviations2
    day-abbreviation3 day-abbreviations3
} related-words

ARTICLE: "months" "Month names in English"
"Naming months:"
{ $subsections
    month-name
    month-names
    month-abbreviation
    month-abbreviations
} ;

ARTICLE: "days" "Day names in English"
"Naming days:"
{ $subsections
    day-abbreviation2
    day-abbreviations2
    day-abbreviation3
    day-abbreviations3
    day-name
    day-names
} ;
