USING: help.markup help.syntax io math strings ;
IN: interpolate

HELP: interpolate
{ $values { "str" string } }
{ $description "String interpolation using named variables and/or stack arguments, writing to the " { $link output-stream } ". Format directives from the " { $vocab-link "formatting" } " vocabulary can be used as well." }
{ $notes "Stack arguments are numbered from the top of the stack, or provided anonymously by order of arguments." }
{ $examples
    { $example
        "USING: interpolate ;"
        "\"Bob\" \"Alice\" \"Hi ${1}, it's ${0}.\" interpolate"
        "Hi Bob, it's Alice."
    }
    { $example
        "USING: interpolate namespaces ;"
        "\"Fred\" \"name\" [ \"Hi ${name}\" interpolate ] with-variable"
        "Hi Fred"
    }
    { $example
        "USING: interpolate ;"
        "\"Mr.\" \"Anderson\"" "\"Hello, ${} ${}\" interpolate"
        "Hello, Mr. Anderson"
    }
    { $example
        "USING: interpolate ;"
        "1.2345 \"${:011.5f}\" interpolate"
        "00001.23450"
    }
} ;

HELP: interpolate>string
{ $values { "str" string } { "newstr" string } }
{ $description "String interpolation using named variables and/or stack arguments, captured as a " { $link string } "." }
{ $notes "Stack arguments are numbered from the top of the stack, or provided anonymously by order of arguments." } ;

{ interpolate interpolate>string } related-words
