USING: help.syntax help.markup kernel macros prettyprint
memoize combinators arrays generalizations see ;
IN: locals

HELP: [|
{ $syntax "[| bindings... | body... ]" }
{ $description "A lambda abstraction. When called, reads stack values into the bindings from left to right; the body may then refer to these bindings." }
{ $examples
    { $example
        "USING: kernel locals math prettyprint ;"
        "IN: scratchpad"
        ":: adder ( n -- quot ) [| m | m n + ] ;"
        "3 5 adder call ."
        "8"
    }
} ;

HELP: [let
{ $syntax "[let | binding1 [ value1... ]\n       binding2 [ value2... ]\n       ... |\n    body... ]" }
{ $description "Introduces a set of lexical bindings and evaluates the body. The values are evaluated in parallel, and may not refer to other bindings within the same " { $link POSTPONE: [let } " form; for Lisp programmers, this means that " { $link POSTPONE: [let } " is equivalent to the Lisp " { $snippet "let" } ", not " { $snippet "let*" } "." }
{ $examples
    { $example
        "USING: kernel locals math math.functions prettyprint sequences ;"
        "IN: scratchpad"
        ":: frobnicate ( n seq -- newseq )"
        "    [let | n' [ n 6 * ] |"
        "        seq [ n' gcd nip ] map ] ;"
        "6 { 36 14 } frobnicate ."
        "{ 36 2 }"
    }
} ;

HELP: [let*
{ $syntax "[let* | binding1 [ value1... ]\n        binding2 [ value2... ]\n        ... |\n    body... ]" }
{ $description "Introduces a set of lexical bindings and evaluates the body. The values are evaluated sequentially, and may refer to previous bindings from the same " { $link POSTPONE: [let* } " form; for Lisp programmers, this means that " { $link POSTPONE: [let* } " is equivalent to the Lisp " { $snippet "let*" } ", not " { $snippet "let" } "." }
{ $examples
    { $example
        "USING: kernel locals math math.functions prettyprint sequences ;"
        "IN: scratchpad"
        ":: frobnicate ( n seq -- newseq )"
        "    [let* | a [ n 3 + ]"
        "            b [ a 4 * ] |"
        "        seq [ b / ] map ] ;"
        "1 { 32 48 } frobnicate ."
        "{ 2 3 }"
    }
} ;

{ POSTPONE: [let POSTPONE: [let* } related-words

HELP: [wlet
{ $syntax "[wlet | binding1 [ body1... ]\n        binding2 [ body2... ]\n        ... |\n     body... ]" }
{ $description "Introduces a set of lexically-scoped non-recursive local functions. The bodies may not refer to other bindings within the same " { $link POSTPONE: [wlet } " form; for Lisp programmers, this means that Factor's " { $link POSTPONE: [wlet } " is equivalent to the Lisp " { $snippet "flet" } ", not " { $snippet "labels" } "." }
{ $examples
    { $example
        "USING: locals math prettyprint sequences ;"
        "IN: scratchpad"
        ":: quuxify ( n seq -- newseq )"
        "    [wlet | add-n [| m | m n + ] |"
        "        seq [ add-n ] map ] ;"
        "2 { 1 2 3 } quuxify ."
        "{ 3 4 5 }"
    }
} ;

HELP: :>
{ $syntax ":> binding" }
{ $description "Introduces a new binding, lexically scoped to the enclosing quotation or definition." }
{ $notes
    "This word can only be used inside a lambda word, lambda quotation or let binding form."
    $nl
    "Lambda and let forms are really just syntax sugar for " { $link POSTPONE: :> } "."
    $nl
    "Lambdas desugar as follows:"
    { $code
        "[| a b | a b + b / ]"
        "[ :> b :> a a b + b / ]"
    }
    "Let forms desugar as follows:"
    { $code
        "[|let | x [ 10 random ] | { x x } ]"
        "10 random :> x { x x }"
    }
}
{ $examples
    { $code
        "USING: locals math kernel ;"
        "IN: scratchpad"
        ":: quadratic ( a b c -- x y )"
        "    b sq 4 a c * * - sqrt :> disc"
        "    b neg disc [ + ] [ - ] 2bi [ 2 a * / ] bi@ ;"
    }
} ;

HELP: ::
{ $syntax ":: word ( bindings... -- outputs... ) body... ;" }
{ $description "Defines a word with named inputs; it reads stack values into bindings from left to right, then executes the body with those bindings in lexical scope." }
{ $notes "The output names do not affect the word's behavior, however the compiler attempts to check the stack effect as with other definitions." }
{ $examples "See " { $link POSTPONE: [| } ", " { $link POSTPONE: [let } " and " { $link POSTPONE: [wlet } "." } ;

{ POSTPONE: : POSTPONE: :: } related-words

HELP: MACRO::
{ $syntax "MACRO:: word ( bindings... -- outputs... ) body... ;" }
{ $description "Defines a macro with named inputs; it reads stack values into bindings from left to right, then executes the body with those bindings in lexical scope." }
{ $notes "The output names do not affect the word's behavior, however the compiler attempts to check the stack effect as with other definitions." } ;

{ POSTPONE: MACRO: POSTPONE: MACRO:: } related-words

HELP: MEMO::
{ $syntax "MEMO:: word ( bindings... -- outputs... ) body... ;" }
{ $description "Defines a memoized word with named inputs; it reads stack values into bindings from left to right, then executes the body with those bindings in lexical scope." } ;

{ POSTPONE: MEMO: POSTPONE: MEMO:: } related-words
                                          
HELP: M::
{ $syntax "M:: class generic ( bindings... -- outputs... ) body... ;" }
{ $description "Defines a method with named inputs; it reads stack values into bindings from left to right, then executes the body with those bindings in lexical scope." }
{ $notes "The output names do not affect the word's behavior, however the compiler attempts to check the stack effect as with other definitions." } ;

{ POSTPONE: M: POSTPONE: M:: } related-words

                                                 
ARTICLE: "locals-literals" "Locals in literals"
"Certain data type literals are permitted to contain free variables. Any such literals are written into code which constructs an instance of the type with the free variable values spliced in. Conceptually, this is similar to the transformation applied to quotations containing free variables."
$nl
"The data types which receive this special handling are the following:"
{ $list
    { $link "arrays" }
    { $link "hashtables" }
    { $link "vectors" }
    { $link "tuples" }
    { $link "wrappers" }
}
{ $heading "Object identity" }
"This feature changes the semantics of literal object identity. An ordinary word containing a literal pushes the same literal on the stack every time it is invoked:"
{ $example
    "IN: scratchpad"
    "TUPLE: person first-name last-name ;"
    ": ordinary-word-test ( -- tuple )"
    "    T{ person { first-name \"Alan\" } { last-name \"Kay\" } } ;"
    "ordinary-word-test ordinary-word-test eq? ."
    "t"
}
"In a word with locals, literals which do not contain locals still behave in the same way:"
{ $example
    "USE: locals"
    "IN: scratchpad"
    "TUPLE: person first-name last-name ;"
    ":: locals-word-test ( -- tuple )"
    "    T{ person { first-name \"Alan\" } { last-name \"Kay\" } } ;"
    "locals-word-test locals-word-test eq? ."
    "t"
}
"However, literals with locals in them actually expand into code for constructing a new object:"
{ $example
    "USING: locals splitting ;"
    "IN: scratchpad"
    "TUPLE: person first-name last-name ;"
    ":: constructor-test ( -- tuple )"
    "    \"Jane Smith\" \" \" split1 :> last :> first"
    "    T{ person { first-name first } { last-name last } } ;"
    "constructor-test constructor-test eq? ."
    "f"
}
"One exception to the above rule is that array instances containing no free variables do retain identity. This allows macros such as " { $link cond } " to recognize that the array is constant and expand at compile-time."
{ $heading "Example" }
"Here is an implementation of the " { $link 3array } " word which uses this feature:"
{ $code ":: 3array ( x y z -- array ) { x y z } ;" } ;

ARTICLE: "locals-mutable" "Mutable locals"
"In the list of bindings supplied to " { $link POSTPONE: :: } ", " { $link POSTPONE: [let } ", " { $link POSTPONE: [let* } " or " { $link POSTPONE: [| } ", a mutable binding may be introduced by suffixing its named with " { $snippet "!" } ". Mutable bindings are read by giving their name as usual; the suffix is not part of the binding's name. To write to a mutable binding, use the binding's name with the " { $snippet "!" } " suffix."
$nl
"Here is a example word which outputs a pair of quotations which increment and decrement an internal counter, and then return the new value. The quotations are closed over the counter and each invocation of the word yields new quotations with their unique internal counter:"
{ $code
    ":: counter ( -- )"
    "    [let | value! [ 0 ] |"
    "        [ value 1 + dup value! ]"
    "        [ value 1 - dup value! ] ] ;"
}
"Mutable bindings are implemented in a manner similar to the ML language; each mutable binding is actually an immutable binding of a mutable cell (in Factor's case, a 1-element array); reading the binding automatically dereferences the array, and writing to the binding stores into the array."
$nl
"Unlike some languages such as Python and Java, writing to mutable locals in outer scopes is fully supported and has the expected semantics." ;

ARTICLE: "locals-fry" "Locals and fry"
"Locals integrate with " { $link "fry" } " so that mixing locals with fried quotations gives intuitive results."
$nl
"Recall that the following two code snippets are equivalent:"
{ $code "'[ sq _ + ]" }
{ $code "[ [ sq ] dip + ] curry" }
"The semantics of " { $link dip } " and " { $link curry } " are such that the first example behaves as if the top of the stack as “inserted” in the “hole” in the quotation's second element."
$nl
"Conceptually, " { $link curry } " is defined so that the following two code snippets are equivalent:"
{ $code "3 [ - ] curry" }
{ $code "[ 3 - ]" }
"With lambdas, " { $link curry } " behaves differently. Rather than prepending an element, it fills in named parameters from right to left. The following two snippets are equivalent:"
{ $code "3 [| a b | a b - ] curry" }
{ $code "[| a | a 3 - ]" }
"Because of this, the behavior of fry changes when applied to a lambda, to ensure that conceptually, fry behaves as with quotations. So the following snippets are no longer equivalent:"
{ $code "'[ [| a | _ a - ] ]" }
{ $code "'[ [| a | a - ] curry ] call" }
"Instead, the first line above expands into something like the following:"
{ $code "[ [ swap [| a | a - ] ] curry call ]" }
"This ensures that the fried value appears “underneath” the local variable " { $snippet "a" } " when the quotation calls."
$nl
"The precise behavior is the following. When frying a lambda, a stack shuffle (" { $link mnswap } ") is prepended to the lambda so that the " { $snippet "m" } " curried values, which start off at the top of the stack, are transposed with the " { $snippet "n" } " inputs to the lambda." ;

ARTICLE: "locals-limitations" "Limitations of locals"
"There are two main limitations of the current locals implementation, and both concern macros."
{ $heading "Macro expansions with free variables" }
"The expansion of a macro cannot reference local variables bound in the outer scope. For example, the following macro is invalid:"
{ $code "MACRO:: twice ( quot -- ) [ quot call quot call ] ;" }
"The following is fine, though:"
{ $code "MACRO:: twice ( quot -- ) quot quot '[ @ @ ] ;" }
{ $heading "Static stack effect inference and macros" }
"Recall that a macro will only expand at compile-time, and the word containing it will only get a static stack effect, if all inputs to the macro are literal. When locals are used, there is an additional restriction; the literals must immediately precede the macro call, lexically."
$nl
"For example, all of the following three examples are equivalent semantically, but only the first will have a static stack effect and compile with the optimizing compiler:"
{ $code
    ":: good-cond-usage ( a -- ... )"
    "    {"
    "        { [ a 0 < ] [ ... ] }"
    "        { [ a 0 > ] [ ... ] }"
    "        { [ a 0 = ] [ ... ] }"
    "    } cond ;"
}
"The following two will not, and will run slower as a result:"
{ $code
    ": my-cond ( alist -- ) cond ; inline"
    ""
    ":: bad-cond-usage ( a -- ... )"
    "    {"
    "        { [ a 0 < ] [ ... ] }"
    "        { [ a 0 > ] [ ... ] }"
    "        { [ a 0 = ] [ ... ] }"
    "    } my-cond ;"
}
{ $code
    ":: bad-cond-usage ( a -- ... )"
    "    {"
    "        { [ a 0 < ] [ ... ] }"
    "        { [ a 0 > ] [ ... ] }"
    "        { [ a 0 = ] [ ... ] }"
    "    } swap swap cond ;"
}
"The reason is that locals are rewritten into stack code at parse time, whereas macro expansion is performed later during compile time. To circumvent this problem, the " { $vocab-link "macros.expander" } " vocabulary is used to rewrite simple macro usages prior to local transformation, however "{ $vocab-link "macros.expander" } " does not deal with more complicated cases where the literal inputs to the macro do not immediately precede the macro call in the source." ;

ARTICLE: "locals" "Lexical variables and closures"
"The " { $vocab-link "locals" } " vocabulary implements lexical scope with full closures, both downward and upward. Mutable bindings are supported, including assignment to bindings in outer scope."
$nl
"Compile-time transformation is used to compile local variables to efficient code; prettyprinter extensions are defined so that " { $link see } " can display original word definitions with local variables and not the closure-converted concatenative code which results."
$nl
"Applicative word definitions where the inputs are named local variables:"
{ $subsections
    POSTPONE: ::
    POSTPONE: M::
    POSTPONE: MEMO::
    POSTPONE: MACRO::
}
"Lexical binding forms:"
{ $subsections
    POSTPONE: [let
    POSTPONE: [let*
    POSTPONE: [wlet
}
"Lambda abstractions:"
{ $subsections POSTPONE: [| }
"Lightweight binding form:"
{ $subsections POSTPONE: :> }
"Additional topics:"
{ $subsections
    "locals-literals"
    "locals-mutable"
    "locals-fry"
    "locals-limitations"
}
"Locals complement dynamically scoped variables implemented in the " { $vocab-link "namespaces" } " vocabulary." ;

ABOUT: "locals"
