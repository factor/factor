
USING: help.syntax help.markup kernel prettyprint sequences strings ;

IN: time

HELP: strftime
{ $values { "format-string" string } }
{ $description "Writes the timestamp (specified on the stack) formatted according to the format string." } 
;

ARTICLE: "strftime" "Formatted timestamps"
"The " { $vocab-link "time" } " vocabulary is used for formatted timestamps.\n"
{ $subsection strftime }
"\n"
"Several format specifications exist for handling arguments of different types, and specifying attributes for the result string, including such things as maximum width, padding, and decimals.\n"
{ $table
    { "%a"     "Abbreviated weekday name." }
    { "%A"     "Full weekday name." }
    { "%b"     "Abbreviated month name." }
    { "%B"     "Full month name." }
    { "%c"     "Date and time representation." }
    { "%d"     "Day of the month as a decimal number [01,31]." }
    { "%H"     "Hour (24-hour clock) as a decimal number [00,23]." }
    { "%I"     "Hour (12-hour clock) as a decimal number [01,12]." }
    { "%j"     "Day of the year as a decimal number [001,366]." }
    { "%m"     "Month as a decimal number [01,12]." }
    { "%M"     "Minute as a decimal number [00,59]." }
    { "%p"     "Either AM or PM." }
    { "%S"     "Second as a decimal number [00,59]." }
    { "%U"     "Week number of the year (Sunday as the first day of the week) as a decimal number [00,53]." }
    { "%w"     "Weekday as a decimal number [0(Sunday),6]." }
    { "%W"     "Week number of the year (Monday as the first day of the week) as a decimal number [00,53]." }
    { "%x"     "Date representation." }
    { "%X"     "Time representation." }
    { "%y"     "Year without century as a decimal number [00,99]." }
    { "%Y"     "Year with century as a decimal number." }
    { "%Z"     "Time zone name (no characters if no time zone exists)." }
    { "%%"     "A literal '%' character." }
} ;

ABOUT: "strftime"


