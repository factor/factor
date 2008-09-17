
USING: help.syntax help.markup kernel prettyprint sequences strings ;

IN: printf

HELP: printf
{ $values { "format-string" string } }
{ $description 
    "Writes the arguments formatted according to the format string." 
    { $table
        { "%%"    "Single %" "" }
        { "%Wd"   "Integer W digits wide (e.g., \"1234\")"  "fixnum" }
        { "%W.De" "Scientific notation" "fixnum, float" }
        { "%W.DE" "Scientific notation" "fixnum, float" }
        { "%W.Df" "Fixed format" "fixnum, float" }
        { "%Wx"   "Hexadecimal" "hex" }
        { "%WX"   "Hexadecimal uppercase" "hex" }
        { "%W.Ds" "String format" "string" }
        { "%W.DS" "String format uppercase" "string" }
        { "%c"    "Character format" "char" } 
        { "%C"    "Character format uppercase" "char" } 
    }
} 
{ $examples 
    { $example
        "USING: printf ;"
        "{ 123 } \"%05d\" printf"
        "00123" }
    { $example
        "USING: printf ;"
        "{ HEX: ff } \"04X\" printf"
        "00FF" }
    { $example
        "USING: printf ;"
        "{ 1.23456789 } \"%.3f\" printf"
        "1.234" }
    { $example 
        "USING: printf ;"
        "{ 1234567890 } \"%.5e\" printf"
        "1.23456e+09" }
} ;

HELP: sprintf
{ $values { "params" sequence } { "format-string" string } { "result" string } }
{ $description "Returns the arguments formatted according to the format string as a result string." } 
{ $see-also printf } ;

