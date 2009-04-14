USING: help.syntax help.markup kernel sequences words io
effects classes math combinators
stack-checker.backend
stack-checker.branches
stack-checker.errors
stack-checker.transforms
stack-checker.state ;
IN: stack-checker

ARTICLE: "inference-simple" "Straight-line stack effects"
"The simplest case to look at is that of a quotation which does not have any branches or recursion, and just pushes literals and calls words, each of which has a known stack effect."
$nl
"Stack effect inference works by stepping through the quotation, while maintaining a \"shadow stack\" which tracks stack height at the current position in the quotation. Initially, the shadow stack is empty. If a word is encountered which expects more values than there are on the shadow stack, a global counter is incremented. This counter keeps track of the number of inputs the quotation expects on the stack. When inference is done, this counter, together with the final height of the shadow stack, gives the inferred stack effect."
{ $subsection d-in }
{ $subsection meta-d }
"When a literal is encountered, it is simply pushed on the shadow stack. For example, the stack effect of the following quotation is inferred by pushing all three literals on the shadow stack, then taking the value of " { $link d-in } " and the length of " { $link meta-d } ":"
{ $example "[ 1 2 3 ] infer." "( -- object object object )" }
"In the following example, the call to " { $link + } " expects two values on the shadow stack, but only one value is present, the literal which was pushed previously. This increments the " { $link d-in } " counter by one:"
{ $example "[ 2 + ] infer." "( object -- object )" }
"After the call to " { $link + } ", the shadow stack contains a \"computed value placeholder\", since the inferencer has no way to know what the resulting value actually is (in fact it is arbitrary)." ;

ARTICLE: "inference-combinators" "Combinator stack effects"
"Without further information, one cannot say what the stack effect of " { $link call } " is; it depends on the given quotation. If the inferencer encounters a " { $link call } " without further information, a " { $link literal-expected } " error is raised."
{ $example "[ dup call ] infer." "Got a computed value where a literal quotation was expected\n\nType :help for debugging help." }
"On the other hand, the stack effect of applying " { $link call } " to a literal quotation or a " { $link curry } " of a literal quotation is easy to compute; it behaves as if the quotation was substituted at that point:"
{ $example "[ [ 2 + ] call ] infer." "( object -- object )" }
"Consider a combinator such as " { $link keep } ". The combinator itself does not have a stack effect, because it applies " { $link call } " to a potentially arbitrary quotation. However, since the combinator is declared " { $link POSTPONE: inline } ", a given usage of it can have a stack effect:"
{ $example "[ [ 2 + ] keep ] infer." "( object -- object object )" }
"Another example is the " { $link compose } " combinator. Because it is decared " { $link POSTPONE: inline } ", we can infer the stack effect of applying " { $link call } " to the result of " { $link compose } ":"
{ $example "[ 2 [ + ] curry [ sq ] compose ] infer." "( -- object )" }
"Incidentally, this example demonstrates that the stack effect of nested currying and composition can also be inferred."
$nl
"A general rule of thumb is that any word which applies " { $link call } " or " { $link curry } " to one of its inputs must be declared " { $link POSTPONE: inline } "."
$nl
"Here is an example where the stack effect cannot be inferred:"
{ $code ": foo ( -- n quot ) 0 [ + ] ;" "[ foo reduce ] infer." }
"However if " { $snippet "foo" } " was declared " { $link POSTPONE: inline } ", everything would work, since the " { $link reduce } " combinator is also " { $link POSTPONE: inline } ", and the inferencer can see the literal quotation value at the point it is passed to " { $link call } ":"
{ $example ": foo ( -- n quot ) 0 [ + ] ; inline" "[ foo reduce ] infer." "( object -- object )" }
"Passing a literal quotation on the data stack through an inlined recursive combinator nullifies its literal status. For example, the following will not infer:"
{ $example
  "[ [ reverse ] swap [ reverse ] map swap call ] infer." "Got a computed value where a literal quotation was expected\n\nType :help for debugging help."
}
"To make this work, pass the quotation on the retain stack instead:"
{ $example
  "[ [ reverse ] [ [ reverse ] map ] dip call ] infer." "( object -- object )"
} ;

ARTICLE: "inference-branches" "Branch stack effects"
"Conditionals such as " { $link if } " and combinators built on " { $link if } " present a problem, in that if the two branches leave the stack at a different height, it is not clear what the stack effect should be. In this case, inference throws a " { $link unbalanced-branches-error } "."
$nl
"If all branches leave the stack at the same height, then the stack effect of the conditional is just the maximum of the stack effect of each branch. For example,"
{ $example "[ [ + ] [ drop ] if ] infer." "( object object object -- object )" }
"The call to " { $link if } " takes one value from the stack, a generalized boolean. The first branch " { $snippet "[ + ]" } " has stack effect " { $snippet "( x x -- x )" } " and the second has stack effect " { $snippet "( x -- )" } ". Since both branches decrease the height of the stack by one, we say that the stack effect of the two branches is " { $snippet "( x x -- x )" } ", and together with the boolean popped off the stack by " { $link if } ", this gives a total stack effect of " { $snippet "( x x x -- x )" } "." ;

