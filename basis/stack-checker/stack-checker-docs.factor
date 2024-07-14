USING: classes continuations effects help.markup help.syntax io
kernel quotations sequences stack-checker.backend
stack-checker.errors ;
IN: stack-checker

ARTICLE: "inference-simple" "Straight-line stack effects"
"The simplest case is when a piece of code does not have any branches or recursion, and just pushes literals and calls words."
$nl
"Pushing a literal has stack effect " { $snippet "( -- x )" } ". The stack effect of most words is always known statically from the declaration. Stack effects of " { $link POSTPONE: inline } " words and " { $link "macros" } ", may depend on literals pushed on the stack prior to the call, and this case is discussed in " { $link "inference-combinators" } "."
$nl
"The stack effect of each element in a code snippet is composed. The result is then the stack effect of the snippet."
$nl
"An example:"
{ $example "[ 1 2 3 ] infer." "( -- x x x )" }
"Another example:"
{ $example "[ 2 + ] infer." "( x -- x )" } ;

ARTICLE: "inference-combinators" "Combinator stack effects"
"If a word calls a combinator, one of the following two conditions must hold for the stack checker to succeed:"
{ $list
  { "The combinator must be called with a quotation that is either literal or built from literal quotations, " { $link curry } ", and " { $link compose } ". (Note that quotations that use " { $vocab-link "fry" } " or " { $vocab-link "locals" } " use " { $link curry } " and " { $link compose } " from the perspective of the stack checker.)" }
  { "If the word is declared " { $link POSTPONE: inline } ", the combinator may additionally be called on one of the word's input parameters or with quotations built from the word's input parameters, literal quotations, " { $link curry } ", and " { $link compose } ". When inline, a word is itself considered to be a combinator, and its callers must in turn satisfy these conditions." }
}
"If neither condition holds, the stack checker throws an " { $link unknown-macro-input } " or " { $link bad-macro-input } " error. To make the code compile, a runtime checking combinator such as " { $link POSTPONE: call( } " must be used instead. See " { $link "inference-escape" } " for details. An inline combinator can be called with an unknown quotation by " { $link curry } "ing the quotation onto a literal quotation that uses " { $link POSTPONE: call( } "."
{ $heading "Input stack effects" }
"Inline combinators will verify the stack effect of their input quotations if they are declared in the combinator's stack effect. See " { $link "effects-variables" } " for details."
{ $heading "Examples" }
{ $subheading "Calling a combinator" }
"The following usage of " { $link map } " passes the stack checker, because the quotation is the result of " { $link curry } ":"
{ $example "USING: math sequences ;" "[ [ + ] curry map ] infer." "( x x -- x )" }
"The equivalent code using " { $vocab-link "fry" } " and " { $vocab-link "locals" } " likewise passes the stack checker:"
{ $example "USING: fry math sequences ;" "[ '[ _ + ] map ] infer." "( x x -- x )" }
{ $example "USING: locals math sequences ;" "[| a | [ a + ] map ] infer." "( x x -- x )" }
{ $subheading "Defining an inline combinator" }
"The following word calls a quotation twice; the word is declared " { $link POSTPONE: inline } ", since it invokes " { $link call } " on the result of " { $link compose } " on an input parameter:"
{ $code ": twice ( value quot -- result ) dup compose call ; inline" }
"The following code now passes the stack checker; it would fail were " { $snippet "twice" } " not declared " { $link POSTPONE: inline } ":"
{ $unchecked-example "USE: math.functions" "[ [ sqrt ] twice ] infer." "( x -- x )" }
{ $subheading "Defining a combinator for unknown quotations" }
"In the next example, " { $link POSTPONE: call( } " must be used because the quotation is the result of calling a runtime accessor, and the compiler cannot make any static assumptions about this quotation at all:"
{ $code
  "TUPLE: action name quot ;"
  ": perform ( value action -- result ) quot>> call( value -- result ) ;"
}
{ $subheading "Passing an unknown quotation to an inline combinator" }
"Suppose we want to write:"
{ $code ": perform ( values action -- results ) quot>> map ;" }
"However this fails to pass the stack checker since there is no guarantee the quotation has the right stack effect for " { $link map } ". It can be wrapped in a new quotation with a declaration:"
{ $code ": perform ( values action -- results )" "    quot>> [ call( value -- result ) ] curry map ;" }
{ $heading "Explanation" }
"This restriction exists because without further information, one cannot say what the stack effect of " { $link call } " is; it depends on the given quotation. If the stack checker encounters a " { $link call } " without further information, a " { $link unknown-macro-input } " or " { $link bad-macro-input } " error is raised."
$nl
"On the other hand, the stack effect of applying " { $link call } " to a literal quotation or a " { $link curry } " of a literal quotation is easy to compute; it behaves as if the quotation was substituted at that point."
{ $heading "Limitations" }
"The stack checker cannot guarantee that a literal quotation is still literal if it is passed on the data stack to an inlined recursive combinator such as " { $link each } " or " { $link map } ". For example, the following will not infer:"
{ $example
  "[ [ reverse ] swap [ reverse ] map swap call ] infer." "Cannot apply 'call' to a run-time computed value\nmacro call"
}
"To make this work, use " { $link dip } " to pass the quotation instead:"
{ $example
  "[ [ reverse ] [ [ reverse ] map ] dip call ] infer." "( x -- x )"
} ;

ARTICLE: "inference-branches" "Branch stack effects"
"Conditionals such as " { $link if } " and combinators built on top have the same restrictions as " { $link POSTPONE: inline } " combinators (see " { $link "inference-combinators" } ") with the additional requirement that all branches leave the stack at the same height. If this is not the case, the stack checker throws an " { $link unbalanced-branches-error } "."
$nl
"If all branches leave the stack at the same height, then the stack effect of the conditional is just the maximum of the stack effect of each branch. For example,"
{ $example "[ [ + ] [ drop ] if ] infer." "( x x x -- x )" }
"The call to " { $link if } " takes one value from the stack, a generalized boolean. The first branch " { $snippet "[ + ]" } " has stack effect " { $snippet "( x x -- x )" } " and the second has stack effect " { $snippet "( x -- )" } ". Since both branches decrease the height of the stack by one, we say that the stack effect of the two branches is " { $snippet "( x x -- x )" } ", and together with the boolean popped off the stack by " { $link if } ", this gives a total stack effect of " { $snippet "( x x x -- x )" } "." ;

ARTICLE: "inference-recursive-combinators" "Recursive combinator stack effects"
"Most combinators do not call themselves recursively directly; instead, they are implemented in terms of existing combinators, for example " { $link while } ", " { $link map } ", and the " { $link "compositional-combinators" } ". In these cases, the rules outlined in " { $link "inference-combinators" } " apply."
$nl
"Combinators which are recursive require additional care. In addition to being declared " { $link POSTPONE: inline } ", they must be declared " { $link POSTPONE: recursive } ". There are three restrictions that only apply to combinators with this declaration:"
{ $heading "Input quotation declaration" }
"Input parameters which are quotations must be annotated as such in the stack effect. For example, the following will not infer:"
{ $unchecked-example ": bad ( quot -- ) [ call ] keep bad ; inline recursive" "[ [ ] bad ] infer." "Cannot apply 'call' to a run-time computed value\nmacro call" }
"The following is correct:"
{ $example ": good ( quot: ( -- ) -- ) [ call ] keep good ; inline recursive" "[ [ ] good ] infer." "( -- )" }
"The effect of the nested quotation itself is only present for documentation purposes; the mere presence of a nested effect is sufficient to mark that value as a quotation parameter."
{ $heading "Data flow restrictions" }
"The stack checker does not trace data flow in two instances."
$nl
"An inline recursive word cannot pass a quotation on the data stack through the recursive call. For example, the following will not infer:"
{ $unchecked-example ": bad ( ? quot: ( ? -- ) -- ) 2dup [ not ] dip bad call ; inline recursive" "[ [ drop ] bad ] infer." "Cannot apply 'call' to a run-time computed value\nmacro call" }
"However a small change can be made:"
{ $example ": good ( ? quot: ( ? -- ) -- ) [ good ] 2keep [ not ] dip call ; inline recursive" "[ [ drop ] good ] infer." "( x -- )" }
"An inline recursive word must have a fixed stack effect in its base case. The following will not infer:"
{ $unchecked-example
    ": foo ( quot ? -- ) [ f foo ] [ call ] if ; inline"
    "[ [ 5 ] t foo ] infer."
    "The inline recursive word 'foo' must be declared recursive\nword foo"
} ;

ARTICLE: "tools.inference" "Stack effect tools"
{ $link "inference" } " can be used interactively to print stack effects of quotations without running them. It can also be used from " { $link "combinators.smart" } "."
{ $subsections
    infer
    infer.
}
"There are also some words for working with " { $link effect } " instances. Getting a word's declared stack effect:"
{ $subsections stack-effect }
"Converting a stack effect to a string form:"
{ $subsections effect>string }
"Comparing effects:"
{ $subsections
    effect-height
    effect<=
    effect=
}
"The class of stack effects:"
{ $subsections
    effect
    effect?
} ;

ARTICLE: "inference-escape" "Stack effect checking escape hatches"
"In a static checking regime, sometimes it is necessary to step outside the boundaries and run some code which cannot be statically checked; perhaps this code is constructed at run-time. There are two ways to get around the static stack checker."
$nl
"If the stack effect of a word or quotation is known, but the word or quotation itself is not, " { $link POSTPONE: execute( } " or " { $link POSTPONE: call( } " can be used. See " { $link "call" } " for details."
$nl
"If the stack effect is not known, the code being called cannot manipulate the datastack directly. Instead, it must reflect the datastack into an array:"
{ $subsections with-datastack }
"The surrounding code has a static stack effect since " { $link with-datastack } " has one. However, the array passed in as input may be transformed arbitrarily by calling this combinator." ;

ARTICLE: "inference" "Stack effect checking"
"The " { $link "compiler" } " checks the " { $link "effects" } " of words before they can be run. This ensures that words take exactly the number of inputs and outputs that the programmer declares in source."
$nl
"Words that do not pass the stack checker are rejected and cannot be run, and so essentially this defines a very simple and permissive type system that nevertheless catches some invalid programs and enables compiler optimizations."
$nl
"If a word's stack effect cannot be inferred, a compile error is reported. See " { $link "compiler-errors" } "."
$nl
"The following articles describe how different control structures are handled by the stack checker."
{ $subsections
    "inference-simple"
    "inference-combinators"
    "inference-recursive-combinators"
    "inference-branches"
}
"Stack checking catches several classes of errors."
{ $subsections "inference-errors" }
"Sometimes code with a dynamic stack effect has to be run."
{ $subsections "inference-escape" }
{ $see-also "effects" "tools.inference" "tools.errors" } ;

ABOUT: "inference"

HELP: inference-error
{ $values { "class" class } }
{ $description "Creates an instance of " { $snippet "class" } ", wraps it in an " { $link inference-error } " and throws the result." }
{ $error-description
    "Thrown by " { $link infer } " when the stack effect of a quotation cannot be inferred."
    $nl
    "The " { $snippet "error" } " slot contains one of several possible " { $link "inference-errors" } "."
} ;

HELP: infer
{ $values { "quot" quotation } { "effect" "an instance of " { $link effect } } }
{ $description "Attempts to infer the quotation's stack effect. For interactive testing, the " { $link infer. } " word should be called instead since it presents the output in a nicely formatted manner." }
{ $errors "Throws an " { $link inference-error } " if stack effect inference fails." } ;

HELP: infer.
{ $values { "quot" quotation } }
{ $description "Attempts to infer the quotation's stack effect, and prints this data to " { $link output-stream } "." }
{ $errors "Throws an " { $link inference-error } " if stack effect inference fails." } ;

{ infer infer. } related-words
