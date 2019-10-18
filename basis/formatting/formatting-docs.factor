USING: assocs help.markup help.syntax kernel math prettyprint
sequences strings ;

IN: formatting

HELP: printf
{ $values { "format-string" string } }
{ $description
    "Writes the arguments (specified on the stack) formatted according to the format string."
    $nl
    "Several format specifications exist for handling arguments of different types, and "
    "specifying attributes for the result string, including such things as maximum width, "
    "padding, and decimals."
    $nl
    { $table
        { { $snippet "%%" }          "Single %" "" }
        { { $snippet "%P.Ds" }       "String" { $link string } }
        { { $snippet "%P.DS" }       "String uppercase" { $link string } }
        { { $snippet "%P.Du" }       "Unparsed" { $link object } }
        { { $snippet "%c" }          "Character" "char" }
        { { $snippet "%C" }          "Character uppercase" "char" }
        { { $snippet "%LPd" }        "Integer decimal (base 10)" { $link real } }
        { { $snippet "%LPx" }        "Integer hexadecimal (base 16)" { $link real } }
        { { $snippet "%LPX" }        "Integer hexadecimal uppercase (base 16)" { $link real } }
        { { $snippet "%LPo" }        "Integer octal (base 8)" { $link real } }
        { { $snippet "%LPb" }        "Integer binary (base 2)" { $link real } }
        { { $snippet "%LP.De" }      "Scientific (base 10)" { $link real } }
        { { $snippet "%LP.DE" }      "Scientific uppercase (base 10)" { $link real } }
        { { $snippet "%LP.Df" }      "Fixed (base 10)" { $link real } }
        { { $snippet "%[%?, %]" }    "Sequence" { $link sequence } }
        { { $snippet "%[%?: %? %]" } "Assocs" { $link assoc } }
    }
    $nl
    "Leading (" { $snippet "L" } ") is used to optionally prefix a plus sign (" { $snippet "\"+\"" } ") or space (" { $snippet "\" \"" } ") "
    "if the formatted number is positive."
    $nl
    "Padding (" { $snippet "P" } ") is used to optionally specify the minimum width of the result "
    "string, the padding character, and the alignment. By default, the padding "
    "character defaults to a space and the alignment defaults to right-aligned. "
    "For example:"
    $nl
    { $list
        { { $snippet "%5s" } " formats a string padding with spaces up to 5 characters wide." }
        { { $snippet "%03d" } " formats an integer padding with zeros up to 3 characters wide." }
        { { $snippet "%'#10f" } " formats a float padding with " { $snippet "#" } " up to 10 characters wide." }
        { { $snippet "%-10d" } " formats an integer to 10 characters wide and left-aligns." }
    }
    $nl
    "Digits (" { $snippet "D" } ") is used to optionally specify the maximum digits in the result "
    "string. For example:"
    $nl
    { $list
        { { $snippet "%.3s" } " formats a string to truncate at 3 characters (from the left)." }
        { { $snippet "%.10f" } " formats a float to pad-tail with zeros up to 10 digits beyond the decimal point." }
        { { $snippet "%.5E" } " formats a float into scientific notation with zeros up to 5 digits beyond the decimal point, but before the exponent." }
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
        "12 \"%b\" printf"
        "1100" }
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
        " 1234 \"%+d\\n\" printf"
        "-1234 \"%+d\\n\" printf"
        " 1234 \"% d\\n\" printf"
        "+1234\n-1234\n 1234" }
    { $example
        "USING: formatting ;"
        "{ 1 2 3 } \"%[%d, %]\" printf"
        "{ 1, 2, 3 }" }
    { $example
        "USING: formatting ;"
        "H{ { 1 2 } { 3 4 } } \"%[%d: %d %]\" printf"
        "{ 1:2, 3:4 }" }
    { $example
      "USING: calendar formatting ;"
      "3 years \"%u\" printf"
      "T{ duration { year 3 } }" }
} ;

HELP: sprintf
{ $values { "format-string" string } { "result" string } }
{ $description "Returns the arguments (specified on the stack) formatted according to the format string as a result string." }
{ $see-also printf } ;

HELP: strftime
{ $values { "format-string" string } }
{ $description
    "Writes the timestamp (specified on the stack) formatted according to the format string."
    $nl
    "Different attributes of the timestamp can be retrieved using format specifications."
    $nl
    { $table
        { { $snippet "%a" }    "Abbreviated weekday name." }
        { { $snippet "%A" }    "Full weekday name." }
        { { $snippet "%b" }    "Abbreviated month name." }
        { { $snippet "%B" }    "Full month name." }
        { { $snippet "%c" }    "Date and time representation." }
        { { $snippet "%d" }    "Day of the month as a decimal number [01,31]." }
        { { $snippet "%H" }    "Hour (24-hour clock) as a decimal number [00,23]." }
        { { $snippet "%I" }    "Hour (12-hour clock) as a decimal number [01,12]." }
        { { $snippet "%j" }    "Day of the year as a decimal number [001,366]." }
        { { $snippet "%m" }    "Month as a decimal number [01,12]." }
        { { $snippet "%M" }    "Minute as a decimal number [00,59]." }
        { { $snippet "%p" }    "Either AM or PM." }
        { { $snippet "%S" }    "Second as a decimal number [00,59]." }
        { { $snippet "%U" }    "Week number of the year (Sunday as the first day of the week) as a decimal number [00,53]." }
        { { $snippet "%w" }    "Weekday as a decimal number [0(Sunday),6]." }
        { { $snippet "%W" }    "Week number of the year (Monday as the first day of the week) as a decimal number [00,53]." }
        { { $snippet "%x" }    "Date representation." }
        { { $snippet "%X" }    "Time representation." }
        { { $snippet "%y" }    "Year without century as a decimal number [00,99]." }
        { { $snippet "%Y" }    "Year with century as a decimal number." }
        { { $snippet "%Z" }    "Time zone name (no characters if no time zone exists)." }
        { { $snippet "%%" }    "A literal '%' character." }
    }
}
{ $examples
    { $unchecked-example
        "USING: calendar formatting io ;"
        "now \"%c\" strftime print"
        "Mon Dec 15 14:40:43 2008" }
} ;

ARTICLE: "formatting" "Formatted printing"
"The " { $vocab-link "formatting" } " vocabulary is used for english formatted printing."
{ $subsections
    printf
    sprintf
    strftime
} ;

ABOUT: "formatting"
