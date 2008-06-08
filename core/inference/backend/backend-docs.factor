USING: help.syntax help.markup words effects inference.dataflow
inference.state kernel sequences
kernel.private combinators sequences.private ;
IN: inference.backend

HELP: literal-expected
{ $error-description "Thrown when inference encounters a " { $link call } " or " { $link if } " being applied to a value which is not known to be a literal. Such a form can have an arbitrary stack effect, and does not compile." }
{ $notes "This error will be thrown when compiling any combinator, such as " { $link each } ". However, words calling combinators can compile if the combinator is declared " { $link POSTPONE: inline } " and the quotation being passed in is a literal." } ;

HELP: too-many->r
{ $error-description "Thrown if inference notices a quotation pushing elements on the retain stack without popping them at the end." }
{ $notes "See " { $link "shuffle-words" } " for retain stack usage conventions." } ;

HELP: too-many-r>
{ $error-description "Thrown if inference notices a quotation popping elements from the return stack it did not place there." }
{ $notes "See " { $link "shuffle-words" } " for retain stack usage conventions." } ;

HELP: unify-lengths
{ $values { "seq" sequence } { "newseq" "a new sequence" } }
{ $description "Pads sequences in " { $snippet "seq" } " with computed value placeholders to ensure they are all the same length." } ;

HELP: cannot-unify-specials
{ $description "Throws an " { $link cannot-unify-specials } "." }
{ $error-description "Thrown when some but not all branches in a conditional output " { $link curry } " or " { $link compose } " values. This case is not supported by stack effect inference yet. It does not indicate there is a programming error." } ;

HELP: unify-values
{ $values { "seq" sequence } { "value" "an object" } }
{ $description "If all values in the sequence are equal, outputs the value, otherwise outputs a computed value placeholder." } ;

HELP: unbalanced-branches-error
{ $values { "in" "a sequence of integers" } { "out" "a sequence of integers" } }
{ $description "Throws an " { $link unbalanced-branches-error } "." }
{ $error-description "Thrown when inference encounters an " { $link if } ", " { $link dispatch } " or " { $link cond } " where the branches do not all exit with the same stack height." }
{ $notes "Conditionals with variable stack effects are considered to be bad style and should be avoided since they do not compile."
$nl
"If this error comes up when inferring the stack effect of a recursive word, check the word's stack effect declaration; it might be wrong." } ;

HELP: unify-effect
{ $values { "quots" "a sequence of quotations" } { "in" "a sequence of integers" } { "out" "a sequence of stacks" } { "newin" "a sequence of integers" } { "newout" "a sequence of stacks" } }
{ $description "Unifies the stack effects of a number of branches, and outputs new values for " { $link d-in } " and " { $link meta-d } "." } ;

HELP: consume/produce
{ $values { "node" "a dataflow node" } { "effect" "an instance of " { $link effect } } }
{ $description "Adds a node to the dataflow graph that calls " { $snippet "word" } " with a stack effect of " { $snippet "effect" } "." } ;

HELP: cannot-infer-effect
{ $values { "word" word } }
{ $description "Throws a " { $link cannot-infer-effect } " error." }
{ $error-description "Thrown when inference encounters a call to a word which is already known not to have a static stack effect, due to a prior inference attempt failing." } ;

HELP: inline-word
{ $values { "word" word } }
{ $description "Called during inference to infer stack effects of inline words."
$nl
"If the inline word is recursive, a new " { $link #label } " node is added to the dataflow graph, and the word has to be inferred twice, to determine which literals survive the recursion (eg, quotations) and which don't (loop indices, etc)."
$nl
"If the inline word is not recursive, the resulting nodes are spliced into the dataflow graph, and no " { $link #label } " node is created." } ;

HELP: effect-error
{ $values { "word" word } { "effect" "an instance of " { $link effect } } }
{ $description "Throws an " { $link effect-error } "." }
{ $error-description "Thrown when a word's inferred stack effect does not match its declared stack effect." } ;

HELP: missing-effect
{ $error-description "Thrown when inference encounters a word lacking a stack effect declaration. Words not declared " { $link POSTPONE: inline } " must declare a stack effect in order to compile." } ;

HELP: recursive-quotation-error
{ $error-description "Thrown when a quotation calls itself, directly or indirectly, within the same word. Stack effect inference becomes equivalent to the halting problem if quotation recursion has to be taken into account, hence it is not permitted." }
{ $examples
    "Here is an example of quotation recursion:"
    { $code "[ [ dup call ] dup call ] infer." }
} ;
