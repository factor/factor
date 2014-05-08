USING: help.markup help.syntax sequences words ;
IN: tools.help-lint.checks

HELP: check-example
{ $values { "element" sequence } }
{ $description "Throws an error if the expected output from the $example is different from the expected, or if it leaks disposables." }
{ $examples
  { $example
    "USING: continuations help.markup prettyprint tools.help-lint.checks ;"
    "[ { $example \"USING: io ; \\\"hello\\\" print\" \"goodbye\" } check-example ] [ ] recover ."
    "T{ assert { got \"hello\" } { expect \"goodbye\" } }"
  }
} ;

HELP: check-values
{ $values { "word" word } { "element" sequence } }
{ $description "Throws an error if the $values pair doesnt match the declared stack effect." }
{ $examples
  { $unchecked-example
    "USING: tools.help-lint.checks math ;"
    ": foo ( x -- y ) ;"
    "\\ foo { $values { \"a\" number } { \"b\" number } } check-values"
    "$values don't match stack effect; expected { \"x\" \"y\" }, got { \"a\" \"b\" }\n\nType :help for debugging help."
    }
} ;
