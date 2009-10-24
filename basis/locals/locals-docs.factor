USING: help.syntax help.markup kernel macros prettyprint
memoize combinators arrays generalizations see ;
IN: locals

HELP: [|
{ $syntax "[| bindings... | body... ]" }
{ $description "A literal quotation with named variable bindings. When the quotation is " { $link call } "ed, it will take values off the datastack values and place them into the bindings from left to right. The body may then refer to these bindings. The quotation may also bind to named variables in an enclosing scope to create a closure." }
{ $examples "See " { $link "locals-examples" } "." } ;

HELP: [let
{ $syntax "[let | var-1 [ value-1... ]\n        var-2 [ value-2... ]\n        ... |\n    body... ]" }
{ $description "Evaluates each " { $snippet "value-n" } " form and binds its result to a new local variable named " { $snippet "var-n" } " lexically scoped to the " { $snippet "body" } ", then evaluates " { $snippet "body" } ". The " { $snippet "value-n" } " forms are evaluated in parallel, so a " { $snippet "value-n" } " form may not refer to previous " { $snippet "var-n" } " definitions inside the same " { $link POSTPONE: [let } " form, unlike " { $link POSTPONE: [let* } "." }
{ $examples "See " { $link "locals-examples" } "." } ;

HELP: [let*
{ $syntax "[let* | var-1 [ value-1... ]\n        var-2 [ value-2... ]\n        ... |\n    body... ]" }
{ $description "Evaluates each " { $snippet "value-n" } " form and binds its result to a new local variable named " { $snippet "var-n" } " lexically scoped to the " { $snippet "body" } ", then evaluates " { $snippet "body" } ". The " { $snippet "value-n" } " forms are evaluated sequentially, so a " { $snippet "value-n" } " form may refer to previous " { $snippet "var-n" } " definitions inside the same " { $link POSTPONE: [let* } " form." }
{ $examples "See " { $link "locals-examples" } "." } ;

{ POSTPONE: [let POSTPONE: [let* } related-words

HELP: [wlet
{ $syntax "[wlet | binding1 [ body1... ]\n        binding2 [ body2... ]\n        ... |\n     body... ]" }
{ $description "Introduces a set of lexically-scoped non-recursive local functions. The bodies may not refer to other bindings within the same " { $link POSTPONE: [wlet } " form." }
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
{ $syntax ":> var" ":> var!" }
{ $description "Binds the value on the top of the datastack to a new local variable named " { $snippet "var" } ", lexically scoped to the enclosing quotation or definition."
$nl
"If the " { $snippet "var" } " name is followed by an exclamation point (" { $snippet "!" } "), the new variable will be mutable. See " { $link "locals-mutable" } " for more information on mutable local bindings." }
{ $notes
    "This syntax can only be used inside a " { $link POSTPONE: :: } " word, " { $link POSTPONE: [let } ", " { $link POSTPONE: [let* } ",  or " { $link POSTPONE: [wlet } " form, or inside a quotation literal inside one of those forms."
}
{ $examples "See " { $link "locals-examples" } "." } ;

HELP: ::
{ $syntax ":: word ( bindings... -- outputs... ) body... ;" }
{ $description "Defines a word with named inputs; it reads datastack values into local variable bindings from left to right, then executes the body with those bindings in lexical scope." }
{ $notes "The output names do not affect the word's behavior, however the compiler attempts to check the stack effect as with other definitions." }
{ $examples "See " { $link "locals-examples" } "." } ;

{ POSTPONE: : POSTPONE: :: } related-words

HELP: MACRO::
{ $syntax "MACRO:: word ( bindings... -- outputs... ) body... ;" }
{ $description "Defines a macro with named inputs; it reads datastack values into local variable bindings from left to right, then executes the body with those bindings in lexical scope." }
{ $notes "The output names do not affect the word's behavior, however the compiler attempts to check the stack effect as with other definitions." }
{ $examples "See " { $link "locals-examples" } "." } ;

{ POSTPONE: MACRO: POSTPONE: MACRO:: } related-words

HELP: MEMO::
{ $syntax "MEMO:: word ( bindings... -- outputs... ) body... ;" }
{ $description "Defines a macro with named inputs; it reads datastack values into local variable bindings from left to right, then executes the body with those bindings in lexical scope." }
{ $examples "See " { $link "locals-examples" } "." } ;

{ POSTPONE: MEMO: POSTPONE: MEMO:: } related-words
                                          
HELP: M::
{ $syntax "M:: class generic ( bindings... -- outputs... ) body... ;" }
{ $description "Defines a macro with named inputs; it reads datastack values into local variable bindings from left to right, then executes the body with those bindings in lexical scope." }
{ $notes "The output names do not affect the word's behavior, however the compiler attempts to check the stack effect as with other definitions." }
{ $examples "See " { $link "locals-examples" } "." } ;

{ POSTPONE: M: POSTPONE: M:: } related-words

ARTICLE: "locals-examples" "Examples of locals"
{ $heading "Definitions with locals" }
"The following example demonstrates local variable bindings in word definitions. The " { $snippet "quadratic-roots" } " word is defined with " { $link POSTPONE: :: } ", so it takes its inputs from the top three elements of the datastack and binds them to the variables " { $snippet "a" } ", " { $snippet "b" } ", and " { $snippet "c" } ". In the body, the " { $snippet "disc" } " variable is bound using " { $link POSTPONE: :> } " and then used in the following line of code."
{ $example """USING: locals math math.functions kernel ;
IN: scratchpad
:: quadratic-roots ( a b c -- x y )
    b sq 4 a c * * - sqrt :> disc
    b neg disc [ + ] [ - ] 2bi [ 2 a * / ] bi@ ;
1.0 1.0 -6.0 quadratic-roots [ . ] bi@"""
"""2.0
-3.0"""
}
{ $snippet "quadratic-roots" } " can also be expressed with " { $link POSTPONE: [let } ":"
{ $example """USING: locals math math.functions kernel ;
IN: scratchpad
:: quadratic-roots ( a b c -- x y )
    [let | disc [ b sq 4 a c * * - sqrt ] |
        b neg disc [ + ] [ - ] 2bi [ 2 a * / ] bi@
    ] ;
1.0 1.0 -6.0 quadratic-roots [ . ] bi@"""
"""2.0
-3.0"""
}

$nl

{ $heading "Quotations with locals, and closures" }
"These next two examples demonstrate local variable bindings in quotations defined with " { $link POSTPONE: [| } ". In this example, the values " { $snippet "5" } " and " { $snippet "3" } " are put on the datastack. When the quotation is called, those values are bound to " { $snippet "m" } " and " { $snippet "n" } " respectively in the lexical scope of the quotation:"
{ $example
    "USING: kernel locals math prettyprint ;"
    "IN: scratchpad"
    "5 3 [| m n | m n - ] call ."
    "2"
}
$nl

"In this example, the " { $snippet "adder" } " word creates a quotation that closes over its argument " { $snippet "n" } ". When called, the result of " { $snippet "5 adder" } " pulls " { $snippet "3" } " off the datastack and binds it to " { $snippet "m" } ":"
{ $example
    "USING: kernel locals math prettyprint ;"
    "IN: scratchpad"
    ":: adder ( n -- quot ) [| m | m n + ] ;"
    "3 5 adder call ."
    "8"
}
$nl

{ $heading "Mutable bindings" }
"This next example demonstrates closures and mutable variable bindings. The " { $snippet "make-counter" } " word outputs a tuple containing a pair of quotations that respectively increment and decrement an internal counter in the mutable " { $snippet "value" } " variable and then return the new value. The quotations close over the counter, so each invocation of the word gives new quotations with a new internal counter."
{ $example
"""USING: locals kernel math ;
IN: scratchpad

TUPLE: counter adder subtractor ;

:: <counter> ( -- counter )
    0 :> value!
    counter new
    [ value 1 + dup value! ] >>adder
    [ value 1 - dup value! ] >>subtractor ;
<counter>
[ adder>>      call . ]
[ adder>>      call . ]
[ subtractor>> call . ] tri """
"""1
2
1"""
}
    $nl
    "The same variable name can be bound multiple times in the same scope. This is different from reassigning the value of a mutable variable. The most recent binding for a variable name will mask previous bindings for that name. However, the old binding referring to the previous value can still persist in closures. The following contrived example demonstrates this:"
    { $example
"""USING: kernel locals prettyprint ;
IN: scratchpad
:: rebinding-example ( -- quot1 quot2 )
    5 :> a [ a ]
    6 :> a [ a ] ;
:: mutable-example ( -- quot1 quot2 )
    5 :> a! [ a ]
    6 a! [ a ] ;
rebinding-example [ call . ] bi@
mutable-example [ call . ] bi@"""
"""5
6
6
6"""
} 
    "In " { $snippet "rebinding-example" } ", the binding of " { $snippet "a" } " to " { $snippet "5" } " is closed over in the first quotation, and the binding of " { $snippet "a" } " to " { $snippet "6" } " is closed over in the second, so calling both quotations results in " { $snippet "5" } " and " { $snippet "6" } " respectively. By contrast, in " { $snippet "mutable-example" } ", both quotations close over a single binding of " { $snippet "a" } ". Even though " { $snippet "a" } " is assigned to " { $snippet "6" } " after the first quotation is made, calling either quotation will output the new value of " { $snippet "a" } "."
{ $heading "Locals in literals" }
"Some kinds of literals can include references to local variables as described in " { $link "locals-literals" } ". For example, the " { $link 3array } " word could be implemented as follows:"
{ $example
"""USING: locals prettyprint ;
IN: scratchpad

:: my-3array ( x y z -- array ) { x y z } ;
1 "two" 3.0 my-3array ."""
"""{ 1 "two" 3.0 }"""
} ;
                                                 
ARTICLE: "locals-literals" "Locals in literals"
"Certain data type literals are permitted to contain local variables. Any such literals are rewritten into code which constructs an instance of the type with the values of the variables spliced in. Conceptually, this is similar to the transformation applied to quotations containing free variables."
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
"One exception to the above rule is that array instances containing free local variables (that is, immutable local variables not referenced in a closure) do retain identity. This allows macros such as " { $link cond } " to recognize that the array is constant and expand at compile time." ;

ARTICLE: "locals-mutable" "Mutable locals"
"In the list of bindings supplied to " { $link POSTPONE: :: } ", " { $link POSTPONE: [let } ", " { $link POSTPONE: [let* } " or " { $link POSTPONE: [| } ", a mutable binding may be introduced by suffixing its named with " { $snippet "!" } ". Mutable bindings are read by giving their name as usual; the suffix is not part of the binding's name. To write to a mutable binding, use the binding's name with the " { $snippet "!" } " suffix."
$nl
"Mutable bindings are implemented in a manner similar to the ML language; each mutable binding is actually an immutable binding of a mutable cell (in Factor's case, a 1-element array); reading the binding automatically dereferences the array, and writing to the binding stores into the array."
$nl
"Writing to mutable locals in outer scopes is fully supported and has the expected semantics. See " { $link "locals-examples" } " for examples of mutable local variables in action." ;

ARTICLE: "locals-fry" "Locals and fry"
"Locals integrate with " { $link "fry" } " so that mixing locals with fried quotations gives intuitive results."
$nl
"The following two code snippets are equivalent:"
{ $code "'[ sq _ + ]" }
{ $code "[ [ sq ] dip + ] curry" }
"The semantics of " { $link dip } " and " { $link curry } " are such that the first example behaves as if the top of the stack as “inserted” in the “hole” in the quotation's second element."
$nl
"Conceptually, " { $link curry } " is defined so that the following two code snippets are equivalent:"
{ $code "3 [ - ] curry" }
{ $code "[ 3 - ]" }
"When quotations take named parameters using " { $link POSTPONE: [| } ", " { $link curry } " fills in the variable bindings from right to left. The following two snippets are equivalent:"
{ $code "3 [| a b | a b - ] curry" }
{ $code "[| a | a 3 - ]" }
"Because of this, the behavior of " { $snippet "fry" } " changes when applied to such a quotation to ensure that fry conceptually behaves the same as with normal quotations, placing the fried values “underneath” the local variable bindings. Thus, the following snippets are no longer equivalent:"
{ $code "'[ [| a | _ a - ] ]" }
{ $code "'[ [| a | a - ] curry ] call" }
"Instead, the first line above expands into something like the following:"
{ $code "[ [ swap [| a | a - ] ] curry call ]" }
$nl
"The precise behavior is as follows. When frying a " { $link POSTPONE: [| } " quotation, a stack shuffle (" { $link mnswap } ") is prepended so that the " { $snippet "m" } " curried values, which start off at the top of the stack, are transposed with the quotation's " { $snippet "n" } " named input bindings." ;

ARTICLE: "locals-limitations" "Limitations of locals"
"There are two main limitations of the current locals implementation, and both concern macros."
{ $heading "Macro expansions with free variables" }
"The expansion of a macro cannot reference local variables bound in the outer scope. For example, the following macro is invalid:"
{ $code "MACRO:: twice ( quot -- ) [ quot call quot call ] ;" }
"The following is fine, though:"
{ $code "MACRO:: twice ( quot -- ) quot quot '[ @ @ ] ;" }
{ $heading "Static stack effect inference and macros" }
"A macro will only expand at compile-time if all inputs to the macro are literal. Likewise, the word containing the macro will only get a static stack effect and compile successfully if the macro's inputs are literal. When locals are used in a macro's literal arguments, there is an additional restriction: The literals must immediately precede the macro call lexically."
$nl
"For example, all of the following three code snippets are superficially equivalent, but only the first will compile:"
{ $code
    ":: good-cond-usage ( a -- ... )"
    "    {"
    "        { [ a 0 < ] [ ... ] }"
    "        { [ a 0 > ] [ ... ] }"
    "        { [ a 0 = ] [ ... ] }"
    "    } cond ;"
}
"The next two snippets will not compile, because the argument to " { $link cond } " does not immediately precede the call to " { $link cond } ":"
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
"The reason is that locals are rewritten into stack code at parse time, whereas macro expansion is performed later during compile time. To circumvent this problem, the " { $vocab-link "macros.expander" } " vocabulary is used to rewrite simple macro usages prior to local transformation, however " { $vocab-link "macros.expander" } " cannot deal with more complicated cases where the literal inputs to the macro do not immediately precede the macro call in the source." ;

ARTICLE: "locals" "Lexical variables and closures"
"The " { $vocab-link "locals" } " vocabulary provides lexically scoped local variables. Full closure semantics, both downward and upward, are supported. Mutable variable bindings are also provided, supporting assignment to bindings in the current scope or outer scopes."
{ $subsections
    "locals-examples"
}
"Word definitions where the inputs are bound to named local variables:"
{ $subsections
    POSTPONE: ::
    POSTPONE: M::
    POSTPONE: MEMO::
    POSTPONE: MACRO::
}
"Lexical binding forms:"
{ $subsections
    POSTPONE: :>
    POSTPONE: [let
    POSTPONE: [let*
    POSTPONE: [wlet
}
"Quotation literals where the inputs are named local variables:"
{ $subsections POSTPONE: [| }
"Additional topics:"
{ $subsections
    "locals-literals"
    "locals-mutable"
    "locals-fry"
    "locals-limitations"
}
"Locals complement dynamically scoped variables implemented in the " { $vocab-link "namespaces" } " vocabulary." ;

ABOUT: "locals"
