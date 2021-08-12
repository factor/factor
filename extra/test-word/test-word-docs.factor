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
    { $unchecked-example
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

ABOUT: "test-word"