ARTICLE: "inference-recursive" "Stack effects of recursive words"
"When a recursive call is encountered, the declared stack effect is substituted in. When inference is complete, the inferred stack effect is compared with the declared stack effect."
$nl
"Attempting to infer the stack effect of a recursive word which outputs a variable number of objects on the stack will fail. For example, the following will throw an " { $link unbalanced-branches-error } ":"
{ $code ": foo ( seq -- ) dup empty? [ drop ] [ dup pop foo ] if ;" "[ foo ] infer." }
"If you declare an incorrect stack effect, inference will fail also. Badly defined recursive words cannot confuse the inferencer." ;

ARTICLE: "inference-recursive-combinators" "Recursive combinator inference"
"Most combinators are not explicitly recursive; instead, they are implemented in terms of existing combinators, for example " { $link while } ", " { $link map } ", and the " { $link "compositional-combinators" } "."
$nl
"Combinators which are recursive require additional care."
$nl
"If a recursive word takes quotation parameters from the stack and calls them, it must be declared " { $link POSTPONE: inline } " (as documented in " { $link "inference-combinators" } ") as well as " { $link POSTPONE: recursive } "."
$nl
"Furthermore, the input parameters which are quotations must be annotated in the stack effect. For example, the following will not infer:"
{ $example ": bad ( quot -- ) [ call ] keep foo ; inline recursive" "[ [ ] bad ] infer." "Got a computed value where a literal quotation was expected\n\nType :help for debugging help." }
"The following is correct:"
{ $example ": good ( quot: ( -- ) -- ) [ call ] keep good ; inline recursive" "[ [ ] good ] infer." "( -- )" }
"An inline recursive word cannot pass a quotation on the data stack through the recursive call. For example, the following will not infer:"
{ $example ": bad ( ? quot: ( ? -- ) -- ) 2dup [ not ] dip bad call ; inline recursive" "[ [ drop ] bad ] infer." "Got a computed value where a literal quotation was expected\n\nType :help for debugging help." }
"However a small change can be made:"
{ $example ": good ( ? quot: ( ? -- ) -- ) [ good ] 2keep [ not ] dip call ; inline recursive" "[ [ drop ] good ] infer." "( object -- )" }
"An inline recursive word must have a fixed stack effect in its base case. The following will not infer:"
{ $code
    ": foo ( quot ? -- ) [ f foo ] [ call ] if ; inline"
    "[ [ 5 ] t foo ] infer."
} ;

ARTICLE: "inference" "Stack effect inference"
"The stack effect inference tool is used to check correctness of code before it is run. It is also used by the optimizing compiler to build the high-level SSA representation on which optimizations can be performed. Only words for which a stack effect can be inferred will compile with the optimizing compiler; all other words will be compiled with the non-optimizing compiler (see " { $link "compiler" } ")."
$nl
"The main entry point is a single word which takes a quotation and prints its stack effect and variable usage:"
{ $subsection infer. }
"Instead of printing the inferred information, it can be returned as objects on the stack:"
{ $subsection infer }
"Static stack effect inference can be combined with unit tests; see " { $link "tools.test.write" } "."
$nl
"The following articles describe the implementation of the stack effect inference algorithm:"
{ $subsection "inference-simple" }
{ $subsection "inference-recursive" } 
{ $subsection "inference-combinators" }
{ $subsection "inference-recursive-combinators" }
{ $subsection "inference-branches" }
{ $subsection "inference-errors" }
{ $see-also "effects" } ;

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
{ $values { "quot" "a quotation" } { "effect" "an instance of " { $link effect } } }
{ $description "Attempts to infer the quotation's stack effect. For interactive testing, the " { $link infer. } " word should be called instead since it presents the output in a nicely formatted manner." }
{ $errors "Throws an " { $link inference-error } " if stack effect inference fails." } ;

HELP: infer.
{ $values { "quot" "a quotation" } }
{ $description "Attempts to infer the quotation's stack effect, and prints this data to " { $link output-stream } "." }
{ $errors "Throws an " { $link inference-error } " if stack effect inference fails." } ;

{ infer infer. } related-words

HELP: forget-errors
{ $description "Removes markers indicating which words do not have stack effects."
$nl
"The stack effect inference code remembers which words failed to infer as an optimization, so that it does not try to infer the stack effect of words which do not have one over and over again." }
{ $notes "Usually this word does not need to be called directly; if a word failed to compile because of a stack effect error, fixing the word definition clears the flag automatically. However, if words failed to compile due to external factors which were subsequently rectified, such as an unavailable C library or a missing or broken compiler transform, this flag can be cleared for all words:"
{ $code "forget-errors" }
"Subsequent invocations of the compiler will consider all words for compilation." } ;
