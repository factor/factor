USING: arrays help.markup help.syntax kernel math ;
IN: test-word

HELP: gather-results
{ $values 
    { "seq" array } 
    { $quotation ( ... -- ... ) } 
    { "seq" array } 
}
{ $description
    "Executes a quotation with inputs, preserving inputs and outputs"
    "Takes a quotation and a seq containing inputs for the quotation"
    "Returns a seq containing the inputs as well as any produced output"
    "Useful for checking the behaviour of words under different inputs"
}
{ $examples
    { $example
        "USING: test-word math prettyprint ;" 
        "{ { 1 2 } { 3 4 } { 2 3 } { 1 4 } } [ + ] gather-results ."
"{
    { { 1 2 } { 3 } }
    { { 3 4 } { 7 } }
    { { 2 3 } { 5 } }
    { { 1 4 } { 5 } }
}"
    }
    { $example
        "! generating inputs using math.combinatorics"
        "USING: test-word math math.combinatorics prettyprint ;" 
        "{ t f } 2 all-selections [ xor ] gather-results ."
"{
    { { t t } { f } }
    { { t f } { t } }
    { { f t } { t } }
    { { f f } { f } }
}"
    }
    { $example
        "! generating inputs using math.combinatorics and math.ranges"
        "USING: test-word math math.combinatorics math.ranges prettyprint ;" 
        "4 [1..b] 2 all-combinations [ + ] gather-results ."
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

HELP: gather-intermediates
{ $values 
    { "stack" array } 
    { $quotation ( ... -- ... ) } 
    { "stack" array } 
    { "seq" array } 
}
{ $description
    "Executes an array of words with an input, preserving intermediary values \n"
    "Takes an array of words and a seq containing inputs for the quotation \n"
    "The array of words can be produced with " { $link definition } ".\n"
    "For example:" { $code "\\ palindrome? definition" } "\n"
    "gather-intermediates will execute the words in the array and store any intermediary values into the outputted seq \n"
    "Returns a seq containing the words executed as well as any produced output \n"
    "Can be used together with " { $link simple-table. } " as a form of super simple printf debugging. \n"
}
{ $examples
    { $example
        "USE: ascii"
        ": palindrome? ( string -- ? ) [ Letter? ] filter >lower dup reverse = ;"
        "{ \"Hello World!\" } \\ palindrome? definition gather-intermediates simple-table." 
"{ \"Hello World!\" }             [ Letter? ]
{ \"Hello World!\" ~quotation~ } filter
{ \"HelloWorld\" }               >lower
{ \"helloworld\" }               dup
{ \"helloworld\" \"helloworld\" }  reverse
{ \"helloworld\" \"dlrowolleh\" }  ="
    }
} ;

ABOUT: "gather-results"
