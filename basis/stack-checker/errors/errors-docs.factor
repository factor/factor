USING: help.markup help.syntax kernel effects sequences
sequences.private words ;
IN: stack-checker.errors

HELP: literal-expected
{ $error-description "Thrown when inference encounters a " { $link call } " or " { $link if } " being applied to a value which is not known to be a literal. Such a form can have an arbitrary stack effect, and does not compile." }
{ $notes "This error will be thrown when compiling any combinator, such as " { $link each } ". However, words calling combinators can compile if the combinator is declared " { $link POSTPONE: inline } " and the quotation being passed in is a literal." } ;

HELP: too-many->r
{ $error-description "Thrown if inference notices a quotation pushing elements on the retain stack without popping them at the end." }
{ $notes "See " { $link "shuffle-words" } " for retain stack usage conventions." } ;

HELP: too-many-r>
{ $error-description "Thrown if inference notices a quotation popping elements from the return stack it did not place there." }
{ $notes "See " { $link "shuffle-words" } " for retain stack usage conventions." } ;

HELP: cannot-infer-effect
{ $values { "word" word } }
{ $description "Throws a " { $link cannot-infer-effect } " error." }
{ $error-description "Thrown when inference encounters a call to a word which is already known not to have a static stack effect, due to a prior inference attempt failing." } ;

HELP: effect-error
{ $values { "word" word } { "effect" "an instance of " { $link effect } } }
{ $description "Throws an " { $link effect-error } "." }
{ $error-description "Thrown when a word's inferred stack effect does not match its declared stack effect." } ;

HELP: missing-effect
{ $error-description "Thrown when inference encounters a word lacking a stack effect declaration. Stack effects of words must be declared, with the exception of words which only push literals on the stack." } ;

HELP: recursive-quotation-error
{ $error-description "Thrown when a quotation calls itself, directly or indirectly, within the same word. Stack effect inference becomes equivalent to the halting problem if quotation recursion has to be taken into account, hence it is not permitted." }
{ $examples
    "Here is an example of quotation recursion:"
    { $code "[ [ dup call ] dup call ] infer." }
} ;

HELP: unbalanced-branches-error
{ $values { "in" "a sequence of integers" } { "out" "a sequence of integers" } }
{ $description "Throws an " { $link unbalanced-branches-error } "." }
{ $error-description "Thrown when inference encounters an " { $link if } " or " { $link dispatch } " where the branches do not all exit with the same stack height." }
{ $notes "Conditionals with variable stack effects are considered to be bad style and should be avoided since they do not compile."
$nl
"If this error comes up when inferring the stack effect of a recursive word, check the word's stack effect declaration; it might be wrong." } ;

ARTICLE: "inference-errors" "Inference errors"
"Main wrapper for all inference errors:"
{ $subsection inference-error }
"Specific inference errors:"
{ $subsection cannot-infer-effect }
{ $subsection literal-expected }
{ $subsection too-many->r }
{ $subsection too-many-r> }
{ $subsection recursive-quotation-error }
{ $subsection unbalanced-branches-error }
{ $subsection effect-error }
{ $subsection missing-effect } ;

ABOUT: "inference-errors"
