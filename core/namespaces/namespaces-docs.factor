USING: help.markup help.syntax kernel kernel.private
sequences words namespaces.private quotations vectors
math.parser math words.symbol assocs ;
IN: namespaces

ARTICLE: "namespaces-combinators" "Namespace combinators"
{ $subsection make-assoc }
{ $subsection with-scope }
{ $subsection with-variable }
{ $subsection bind } ;

ARTICLE: "namespaces-change" "Changing variable values"
{ $subsection on }
{ $subsection off }
{ $subsection inc }
{ $subsection dec }
{ $subsection change }
{ $subsection change-global } ;

ARTICLE: "namespaces-global" "Global variables"
{ $subsection namespace }
{ $subsection global }
{ $subsection get-global }
{ $subsection set-global }
{ $subsection initialize } ;

ARTICLE: "namespaces.private" "Namespace implementation details"
"The namestack holds namespaces."
{ $subsection namestack }
{ $subsection set-namestack }
{ $subsection namespace }
"A pair of words push and pop namespaces on the namestack."
{ $subsection >n }
{ $subsection ndrop } ;

ARTICLE: "namespaces" "Dynamic variables and namespaces"
"The " { $vocab-link "namespaces" } " vocabulary implements simple dynamically-scoped variables."
$nl
"A variable is an entry in an assoc of bindings, where the assoc is implicit rather than passed on the stack. These assocs are termed " { $emphasis "namespaces" } ". Nesting of scopes is implemented with a search order on namespaces, defined by a " { $emphasis "namestack" } ". Since namespaces are just assoc, any object can be used as a variable, however by convention, variables are keyed by symbols (see " { $link "words.symbol" } ")."
$nl
"The " { $link get } " and " { $link set } " words read and write variable values. The " { $link get } " word searches up the chain of nested namespaces, while " { $link set } " always sets variable values in the current namespace only. Namespaces are dynamically scoped; when a quotation is called from a nested scope, any words called by the quotation also execute in that scope."
{ $subsection get }
{ $subsection set }
"Various utility words abstract away common variable access patterns:"
{ $subsection "namespaces-change" }
{ $subsection "namespaces-combinators" }
"Implementation details your code probably does not care about:"
{ $subsection "namespaces.private" }
"An alternative to dynamic scope is lexical scope. Lexically-scoped values and closures are implemented in the " { $vocab-link "locals" } " vocabulary." ;

ABOUT: "namespaces"

HELP: get
{ $values { "variable" "a variable, by convention a symbol" } { "value" "the value, or " { $link f } } }
{ $description "Searches the name stack for a namespace containing the variable, and outputs the associated value. If no such namespace is found, outputs " { $link f } "." } ;

HELP: set
{ $values { "value" "the new value" } { "variable" "a variable, by convention a symbol" } }
{ $description "Assigns a value to the variable in the namespace at the top of the name stack." }
{ $side-effects "variable" } ;

HELP: off
{ $values { "variable" "a variable, by convention a symbol" } }
{ $description "Assigns a value of " { $link f } " to the variable." }
{ $side-effects "variable" } ;

HELP: on
{ $values { "variable" "a variable, by convention a symbol" } }
{ $description "Assigns a value of " { $link t } " to the variable." }
{ $side-effects "variable" } ;

HELP: change
{ $values { "variable" "a variable, by convention a symbol" } { "quot" { $quotation "( old -- new )" } } }
{ $description "Applies the quotation to the old value of the variable, and assigns the resulting value to the variable." }
{ $side-effects "variable" } ;

HELP: change-global
{ $values { "variable" "a variable, by convention a symbol" } { "quot" { $quotation "( old -- new )" } } }
{ $description "Applies the quotation to the old value of the global variable, and assigns the resulting value to the global variable." }
{ $side-effects "variable" } ;

HELP: +@
{ $values { "n" "a number" } { "variable" "a variable, by convention a symbol" } }
{ $description "Adds " { $snippet "n" } " to the value of the variable. A variable value of " { $link f } " is interpreted as being zero." }
{ $side-effects "variable" }
{ $examples
    { $example "USING: namespaces prettyprint ;" "IN: scratchpad" "SYMBOL: foo\n1 foo +@\n10 foo +@\nfoo get ." "11" }
} ;

