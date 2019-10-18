USING: help.syntax help.markup kernel sequences words io
effects inference.dataflow inference.backend
math combinators inference.transforms ;
IN: inference

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
{ $example "[ dup call ] infer." "... an error ..." }
"On the other hand, the stack effect of applying " { $link call } " to a literal quotation or a " { $link curry } " of a literal quotation is easy to compute; it behaves as if the quotation was substituted at that point:"
{ $example "[ [ 2 + ] call ] infer." "( object -- object )" }
"Consider a combinator such as " { $link keep } ". The combinator itself does not have a stack effect, because it applies " { $link call } " to a potentially arbitrary quotation. However, since the combinator is declared " { $link POSTPONE: inline } ", a given usage of it can have a stack effect:"
{ $example "[ [ 2 + ] keep ] infer." "( object -- object object )" }
"Another example is the " { $link compose } " combinator. Because it is decared " { $link POSTPONE: inline } ", we can infer the stack effect of applying " { $link call } " to the result of " { $link compose } ":"
{ $example "[ 2 [ + ] curry [ sq ] compose ] infer." "( -- object object )" }
"Incidentally, this example demonstrates that the stack effect of nested currying and composition can also be inferred."
$nl
"A general rule of thumb is that any word which applies " { $link call } " or " { $link curry } " to one of its inputs must be declared " { $link POSTPONE: inline } "."
$nl
"Here is an example where the stack effect cannot be inferred:"
{ $code ": foo 0 [ + ] ;" "[ foo reduce ] infer." }
"However if " { $snippet "foo" } " was declared " { $link POSTPONE: inline } ", everything would work, since the " { $link reduce } " combinator is also " { $link POSTPONE: inline } ", and the inferencer can see the literal quotation value at the point it is passed to " { $link call } ":"
{ $example ": foo 0 [ + ] ; inline" "[ foo reduce ] infer." "( object -- object )" } ;

ARTICLE: "inference-branches" "Branch stack effects"
"Conditionals such as " { $link if } " and combinators built on " { $link if } " present a problem, in that if the two branches leave the stack at a different height, it is not clear what the stack effect should be. In this case, inference throws a " { $link unbalanced-branches-error } "."
$nl
"If all branches leave the stack at the same height, then the stack effect of the conditional is just the maximum of the stack effect of each branch. For example,"
{ $example "[ [ + ] [ drop ] if ] infer." "( object object object -- object )" }
"The call to " { $link if } " takes one value from the stack, a generalized boolean. The first branch " { $snippet "[ + ]" } " has stack effect " { $snippet "( x x -- x )" } " and the second has stack effect " { $snippet "( x -- )" } ". Since both branches decrease the height of the stack by one, we say that the stack effect of the two branches is " { $snippet "( x x -- x )" } ", and together with the boolean popped off the stack by " { $link if } ", this gives a total stack effect of " { $snippet "( x x x -- x )" } "." ;

ARTICLE: "inference-recursive" "Stack effects of recursive words"
"Recursive words must declare a stack effect. When a recursive call is encountered, the declared stack effect is substituted in. When inference is complete, the inferred stack effect is compared with the declared stack effect."
$nl
"Attempting to infer the stack effect of a recursive word which outputs a variable number of objects on the stack will fail. For example, the following will throw an " { $link unbalanced-branches-error } ":"
{ $code ": foo ( seq -- ) dup empty? [ drop ] [ dup pop foo ] if" "[ foo ] infer." }
"If you declare an incorrect stack effect, inference will fail also. Badly defined recursive words cannot confuse the inferencer." ;

ARTICLE: "inference-limitations" "Inference limitations"
"Mutually recursive words are supported, but mutually recursive " { $emphasis "inline" } " words are not."
$nl
"An inline recursive word cannot pass a quotation through the recursive call. For example, the following will not infer:"
{ $code ": foo ( a b c -- d e f ) [ f foo drop ] when 2dup call ; inline" "[ 1 [ 1+ ] foo ] infer." }
"However a small change can be made:"
{ $example ": foo ( a b c -- d ) [ 2dup f foo drop ] when call ; inline" "[ 1 [ 1+ ] t foo ] infer." "( -- object )" }
"An inline recursive word must have a fixed stack effect in its base case. The following will not infer:"
{ $code
    ": foo ( quot ? -- ) [ f foo ] [ call ] if ; inline"
    "[ [ 5 ] t foo ] infer."
} ;

