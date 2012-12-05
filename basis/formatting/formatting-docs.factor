
USING: help.syntax help.markup kernel prettyprint sequences strings ;

IN: formatting

HELP: printf
{ $values { "format-string" string } }
{ $description 
    "Writes the arguments (specified on the stack) formatted according to the format string.\n" 
    $nl
    "Several format specifications exist for handling arguments of different types, and "
    "specifying attributes for the result string, including such things as maximum width, "
    "padding, and decimals.\n"
    { $table
        { "%%"          "Single %"                   "" }
        { "%P.Ds"       "String format"              "string" }
        { "%P.DS"       "String format uppercase"    "string" }
        { "%c"          "Character format"           "char" } 
        { "%C"          "Character format uppercase" "char" } 
        { "%+Pd"        "Integer format"             "fixnum" }
        { "%+P.De"      "Scientific notation"        "fixnum, float" }
        { "%+P.DE"      "Scientific notation"        "fixnum, float" }
        { "%+P.Df"      "Fixed format"               "fixnum, float" }
        { "%+Px"        "Hexadecimal"                "hex" }
        { "%+PX"        "Hexadecimal uppercase"      "hex" }
        { "%[%?, %]"    "Sequence format"            "sequence" }
        { "%[%?: %? %]" "Assocs format"              "assocs" }
    }
    $nl
    "A plus sign ('+') is used to optionally specify that the number should be "
    "formatted with a '+' preceeding it if positive.\n"
    $nl
    "Padding ('P') is used to optionally specify the minimum width of the result "
    "string, the padding character, and the alignment.  By default, the padding "
    "character defaults to a space and the alignment defaults to right-aligned. "
    "For example:\n"
    { $list
        "\"%5s\" formats a string padding with spaces up to 5 characters wide."
        "\"%03d\" formats an integer padding with zeros up to 3 characters wide."
        "\"%'#5f\" formats a float padding with '#' up to 3 characters wide."
        "\"%-10d\" formats an integer to 10 characters wide and left-aligns." 
    }
    $nl
    "Digits ('D') is used to optionally specify the maximum digits in the result "
    "string. For example:\n"
    { $list 
        "\"%.3s\" formats a string to truncate at 3 characters (from the left)."
        "\"%.10f\" formats a float to pad-tail with zeros up to 10 digits beyond the decimal point."
        "\"%.5E\" formats a float into scientific notation with zeros up to 5 digits beyond the decimal point, but before the exponent."
    }
}
{ $examples 
    { $example
        "USING: formatting ;"
        "123 \"%05d\" printf"
        "00123" }
    { $example
        "USING: formatting ;"
        "0xff \"%04X\" printf"
        "00FF" }
    { $example
        "USING: formatting ;"
        "1.23456789 \"%.3f\" printf"
        "1.235" }
    { $example
        "USING: formatting ;"
        "12 \"%'#4d\" printf"
        "##12" }
    { $example
        "USING: formatting ;"
        "1234 \"%+d\" printf"
        "+1234" }
    { $example
        "USING: formatting ;"
        "{ 1 2 3 } \"%[%d, %]\" printf"
        "{ 1, 2, 3 }" }
    { $example
        "USING: formatting ;"
        "H{ { 1 2 } { 3 4 } } \"%[%d: %d %]\" printf"
        "{ 1:2, 3:4 }" }
} ;

HELP: sprintf
{ $values { "format-string" string } { "result" string } }
{ $description "Returns the arguments (specified on the stack) formatted according to the format string as a result string." } 
{ $see-also printf } ;

HELP: strftime
{ $values { "format-string" string } }
{ $description 
    "Writes the timestamp (specified on the stack) formatted according to the format string.\n"
    $nl
    "Different attributes of the timestamp can be retrieved using format specifications.\n"
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
    } 
} 
{ $examples 
    { $unchecked-example
        "USING: calendar formatting io ;"
        "now \"%c\" strftime print"
        "Mon Dec 15 14:40:43 2008" }
} ;

ARTICLE: "formatting" "Formatted printing"
"The " { $vocab-link "formatting" } " vocabulary is used for formatted printing."
{ $subsections
    printf
    sprintf
    strftime
} ;

ABOUT: "formatting"


