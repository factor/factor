USING: help.syntax help.markup kernel
combinators arrays generalizations sequences ;
IN: locals

HELP: [|
{ $syntax "[| bindings... | body... ]" }
{ $description "A literal quotation with named variable bindings. When the quotation is " { $link call } "ed, it will take values off the datastack and place them into the bindings from left to right. The body may then refer to these bindings. The quotation may also bind to named variables in an enclosing scope to create a closure." }
{ $examples "See " { $link "locals-examples" } "." } ;

HELP: [let
{ $syntax "[let code :> var code :> var code... ]" }
{ $description "Establishes a new scope for lexical variable bindings. Variables bound with " { $link POSTPONE: :> } " within the body of the " { $snippet "[let" } " will be lexically scoped to the body of the " { $snippet "[let" } " form." }
{ $examples "See " { $link "locals-examples" } "." } ;

HELP: :>
{ $syntax ":> var\n:> var!\n:> ( var-1 var-2 ... )" }
{ $description "Binds one or more new lexical variables. In the " { $snippet ":> var" } " form, the value on the top of the datastack is bound to a new lexical variable named " { $snippet "var" } " and is scoped to the enclosing quotation, " { $link POSTPONE: [let } " form, or " { $link POSTPONE: :: } " definition."
$nl
"The " { $snippet ":> ( var-1 ... )" } " form binds multiple variables to the top values of the datastack in right to left order, with the last variable bound to the top of the datastack. These two snippets have the same effect:"
{ $code ":> c :> b :> a" }
{ $code ":> ( a b c )" }
$nl
"If any " { $snippet "var" } " name is followed by an exclamation point (" { $snippet "!" } "), that new variable is mutable. See " { $link "locals-mutable" } " for more information." }
{ $notes
    "This syntax can only be used inside a lexical scope established by a " { $link POSTPONE: :: } " definition, " { $link POSTPONE: [let } " form, or " { $link POSTPONE: [| } " quotation. Normal quotations have their own lexical scope only if they are inside an outer scope. Definition forms such as " { $link POSTPONE: : } " do not establish a lexical scope by themselves unless documented otherwise, nor is there a lexical scope available at the top level of source files or in the listener. " { $link POSTPONE: [let } " can be used to create a lexical scope where one is not otherwise available." }
{ $examples "See " { $link "locals-examples" } "." } ;

{ POSTPONE: [let POSTPONE: :> } related-words

HELP: ::
{ $syntax ":: word ( vars... -- outputs... ) body... ;" }
{ $description "Defines a word with named inputs. The word binds its input values to lexical variables from left to right, then executes the body with those bindings in scope."
$nl
"If any " { $snippet "var" } " name is followed by an exclamation point (" { $snippet "!" } "), the corresponding new variable is made mutable. See " { $link "locals-mutable" } " for more information." }
{ $notes "The names of the " { $snippet "outputs" } " do not affect the word's behavior. However, the compiler verifies that the stack effect accurately represents the number of outputs as with " { $link POSTPONE: : } " definitions." }
{ $examples "See " { $link "locals-examples" } "." } ;

{ POSTPONE: : POSTPONE: :: } related-words

HELP: MACRO::
{ $syntax "MACRO:: word ( vars... -- outputs... ) body... ;" }
{ $description "Defines a macro with named inputs. The macro binds its input variables to lexical variables from left to right, then executes the body with those bindings in scope."
$nl
"If any " { $snippet "var" } " name is followed by an exclamation point (" { $snippet "!" } "), the corresponding new variable is made mutable. See " { $link "locals-mutable" } " for more information." }
{ $notes "The expansion of a macro cannot reference lexical variables bound in the outer scope. There are also limitations on passing arguments involving lexical variables into macros. See " { $link "locals-limitations" } " for details." }
{ $examples "See " { $link "locals-examples" } "." } ;

{ POSTPONE: MACRO: POSTPONE: MACRO:: } related-words

HELP: MEMO::
{ $syntax "MEMO:: word ( vars... -- outputs... ) body... ;" }
{ $description "Defines a memoized word with named inputs. The word binds its input values to lexical variables from left to right, then executes the body with those bindings in scope."
$nl
"If any " { $snippet "var" } " name is followed by an exclamation point (" { $snippet "!" } "), the corresponding new variable is made mutable. See " { $link "locals-mutable" } " for more information." }
{ $examples "See " { $link "locals-examples" } "." } ;

{ POSTPONE: MEMO: POSTPONE: MEMO:: } related-words

HELP: M::
{ $syntax "M:: class generic ( vars... -- outputs... ) body... ;" }
{ $description "Defines a new method on " { $snippet "generic" } " for " { $snippet "class" } " with named inputs. The method binds its input values to lexical variables from left to right, then executes the body with those bindings in scope."
$nl
"If any " { $snippet "var" } " name is followed by an exclamation point (" { $snippet "!" } "), the corresponding new variable is made mutable. See " { $link "locals-mutable" } " for more information." }
{ $notes "The names of the " { $snippet "outputs" } " do not affect the word's behavior. However, the compiler verifies that the stack effect accurately represents the number of outputs as with " { $link POSTPONE: M: } " definitions." }
{ $examples "See " { $link "locals-examples" } "." } ;

{ POSTPONE: M: POSTPONE: M:: } related-words

ARTICLE: "locals-examples" "Examples of lexical variables"
{ $heading "Definitions with lexical variables" }
"The following example demonstrates lexical variable bindings in word definitions. The " { $snippet "quadratic-roots" } " word is defined with " { $link POSTPONE: :: } ", so it takes its inputs from the top three elements of the datastack and binds them to the variables " { $snippet "a" } ", " { $snippet "b" } ", and " { $snippet "c" } ". In the body, the " { $snippet "disc" } " variable is bound using " { $link POSTPONE: :> } " and then used in the following line of code."
{ $example "USING: locals math math.functions kernel ;
IN: scratchpad
:: quadratic-roots ( a b c -- x y )
    b sq 4 a c * * - sqrt :> disc
    b neg disc [ + ] [ - ] 2bi [ 2 a * / ] bi@ ;
1.0 1.0 -6.0 quadratic-roots"
"\n--- Data stack:\n2.0\n-3.0"
}
"If you wanted to perform the quadratic formula interactively from the listener, you could use " { $link POSTPONE: [let } " to provide a scope for the variables:"
{ $example "USING: locals math math.functions kernel ;
IN: scratchpad
[let 1.0 :> a 1.0 :> b -6.0 :> c
    b sq 4 a c * * - sqrt :> disc
    b neg disc [ + ] [ - ] 2bi [ 2 a * / ] bi@
]"
"\n--- Data stack:\n2.0\n-3.0"
}

$nl

{ $heading "Quotations with lexical variables, and closures" }
"These next two examples demonstrate lexical variable bindings in quotations defined with " { $link POSTPONE: [| } ". In this example, the values " { $snippet "5" } " and " { $snippet "3" } " are put on the datastack. When the quotation is called, it takes those values as inputs and binds them respectively to " { $snippet "m" } " and " { $snippet "n" } " before executing the quotation:"
{ $example
    "USING: kernel locals math ;"
    "IN: scratchpad"
    "5 3 [| m n | m n - ] call( x x -- x )"
    "\n--- Data stack:\n2"
}
$nl

"In this example, the " { $snippet "adder" } " word creates a quotation that closes over its argument " { $snippet "n" } ". When called, the result quotation of " { $snippet "5 adder" } " pulls " { $snippet "3" } " off the datastack and binds it to " { $snippet "m" } ", which is added to the value " { $snippet "5" } " bound to " { $snippet "n" } " in the outer scope of " { $snippet "adder" } ":"
{ $example
    "USING: kernel locals math ;"
    "IN: scratchpad"
    ":: adder ( n -- quot ) [| m | m n + ] ;"
    "3 5 adder call( x -- x )"
    "\n--- Data stack:\n8"
}
$nl

{ $heading "Mutable bindings" }
"This next example demonstrates closures and mutable variable bindings. The " { $snippet "<counter>" } " word outputs a tuple containing a pair of quotations that respectively increment and decrement an internal counter in the mutable " { $snippet "value" } " variable and then return the new value. The quotations close over the counter, so each invocation of the word gives new quotations with a new internal counter."
{ $example
"USING: accessors locals kernel math ;
IN: scratchpad

TUPLE: counter adder subtractor ;

:: <counter> ( -- counter )
    0 :> value!
    counter new
    [ value 1 + dup value! ] >>adder
    [ value 1 - dup value! ] >>subtractor ;
<counter>
[ adder>>      call( -- x ) ]
[ adder>>      call( -- x ) ]
[ subtractor>> call( -- x ) ] tri"
"\n--- Data stack:\n1\n2\n1"
}
    $nl
    "The same variable name can be bound multiple times in the same scope. This is different from reassigning the value of a mutable variable. The most recent binding for a variable name will mask previous bindings for that name. However, the old binding referring to the previous value can still persist in closures. The following contrived example demonstrates this:"
    { $example
"USING: kernel locals ;
IN: scratchpad
:: rebinding-example ( -- quot1 quot2 )
    5 :> a [ a ]
    6 :> a [ a ] ;
:: mutable-example ( -- quot1 quot2 )
    5 :> a! [ a ]
    6 a! [ a ] ;
rebinding-example [ call( -- x ) ] bi@
mutable-example [ call( -- x ) ] bi@"
"\n--- Data stack:\n5\n6\n6\n6"
}
    "In " { $snippet "rebinding-example" } ", the binding of " { $snippet "a" } " to " { $snippet "5" } " is closed over in the first quotation, and the binding of " { $snippet "a" } " to " { $snippet "6" } " is closed over in the second, so calling both quotations results in " { $snippet "5" } " and " { $snippet "6" } " respectively. By contrast, in " { $snippet "mutable-example" } ", both quotations close over a single binding of " { $snippet "a" } ". Even though " { $snippet "a" } " is assigned to " { $snippet "6" } " after the first quotation is made, calling either quotation will output the new value of " { $snippet "a" } "."
{ $heading "Lexical variables in literals" }
"Some kinds of literals can include references to lexical variables as described in " { $link "locals-literals" } ". For example, the " { $link 3array } " word could be implemented as follows:"
{ $example
"USING: locals ;
IN: scratchpad

:: my-3array ( x y z -- array ) { x y z } ;
1 \"two\" 3.0 my-3array"
"\n--- Data stack:\n{ 1 \"two\" 3.0 }"
} ;

ARTICLE: "locals-literals" "Lexical variables in literals"
"Certain data type literals are permitted to contain lexical variables. Any such literals are rewritten into code which constructs an instance of the type with the values of the variables spliced in. Conceptually, this is similar to the transformation applied to quotations containing free variables."
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
    "USING: kernel ;"
    "IN: scratchpad"
    "TUPLE: person first-name last-name ;"
    ": ordinary-word-test ( -- tuple )"
    "    T{ person { first-name \"Alan\" } { last-name \"Kay\" } } ;"
    "ordinary-word-test ordinary-word-test eq?"
    "\n--- Data stack:\nt"
}
"Inside a lexical scope, literals which do not contain lexical variables still behave in the same way:"
{ $example
    "USING: kernel locals ;"
    "IN: scratchpad"
    "TUPLE: person first-name last-name ;"
    ":: locals-word-test ( -- tuple )"
    "    T{ person { first-name \"Alan\" } { last-name \"Kay\" } } ;"
    "locals-word-test locals-word-test eq?"
    "\n--- Data stack:\nt"
}
"However, literals with lexical variables in them actually construct a new object:"
{ $example
    "USING: locals kernel splitting ;"
    "IN: scratchpad"
    "TUPLE: person first-name last-name ;"
    ":: constructor-test ( -- tuple )"
    "    \"Jane Smith\" \" \" split1 :> last :> first"
    "    T{ person { first-name first } { last-name last } } ;"
    "constructor-test constructor-test eq?"
    "\n--- Data stack:\nf"
}
"One exception to the above rule is that array instances containing free lexical variables (that is, immutable lexical variables not referenced in a closure) do retain identity. This allows macros such as " { $link cond } " to expand at compile time even when their arguments reference variables." ;


ARTICLE: "locals-mutable" "Mutable lexical variables"
"When a lexical variable is bound using " { $link POSTPONE: :> } ", " { $link POSTPONE: :: } ", or " { $link POSTPONE: [| } ", the variable may be made mutable by suffixing its name with an exclamation point (" { $snippet "!" } ")."
$nl
"A mutable lexical variable creates two new words in its scope. Assuming that we define a mutable variable with " { $snippet "data :> var!" } ", then:"
$nl
{ $snippet "var" } " will push the value of the variable, " { $snippet "data" } " to the stack,"
$nl
{ $snippet "var!" } " will consume a value from the stack, and set the variable to that value."
$nl
"Note that using " { $link POSTPONE: :> } " will always create a new local, and will not mutate the variable. Creating a new local with the same name may cause confusion, and have undesired effects."
$nl
"The value of any variable can be modified by a word that modifies its arguments e.g. " { $link push } ". These words ignore mutable and immutable bindings."
$nl
"Mutable bindings are implemented in a manner similar to that taken by the ML language. Each mutable binding is actually an immutable binding of a mutable cell. Reading the binding automatically unboxes the value from the cell, and writing to the binding stores into it."
$nl
"Writing to mutable variables from outer lexical scopes is fully supported and has full closure semantics. See " { $link "locals-examples" } " for examples of mutable lexical variables in action." ;

ARTICLE: "locals-fry" "Lexical variables and fry"
"Lexical variables integrate with " { $link "fry" } " so that mixing variables with fried quotations gives intuitive results."
$nl
"The following two code snippets are equivalent:"
{ $code "'[ sq _ + ]" }
{ $code "[ [ sq ] dip + ] curry" }
"The semantics of " { $link dip } " and " { $link curry } " are such that the first example behaves as if the top of the stack as \"inserted\" in the \"hole\" in the quotation's second element."
$nl
"Conceptually, " { $link curry } " is defined so that the following two code snippets are equivalent:"
{ $code "3 [ - ] curry" }
{ $code "[ 3 - ]" }
"When quotations take named parameters using " { $link POSTPONE: [| } ", " { $link curry } " fills in the variable bindings from right to left. The following two snippets are equivalent:"
{ $code "3 [| a b | a b - ] curry" }
{ $code "[| a | a 3 - ]" }
"Because of this, the behavior of " { $snippet "fry" } " changes when applied to such a quotation to ensure that fry conceptually behaves the same as with normal quotations, placing the fried values \"underneath\" the variable bindings. Thus, the following snippets are no longer equivalent:"
{ $code "'[ [| a | _ a - ] ]" }
{ $code "'[ [| a | a - ] curry ] call" }
"Instead, the first line above expands into something like the following:"
{ $code "[ [ swap [| a | a - ] ] curry call ]" }
$nl
"The precise behavior is as follows. When frying a " { $link POSTPONE: [| } " quotation, a stack shuffle (" { $link mnswap } ") is prepended so that the " { $snippet "m" } " curried values, which start off at the top of the stack, are transposed with the quotation's " { $snippet "n" } " named input bindings." ;

ARTICLE: "locals-limitations" "Limitations of lexical variables"
"There are two main limitations of the current implementation, and both concern macros."
{ $heading "Macro expansions with free variables" }
"The expansion of a macro cannot reference lexical variables bound in the outer scope. For example, the following macro is invalid:"
{ $code "MACRO:: twice ( quot -- ) [ quot call quot call ] ;" }
"The following is fine, though:"
{ $code "MACRO:: twice ( quot -- ) quot quot '[ @ @ ] ;" }
{ $heading "Static stack effect inference and macros" }
"A macro will only expand at compile-time if all of its inputs are literal. Likewise, the word containing the macro will only have a static stack effect and compile successfully if the macro's inputs are literal. When lexical variables are used in a macro's literal arguments, there is an additional restriction: The literals must immediately precede the macro call lexically."
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
"The next two snippets will not compile because the argument to " { $link cond } " does not immediately precede the call:"
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
"The reason is that lexical variable references are rewritten into stack code at parse time, whereas macro expansion is performed later during compile time. To circumvent this problem, the " { $vocab-link "macros.expander" } " vocabulary is used to rewrite simple macro usages prior to lexical variable transformation. However, " { $vocab-link "macros.expander" } " cannot deal with more complicated cases where the literal inputs to the macro do not immediately precede the macro call in the source." ;

ARTICLE: "locals" "Lexical variables"
"The " { $vocab-link "locals" } " vocabulary provides lexically scoped local variables. Full closure semantics, both downward and upward, are supported. Mutable variable bindings are also provided, supporting assignment to bindings in the current scope or in outer scopes."
{ $subsections
    "locals-examples"
}
"Word definitions where the inputs are bound to lexical variables:"
{ $subsections
    POSTPONE: ::
    POSTPONE: M::
    POSTPONE: MEMO::
    POSTPONE: MACRO::
}
"Lexical scoping and binding forms:"
{ $subsections
    POSTPONE: [let
    POSTPONE: :>
}
"Quotation literals where the inputs are bound to lexical variables:"
{ $subsections POSTPONE: [| }
"Additional topics:"
{ $subsections
    "locals-literals"
    "locals-mutable"
    "locals-fry"
    "locals-limitations"
}
"Lexical variables complement " { $link "namespaces" } "." ;

ABOUT: "locals"