ARTICLE: "compiler-transforms" "Compiler transforms"
"Compiler transforms can be used to allow words to compile which would otherwise not have a stack effect, and to expand combinators into more efficient code at compile time."
{ $subsection define-transform }
"An example is the " { $link cond } " word. If the association list of quotations it is given is literal, the entire form is expanded into a series of nested calls to " { $link if } "."
$nl
"Further customization can be achieved by hooking into the lower-level machinery used by " { $link define-transform } ", the " { $snippet "\"infer\"" } " word property."
$nl
"This property can hold a quotation to be called when the stack effect of a call to this word is being inferred. This quotation can access all internal state of the stack effect inferencer, such as the known literals on the data stack."
{ $subsection pop-literal }
{ $subsection infer-quot }
{ $subsection infer-quot-value }
"The " { $vocab-link "macros" } " vocabulary defines some nice syntax sugar which makes compiler transforms easier to work with." ;

ARTICLE: "inference" "Stack effect inference"
"The stack effect inference tool is used to check correctness of code before it is run. It is also used by the compiler to build a dataflow graph on which optimizations can be performed. Only words for which a stack effect can be inferred will compile."
$nl
"The main entry point is a single word which takes a quotation and prints its stack effect and variable usage:"
{ $subsection infer. }
"Instead of printing the inferred information, it can be returned as objects on the stack:"
{ $subsection infer }
"The dataflow graph used by " { $link "compiler" } " can be obtained:"
{ $subsection dataflow }
"The following articles describe the implementation of the stack effect inference algorithm:"
{ $subsection "inference-simple" }
{ $subsection "inference-combinators" }
{ $subsection "inference-branches" }
{ $subsection "inference-recursive" } 
{ $subsection "inference-limitations" } 
{ $subsection "compiler-transforms" } ;

ABOUT: "inference"

HELP: inference-error
{ $values { "msg" "an object" } }
{ $description "Throws an " { $link inference-error } "." }
{ $error-description
    "Thrown by " { $link infer } " and " { $link dataflow } " when the stack effect of a quotation cannot be inferred."
    $nl
    "This error always delegates to one of the following classes of errors, which indicate the specific issue preventing a stack effect from being inferred:"
    { $list
        { $link no-effect }
        { $link literal-expected }
        { $link too-many->r }
        { $link too-many-r> }
        { $link unbalanced-branches-error }
        { $link effect-error }
        { $link recursive-declare-error }
    }
} ;


HELP: dataflow-graph
{ $var-description "In the dynamic extent of " { $link infer } " and " { $link dataflow } ", holds the first node of the dataflow graph being constructed." } ;

HELP: current-node
{ $var-description "In the dynamic extent of " { $link infer } " and " { $link dataflow } ", holds the most recently added node of the dataflow graph being constructed." } ;

HELP: infer
{ $values { "quot" "a quotation" } { "effect" "an instance of " { $link effect } } }
{ $description "Attempts to infer the quotation's stack effect. For interactive testing, the " { $link infer. } " word should be called instead since it presents the output in a nicely formatted manner." }
{ $errors "Throws an " { $link inference-error } " if stack effect inference fails." } ;

HELP: infer.
{ $values { "quot" "a quotation" } }
{ $description "Attempts to infer the quotation's stack effect, and prints this data to the " { $link stdio } " stream." }
{ $errors "Throws an " { $link inference-error } " if stack effect inference fails." } ;

{ infer infer. } related-words

HELP: dataflow
{ $values { "quot" "a quotation" } { "dataflow" "a dataflow node" } }
{ $description "Attempts to construct a dataflow graph showing stack flow in the quotation." }
{ $notes "This is the first stage of the compiler." }
{ $errors "Throws an " { $link inference-error } " if stack effect inference fails." } ;

HELP: dataflow-with
{ $values { "quot" "a quotation" } { "stack" "a vector" } { "dataflow" "a dataflow node" } }
{ $description "Attempts to construct a dataflow graph showing stack flow in the quotation, starting with an initial data stack of values." }
{ $errors "Throws an " { $link inference-error } " if stack effect inference fails." } ;
