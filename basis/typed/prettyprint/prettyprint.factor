USING: definitions kernel locals.definitions see see.private typed
words summary make accessors classes prettyprint ;
IN: typed.prettyprint

PREDICATE: typed-lambda-word < lambda-word
    "typed-word" word-prop >boolean ;

M: typed-word definer drop \ TYPED: \ ; ;
M: typed-lambda-word definer drop \ TYPED:: \ ; ;

M: typed-word definition "typed-def" word-prop ;
M: typed-word declarations. "typed-word" word-prop declarations. ;

M: input-mismatch-error summary
    [
        "Typed word '" %
        dup word>> name>> %
        "' expected input value of type " %
        dup expected-type>> unparse %
        " but got " %
        dup value>> class-of name>> %
        drop
    ] "" make ;

M: output-mismatch-error summary
    [
        "Typed word '" %
        dup word>> name>> %
        "' expected to output value of type " %
        dup expected-type>> name>> %
        " but gave " %
        dup value>> class-of name>> %
        drop
    ] "" make ;
