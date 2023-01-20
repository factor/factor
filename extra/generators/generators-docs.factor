! Copyright (C) 2023 Keldan Chapman.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math quotations sequences generators coroutines effects ;
IN: generators

HELP: <generator>
{ $values
    { "quot" quotation }
    { "gen" generator }
}
{ $description "Creates a generator object from an input quotation." } ;

HELP: ?next
{ $values
    { "gen" generator }
    { "val/f" { $maybe object } } { "end?" boolean }
}
{ $description "A safe version of " { $link next } ". Also returns a boolean indicating whether the end of the generator was reached." } ;

HELP: ?next*
{ $values
    { "v" object } { "gen" generator }
    { "val/f" { $maybe object } } { "end?" boolean }
}
{ $description "A safe version of " { $link next } ". Also returns a boolean indicating whether the end of the generator was reached." } ;

HELP: GEN:
{ $syntax "GEN: word ( stack -- generator ) definition... ;" }
{ $description "Creates a generator word in the current vocabulary. When executed, the word will capture its inputs from the stack and a generator object will be returned. The output of generator words must always be only a single value (the generator)." } ;

HELP: GEN::
{ $syntax "GEN:: word ( stack -- generator ) definition... ;" }
{ $description "Creates a generator word in the current vocabulary. When executed, the word's inputs will be captured from the stack and bound to them to lexical input variables from left to right. A generator object will be returned. The output of generator words must always be only a single value (the generator)." } ;


HELP: assert-no-inputs
{ $values
    { "quot" quotation }
}
{ $description "Throws a " { $link has-inputs } " error if the input quotation accepts inputs. Otherwise does nothing." } ;

HELP: catch-stop-generator
{ $values
    { "try" quotation } { "except" quotation }
}
{ $description "Attempts to run the " { $snippet try } " quotation. If a " { $link stop-generator } " error is thrown, then the " { $snippet except } "quotation will be run instead." } ;

HELP: exhausted?
{ $values
    { "gen" generator } { "?" boolean }
}
{ $description "Check whether a generator has already been exhausted." } ;

HELP: gen-coroutine
{ $values
    { "quot" quotation } { "gen" generator }
    { "co" coroutine }
}
{ $description "Builds a coroutine from a quotation for use in a generator object. On termination of the quotation, the generator object will be marked as complete." } ;

HELP: generator
{ $class-description "A simplified coroutine which produces values as needed. " { $link stop-generator } " is thrown when no more values can be produced." } ;

HELP: has-inputs
{ $description "Throws a " { $link has-inputs } " error." }
{ $error-description "Indicates that a quotation incorrectly expects inputs." } ;

HELP: make-gen-quot
{ $values
    { "quot" quotation } { "effect" effect }
}
{ $description "Prepares a quotation for use as a generator word." } ;

HELP: next
{ $values
    { "gen" generator }
    { "result" object }
}
{ $description "Resume computation in the generator until the next value is produced." } ;

HELP: next*
{ $values
    { "v" object } { "gen" generator }
    { "result" object }
}
{ $description "Pass a value into the generator, resuming computation until a value is produced." } ;

HELP: skip
{ $values
    { "gen" generator }
}
{ $description "Resume computation until a value is produced. The value is discarded." } ;

HELP: skip*
{ $values
    { "v" object } { "gen" object }
}
{ $description "Pass a value into the generator, resuming computation until a value is produced. The value is discarded." } ;

HELP: stop-generator
{ $description "Throws a " { $link stop-generator } " error." }
{ $error-description "Indicates that the generator has run out of values to produce" } ;

HELP: take
{ $values
    { "gen" generator } { "n" integer }
    { "seq" sequence }
}
{ $description "Takes the next " { $snippet n } " values from the generator, collecting them into a sequence." } ;

HELP: take-all
{ $values
    { "gen" generator }
    { "seq" sequence }
}
{ $description "Runs the generator until completion, collecting all yielded values into a sequence." } ;

HELP: yield
{ $values
    { "v" object }
}
{ $description "Pause computation and yield a value to the caller." } ;

HELP: yield*
{ $values
    { "v" object }
    { "result" object }
}
{ $description "Pause computation and yield a value to the caller, with the expectation for a value to be returned before computation is resumed." } ;

HELP: yield-from
{ $values
    { "gen" generator }
}
{ $description "Delegate computation to the specified generator until it is exhausted, before resuming computation in the current generator." } ;

ARTICLE: "generators" "Generators"
{ $vocab-link "generators" }
;

ABOUT: "generators"
