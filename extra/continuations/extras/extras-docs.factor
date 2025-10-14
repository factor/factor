USING: arrays definitions help.markup help.syntax kernel math
prettyprint ;

IN: continuations.extras

HELP: with-datastacks
{ $values
    { "seq" array }
    { "quot" { $quotation ( ... -- ... ) } }
}
{ $description
    "Executes a quotation with inputs, preserving inputs and outputs"
    "Takes a quotation and a seq containing inputs for the quotation"
    "Returns a seq containing the inputs as well as any produced output"
    "Useful for checking the behaviour of words under different inputs"
}
{ $examples
    { $example
        "USING: continuations.extras math prettyprint ;" 
        "{ { 1 2 } { 3 4 } { 2 3 } { 1 4 } } [ + ] with-datastacks ."
"{
    { { 1 2 } { 3 } }
    { { 3 4 } { 7 } }
    { { 2 3 } { 5 } }
    { { 1 4 } { 5 } }
}"
    }
    { $example
        "! generating inputs using math.combinatorics"
        "USING: continuations.extras kernel math.combinatorics prettyprint ;" 
        "{ t f } 2 all-selections [ xor ] with-datastacks ."
"{
    { { t t } { f } }
    { { t f } { t } }
    { { f t } { t } }
    { { f f } { f } }
}"
    }
    { $example
        "! generating inputs using math.combinatorics and ranges"
        "USING: continuations.extras math math.combinatorics prettyprint ranges ;" 
        "4 [1..b] 2 all-combinations [ + ] with-datastacks ."
"{
    { { 1 2 } { 3 } }
    { { 1 3 } { 4 } }
    { { 1 4 } { 5 } }
    { { 2 3 } { 5 } }
    { { 2 4 } { 6 } }
    { { 3 4 } { 7 } }
}"
    }
} ;

HELP: datastack-states
{ $values
    { "stack" array }
    { "quot" { $quotation ( ... -- ... ) } }
    { "seq" array }
}
{ $description
    "Executes an array of words with an input, preserving intermediary values, "
    "taking a quotation and a seq containing inputs for the quotation. "
    "Will execute the words in the quotation and store any intermediary values into the outputted seq. "
    "Returns a seq containing the words executed as well as any produced output. "
    "Can be used together with " { $link simple-table. } " as a form of super simple printf-style debugging."
}
{ $examples
    { $example
        "USING: ascii continuations.extras kernel prettyprint sequences ;"
        "{ \"Hello World!\" } [ [ Letter? ] filter >lower dup reverse = ] datastack-states simple-table." 
"{ \"Hello World!\" }             [ Letter? ]
{ \"Hello World!\" ~quotation~ } filter
{ \"HelloWorld\" }               >lower
{ \"helloworld\" }               dup
{ \"helloworld\" \"helloworld\" }  reverse
{ \"helloworld\" \"dlrowolleh\" }  =

--- Data stack:
{ f }"
    }
} ;
