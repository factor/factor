USING: arrays help.markup help.syntax kernel math ;
IN: test-word

HELP: test-word
{ $values 
    { "seq" array } 
    { $quotation ( ... -- ... ) } 
    { "seq" array } 
}
{ $description
    "Executes a quote with inputs, preserving inputs and outputs"
    "Takes a quote and a seq containing inputs for the quote"
    "Returns a seq containing the inputs as well as any produced output"
    "Useful for checking the behaviour of words under different inputs"
}
{ $examples
    { $example
        "USING: test-word math prettyprint ;" 
        "{ { 1 2 } { 3 4 } { 2 3 } { 1 4 } } [ + ] test-word ."
"{
    { { 1 2 } { 3 } }
    { { 3 4 } { 7 } }
    { { 2 3 } { 5 } }
    { { 1 4 } { 5 } }
}"
    }
} ;

HELP: before-word
{ $values 
    { "stack" array } 
    { $quotation ( ... -- ... ) } 
    { "stack" array } 
    { "seq" array } 
}
{ $description
    "Executes an array of words with an input, preserving intermediary values \n"
    "Takes an array of words and a seq containing inputs for the quote \n"
    "The array of words can be produced with " { $link definition } ".\n"
    "For example:" { $code "\\ palindrome? definition" } "\n"
    "before-after will execute the words in the array and store any intermediary values into the outputted seq \n"
    "Returns a seq containing the words executed as well as any produced output \n"
    "Can be used together with " { $link simple-table. } " as a form of super simple printf debugging. \n"
}
{ $examples
    { $example
        "USE: ascii"
        ": palindrome? ( string -- ? ) [ Letter? ] filter >lower dup reverse = ;"
        "{ \"Hello World!\" } \\ palindrome? definition before-after simple-table." 
"{ \"Hello World!\" }             [ Letter? ]
{ \"Hello World!\" ~quotation~ } filter
{ \"HelloWorld\" }               >lower
{ \"helloworld\" }               dup
{ \"helloworld\" \"helloworld\" }  reverse
{ \"helloworld\" \"dlrowolleh\" }  ="
    }
} ;

ABOUT: "test-word"
