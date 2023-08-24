! Copyright (C) 2023 Aleksander Sabak.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel sequences strings urls ;
IN: brain-flak

HELP: unclosed-brain-flak-expression
{ $values
    { "program" object }
}
{ $description "Throws an " { $link unclosed-brain-flak-expression } " error." }
{ $error-description "Thrown during brain-flak compilation if an opened subexpression doesn't have a closing bracket."
} ;

HELP: mismatched-brain-flak-brackets
{ $values
    { "program" object } { "character" object }
}
{ $description "Throws an " { $link mismatched-brain-flak-brackets } " error." }
{ $error-description "Thrown if a bracket is closed with a bracket that doesn't match." } ;

HELP: leftover-program-after-compilation
{ $values
    { "program" object } { "leftover" object }
}
{ $description "Throws an " { $link leftover-program-after-compilation } " error." }
{ $error-description "Thrown if excessive closing brackets are encountered during compilation." } ;


HELP: <brain-flak>
{ $values
    { "seq" sequence }
    { "state" brain-flak }
}
{ $description "Creates a new brain-flak state with a clone of " { $snippet "seq" } " as initial active stack." }
{ $see-also with-brain-flak } ;

HELP: brain-flak
{ $class-description "The class of tuples holding states of brain-flak execution to be operated on by compiled brain-flak programs." }
{ $see-also POSTPONE: b-f" compile-brain-flak <brain-flak> } ;

HELP: with-brain-flak
{ $values
    { "seq" sequence } { "q" { $quotation ( ..A s -- ..B s' ) } }
    { "seq'" sequence }
}
{ $description "Wrapper around quotations transforming a brain-flak state. Creates a new" { $link brain-flak } "instance from " { $snippet "seq" } ", runs " { $snippet "q" } " on it and extracts the final active stack into a new sequence of the same type as " { $snippet "seq" } "." }
{ $examples
    { $example
        "USING: kernel brain-flak prettyprint ;"
        "\"({{}})\" compile-brain-flak"
        "{ 2 1 3 7 } [ swap call( state -- state' ) ] with-brain-flak ."
        "{ 13 }"
    }
    { $example
        "USING: brain-flak prettyprint ;"
        "{ 1 2 } [ b-f\"(({}({}))[({}[{}])])\" ] with-brain-flak ."
        "{ 2 1 }"
    }
}
{ $see-also <brain-flak> } ;

HELP: b-f"
{ $syntax "b-f\"({}[]){<>()}\"" }
{ $description "Syntax for a brain-flak program. It will run on a" { $link brain-flak } "state object. Syntax and semantics of brain-flak are explained in" { $link "brain-flak" } .
}
{ $errors "Throws an error when the parsed string is not a correct brain-flak program" }
{ $examples
    { $example
        "USING: accessors brain-flak prettyprint ;"
        "{ 2 1 3 7 } <brain-flak> b-f\"({{}})\" active>> ."
        "V{ 13 }"
    }
    { $example
        "USING: brain-flak prettyprint ;"
        "{ 1 2 } [ b-f\"(({}({}))[({}[{}])])\" ] with-brain-flak ."
        "{ 2 1 }"
    }
}
{ $see-also compile-brain-flak with-brain-flak } ;

HELP: compile-brain-flak
{ $values
    { "string" string }
    { "quote" { $quotation ( state -- state ) } }
}
{ $description
        "Compiles a brain-flak program in" { $snippet "string" } "into a quotation that can be run on a" { $link brain-flak } "state object. Syntax and semantics of brain-flak are explained in" { $link "brain-flak" } "."
}
{ $errors "Throws an error when the string is not a correct brain-flak program" }
{ $examples
    { $example
        "USING: accessors brain-flak kernel prettyprint ;"
        "\"({{}})\" compile-brain-flak"
        "{ 2 1 3 7 } <brain-flak> swap call( state -- state' ) active>> ."
        "V{ 13 }"
    }
    { $example
        "USING: brain-flak kernel prettyprint ;"
        "\"(({}({}))[({}[{}])])\" compile-brain-flak"
        "{ 1 2 } [ swap call( state -- state' ) ] with-brain-flak ."
        "{ 2 1 }"
    }
}
{ $see-also POSTPONE: b-f" with-brain-flak } ;

ARTICLE: "brain-flak" "Introduction to brain-flak"
{ { $url URL"https://esolangs.org/wiki/Brain-Flak" "Brain-flak" } " is a stack-based esoteric language designed by Programming Puzzles and Code-Golf user " { $url URL"https://codegolf.stackexchange.com/users/31716/djmcmayhem" "DjMcMayhem" } } . The name is a cross between " \"brainfuck\" " , which was a big inspiration for the language, and " \"flak-overstow\" " , since the language is confusing and stack-based.

{ $heading "Overview" }
Brain-flak is an expression-based language written only using brackets, which must be balanced. Any other character will be ignored. Its only data type is a signed integer, which in this implementation has unbounded size.
{ $nl }
There are two stacks, one of which is considered the { $strong "active" } stack at each point of the execution. Programs start with the active stack initialised with the input data and inactive stack empty, and return the active stack when finished. Popping from an empty stack yields 0.
{ $nl }
Each expression in brain-flak executes some side-effects on the stacks and evaluates to a number. Concatenation of expressions performs their side-effects from left to right and evaluates to a sum of their evaluations.

{ $heading "Functions" }
There are two types of functions in brain-flak: nilads, that are brackets without any contents, and monads, which are non-empty bracketed subexpressions.
{ $nl }
Nilads:
{ $list
    { { $snippet "()" } " evaluates to 1" }
    { { $snippet "[]" } " evaluates to the height of the active stack" }
    { { $snippet "{}" } " pops the active stack and evaluates to the popped value" }
    { { $snippet "<>" } " swaps active and inactive stack and evaluates to 0" }
}
Recall that concatenating expressions sums their values, so { $snippet "()()()" } will evaluate to 3, and { $snippet "{}()" } will pop from the active stack and evaluate to one more than the popped value.
{ $nl }
Monads:
{ $list
    { { $snippet "(X)" } " evaluates " { $snippet "X" } ", pushes the result on the stack and evaluates to the same value" }
    { { $snippet "[X]" } " evaluates " { $snippet "X" } " and evaluates to its negation" }
    { { $snippet "{X}" } " evaluates " { $snippet "X" } " in a loop as long as top of the active stack is not 0 and evaluates to the sum of all results" }
    { { $snippet "<X>" } " evaluates " { $snippet "X" } ", discards the result and evaluates to zero" }
}
For example program { $snippet "([(()()())])" } will push numbers 3 and -3 to the stack, and program { $snippet "({{}})" } will replace values on the stack until a zero with their sum.

{ $examples
    "Sum the input stack:"
    { $example
        "USING: brain-flak prettyprint ;"
        "{ 2 1 3 7 } [ b-f\"([]<>){({}[()])<>({}{})<>}<>\" ] with-brain-flak ."
        "{ 13 }"
    }
    "Calculate nth fibonacci number:"
    { $example
        "USING: brain-flak prettyprint ;"
        "{ 10 } [ b-f\"(<>)(())<>{({}[()])(<>({})<({}{}<>)><>)(<>{}<>)<>}<>{}\" ] with-brain-flak . "
        "{ 55 }"
    }
    "More examples of brain-flak programs can be seen on its " { $url URL"https://github.com/DJMcMayhem/Brain-Flak/wiki/Stack-Operations" "github wiki" } "."
}

{ $heading "Vocabulary" }
The { $vocab-link "brain-flak" } vocabulary provides a brain-flak to Factor compiler in two words:
{ $subsections compile-brain-flak POSTPONE: b-f" }
These offer a way to compile brain-flak strings into quotations and embed them directly in code. Programs compiled this way will take and return a brain-flak state object. State objects can be constructed from a sequence which becomes the initial stack of the state. The vocabulary also includes a wrapper word for using a brain-flak quotation as a function from sequence to sequence:
{ $subsections brain-flak <brain-flak> with-brain-flak }
;

ABOUT: "brain-flak"
