USING: help.syntax help.markup kernel macros prettyprint ;
IN: locals

<PRIVATE

: $with-locals-note
    {
        "This form must appear either in a word defined by " { $link POSTPONE: :: } " or " { $link POSTPONE: MACRO:: } ", or alternatively, " { $link with-locals } " must be called on the top-level form of the word to perform closure conversion."
    } $notes ;

PRIVATE>

HELP: [|
{ $syntax "[| bindings... | body... ]" }
{ $description "A lambda abstraction. When called, reads stack values into the bindings from left to right; the body may then refer to these bindings." }
{ $examples
    { $example
        "USE: locals"
        ":: adder | n | [| m | m n + ] ;"
        "3 5 adder call ."
        "8"
    }
}
$with-locals-note ;

HELP: [let
{ $syntax "[let | binding1 [ value1... ]\n       binding2 [ value2... ]\n       ... |\n    body... ]" }
{ $description "Introduces a set of lexical bindings and evaluates the body. The values are evaluated in parallel, and may not refer to other bindings within the same " { $link POSTPONE: [let } " form; for Lisp programmers, this means that Factor's " { $link POSTPONE: [let } " is equivalent to the Lisp " { $snippet "let" } ", not " { $snippet "let*" } "." }
{ $examples
    { $example
        "USE: locals"
        ":: frobnicate | n seq |"
        "    [let | n' [ n 6 * ] |"
        "        seq [ n' gcd ] map ] ;"
        "6 { 36 14 } frobnicate ."
        "{ 36 2 }"
    }
}
$with-locals-note ;

HELP: [wlet
{ $syntax "[wlet | binding1 [ body1... ]\n        binding2 [ body2... ]\n        ... |\n     body... ]" }
{ $description "Introduces a set of lexically-scoped non-recursive local functions. The bodies may not refer to other bindings within the same " { $link POSTPONE: [wlet } " form; for Lisp programmers, this means that Factor's " { $link POSTPONE: [wlet } " is equivalent to the Lisp " { $snippet "flet" } ", not " { $snippet "labels" } "." }
{ $examples
    { $example
        "USE: locals"
        ":: quuxify | n seq |"
        "    [wlet | add-n [| m | m n + ] |"
        "        seq [ add-n ] map ] ;"
        "2 { 1 2 3 } quuxify ."
        "{ 3 4 5 }"
    }
} ;

HELP: with-locals
{ $values { "form" "a quotation, lambda, let or wlet form" } { "quot" "a quotation" } }
{ $description "Performs closure conversion of a lexically-scoped form. All nested sub-forms are converted. This word must be applied to a " { $link POSTPONE: [| } ", " { $link POSTPONE: [let } " or " { $link POSTPONE: [wlet } " used in an ordinary definition, however forms in " { $link POSTPONE: :: } " and " { $link POSTPONE: MACRO:: } " definitions are automatically closure-converted and there is no need to use this word." } ;

HELP: ::
{ $syntax ":: word | bindings... | body... ;" }
{ $description "Defines a word with named inputs; it reads stack values into bindings from left to right, then executes the body with those bindings in lexical scope. Any " { $link POSTPONE: [| } ", " { $link POSTPONE: [let } " or " { $link POSTPONE: [wlet } " forms used in the body of the word definition are automatically closure-converted." }
{ $examples "See " { $link POSTPONE: [| } ", " { $link POSTPONE: [let } " and " { $link POSTPONE: [wlet } "." } ;

HELP: MACRO::
{ $syntax "MACRO:: word | bindings... | body... ;" }
{ $description "Defines a macro with named inputs; it reads stack values into bindings from left to right, then executes the body with those bindings in lexical scope. Any " { $link POSTPONE: [| } ", " { $link POSTPONE: [let } " or " { $link POSTPONE: [wlet } " forms used in the body of the word definition are automatically closure-converted." } ;

{ POSTPONE: MACRO: POSTPONE: MACRO:: } related-words

ARTICLE: "locals-mutable" "Mutable locals"
"In the list of bindings supplied to " { $link POSTPONE: :: } ", " { $link POSTPONE: [let } " or " { $link POSTPONE: [| } ", a mutable binding may be introduced by suffixing its named with " { $snippet "!" } ". Mutable bindings are read by giving their name as usual; the suffix is not part of the binding's name. To write to a mutable binding, use the binding's with the " { $snippet "!" } " suffix."
$nl
"Here is a example word which outputs a pair of quotations which increment and decrement an internal counter, and then return the new value. The quotations are closed over the counter and each invocation of the word yields new quotations with their unique internal counter:"
{ $code
    ":: counter | |"
    "    [let | value! [ 0 ] |"
    "        [ value 1+ dup value! ]"
    "        [ value 1- dup value! ] ] ;"
}
"Mutable bindings are implemented in a manner similar to the ML language; each mutable binding is actually an immutable binding of a mutable cell (in Factor's case, a 1-element array); reading the binding automatically dereferences the array, and writing to the binding stores into the array."
$nl
"Unlike some languages such as Python and Java, writing to mutable locals in outer scopes is fully supported and has the expected semantics." ;

ARTICLE: "locals-limitations" "Limitations of locals"
"The first limitation is that the " { $link >r } " and " { $link r> } " words may not be used together with locals. Instead, use the " { $link dip } " combinator."
$nl
"Another limitation is that closure conversion does not descend into arrays, hashtables or other types of literals. For example, the following does not work:"
{ $code
    ":: bad-cond-usage | a |"
    "    { [ a 0 < ] [ ... ] }"
    "    { [ a 0 > ] [ ... ] }"
    "    { [ a 0 = ] [ ... ] } ;"
} ;

ARTICLE: "locals" "Local variables and lexical closures"
"The " { $vocab-link "locals" } " vocabulary implements lexical scope with full closures, both downward and upward. Mutable bindings are supported, including assignment to bindings in outer scope."
$nl
"Compile-time transformation is used to compile local variables to efficient code; prettyprinter extensions are defined so that " { $link see } " can display original word definitions with local variables and not the closure-converted concatenative code which results."
$nl
"Applicative word definitions where the inputs are named local variables:"
{ $subsection POSTPONE: :: }
{ $subsection POSTPONE: MACRO:: }
"Explicit closure conversion outside of applicative word definitions:"
{ $subsection with-locals }
"Lexical binding forms:"
{ $subsection POSTPONE: [let }
{ $subsection POSTPONE: [wlet }
"Lambda abstractions:"
{ $subsection POSTPONE: [| }
"Additional topics:"
{ $subsection "locals-mutable" }
{ $subsection "locals-limitations" }
"Locals complement dynamically scoped variables implemented in the " { $vocab-link "namespaces" } " vocabulary." ;

ABOUT: "locals"