HELP: inc
{ $values { "variable" "a variable, by convention a symbol" } }
{ $description "Increments the value of the variable by 1. A variable value of " { $link f } " is interpreted as being zero." }
{ $side-effects "variable" } ;

HELP: dec
{ $values { "variable" "a variable, by convention a symbol" } }
{ $description "Decrements the value of the variable by 1. A variable value of " { $link f } " is interpreted as being zero." }
{ $side-effects "variable" } ;

HELP: counter
{ $values { "variable" "a variable, by convention a symbol" } { "n" integer } }
{ $description "Increments the value of the variable by 1, and returns its new value." }
{ $notes "This word is useful for generating (somewhat) unique identifiers. For example, the " { $link gensym } " word uses it." }
{ $side-effects "variable" } ;

HELP: with-scope
{ $values { "quot" quotation } }
{ $description "Calls the quotation in a new namespace. Any variables set by the quotation are discarded when it returns." }
{ $examples
    { $example "USING: math namespaces prettyprint ;" "IN: scratchpad" "SYMBOL: x" "0 x set" "[ x [ 5 + ] change x get . ] with-scope x get ." "5\n0" }
} ;

HELP: with-variable
{ $values { "value" object } { "key" "a variable, by convention a symbol" } { "quot" quotation } }
{ $description "Calls the quotation in a new namespace where " { $snippet "key" } " is set to " { $snippet "value" } "." }
{ $examples "The following two phrases are equivalent:"
    { $code "[ 3 x set foo ] with-scope" }
    { $code "3 x [ foo ] with-variable" }
} ;

HELP: make-assoc
{ $values { "quot" quotation } { "exemplar" assoc } { "hash" "a new assoc" } }
{ $description "Calls the quotation in a new namespace of the same type as " { $snippet "exemplar" } ", and outputs this namespace when the quotation returns. Useful for quickly building assocs." } ;

HELP: bind
{ $values { "ns" assoc } { "quot" quotation } }
{ $description "Calls the quotation in the dynamic scope of " { $snippet "ns" } ". When variables are looked up by the quotation, " { $snippet "ns" } " is checked first, and setting variables in the quotation stores them in " { $snippet "ns" } "." } ;

HELP: namespace
{ $values { "namespace" assoc } }
{ $description "Outputs the current namespace. Calls to " { $link set } " modify this namespace." } ;

HELP: global
{ $values { "g" assoc } }
{ $description "Outputs the global namespace. The global namespace is always checked last when looking up variable values." } ;

HELP: get-global
{ $values { "variable" "a variable, by convention a symbol" } { "value" "the value" } }
{ $description "Outputs the value of a variable in the global namespace." } ;

HELP: set-global
{ $values { "value" "the new value" } { "variable" "a variable, by convention a symbol" } }
{ $description "Assigns a value to the variable in the global namespace." }
{ $side-effects "variable" } ;

HELP: namestack*
{ $values { "namestack" "a vector of assocs" } }
{ $description "Outputs the current name stack." } ;

HELP: namestack
{ $values { "namestack" "a vector of assocs" } }
{ $description "Outputs a copy of the current name stack." } ;

HELP: set-namestack
{ $values { "namestack" "a vector of assocs" } }
{ $description "Replaces the name stack with a copy of the given vector." } ;

HELP: >n
{ $values { "namespace" assoc } }
{ $description "Pushes a namespace on the name stack." } ;

HELP: ndrop
{ $description "Pops a namespace from the name stack." } ;

HELP: init-namespaces
{ $description "Resets the name stack to its initial state, holding a single copy of the global namespace." }
$low-level-note ;

HELP: initialize
{ $values { "variable" symbol } { "quot" quotation } }
{ $description "If " { $snippet "variable" } " does not have a value in the global namespace, calls " { $snippet "quot" } " and assigns the result to " { $snippet "variable" } " in the global namespace." } ;
