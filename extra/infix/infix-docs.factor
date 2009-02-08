USING: help.syntax help.markup prettyprint locals ;
IN: infix

HELP: [infix
{ $syntax "[infix ... infix]" }
{ $description "Parses the infix code inside the brackets, converts it to stack code and executes it." }
{ $examples
    { $example
        "USING: infix prettyprint ;"
        "IN: scratchpad"
        "[infix 8+2*3 infix] ."
        "14"
    } $nl
    { $link POSTPONE: [infix } " isn't that useful by itself, as it can only access literal numbers and no variables. It is designed to be used together with locals; for example with " { $link POSTPONE: :: } " :"
    { $example
        "USING: infix locals math.functions prettyprint ;"
        "IN: scratchpad"
        ":: quadratic-equation ( a b c -- z- z+ )"
        "    [infix (-b-sqrt(b*b-4*a*c)) / (2*a) infix]"
        "    [infix (-b+sqrt(b*b-4*a*c)) / (2*a) infix] ;"
        "1 0 -1 quadratic-equation . ."
        "1.0\n-1.0"
    }
} ;

HELP: [infix|
{ $syntax "[infix| binding1 [ value1... ]\n        binding2 [ value2... ]\n        ... |\n    infix-expression infix]" }
{ $description "Introduces a set of lexical bindings and evaluates the body as a snippet of infix code. The values are evaluated in parallel, and may not refer to other bindings within the same " { $link POSTPONE: [infix| } " form, as it is based on " { $link POSTPONE: [let } "." }
{ $examples
    { $example
        "USING: infix prettyprint ;"
        "IN: scratchpad"
        "[infix| pi [ 3.14 ] r [ 12 ] | r*r*pi infix] ."
        "452.16"
    }
} ;

{ POSTPONE: [infix POSTPONE: [infix| } related-words
