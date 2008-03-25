USING: help.markup help.syntax words classes classes.algebra
definitions kernel alien sequences math quotations
generic.standard generic.math combinators ;
IN: generic

ARTICLE: "method-order" "Method precedence"
"Consider the case where a generic word has methods on two classes, say A and B, which share a non-empty intersection. If the generic word is called on an object which is an instance of both A and B, a choice of method must be made. If A is a subclass of B, the method for A to be called; this makes sense, because we're defining general behavior for instances of B, and refining it for instances of A. Conversely, if B is a subclass of A, then we expect B's method to be called. However, if neither is a subclass of the other, we have an ambiguous situation and undefined behavior will result. Either the method for A or B will be called, and there is no way to predict ahead of time."
$nl
"The generic word system linearly orders all the methods on a generic word by their class. Conceptually, method dispatch is implemented by testing the object against the predicate word for every class, in order. If methods are defined on overlapping classes, this order will fail to be unique and the problem described above can occur."
$nl
"Here is an example:"
{ $code
    "GENERIC: explain"
    "M: number explain drop \"an integer\" print ;"
    "M: sequence explain drop \"a sequence\" print ;"
    "M: object explain drop \"an object\" print ;"
}
"Neither " { $link number } " nor " { $link sequence } " are subclasses of each other, yet their intersection is the non-empty " { $link integer } " class. As a result, the outcome of calling " { $snippet "bar" } " with an " { $link integer } " on the stack is undefined - either one of the two methods may be called. This situation can lead to subtle bugs. To avoid it, explicitly disambiguate the method order by defining a method on the intersection. If in this case we want integers to behave like numbers, we would also define:"
{ $code "M: integer explain drop \"an integer\" print ;" }
"On the other hand, if we want integers to behave like sequences here, we could define:"
{ $code "M: integer explain drop \"a sequence\" print ;" }
"The " { $link order } " word can be useful to clarify method dispatch order."
{ $subsection order } ;

ARTICLE: "generic-introspection" "Generic word introspection"
"In most cases, generic words and methods are defined at parse time with " { $link POSTPONE: GENERIC: } " (or some other parsing word) and " { $link POSTPONE: M: } "."
$nl
"Sometimes, generic words need to be inspected defined at run time; words for performing these tasks are found in the " { $vocab-link "generic" } " vocabulary."
$nl
"The set of generic words is a class which implements the " { $link "definition-protocol" } ":"
{ $subsection generic }
{ $subsection generic? }
"New generic words can be defined:"
{ $subsection define-generic }
{ $subsection define-simple-generic }
"Methods can be added to existing generic words:"
{ $subsection create-method }
"Method definitions can be looked up:"
{ $subsection method }
{ $subsection methods }
"A generic word contains methods; the list of methods specializing on a class can also be obtained:"
{ $subsection implementors }
"Low-level word which rebuilds the generic word after methods are added or removed, or the method combination is changed:"
{ $subsection make-generic }
"Low-level method constructor:"
{ $subsection <method> }
"A " { $emphasis "method specifier" } " refers to a method and implements the " { $link "definition-protocol" } ":"
{ $subsection method-spec } ;

ARTICLE: "method-combination" "Custom method combination"
"Abstractly, a generic word can be thought of as a big chain of type conditional tests applied to the top of the stack, with methods as the bodies of each test. The " { $emphasis "method combination" } " is this control flow glue between the set of methods, and several aspects of it can be customized:"
{ $list
    "which stack item(s) the generic word dispatches upon,"
    "which methods out of the set of applicable methods are called"
}
"A table of built-in method combination defining words, and the method combinations themselves:"
{ $table
    { { $link POSTPONE: GENERIC: } { $link standard-combination } }
    { { $link POSTPONE: GENERIC# } { $link standard-combination } }
    { { $link POSTPONE: HOOK: } { $link hook-combination } }
    { { $link POSTPONE: MATH: } { $link math-combination } }
}
"Developing a custom method combination requires that a parsing word calling " { $link define-generic } " be defined; additionally, it is a good idea to implement the definition protocol words " { $link definer } " and " { $link synopsis* } " on the class of words having this method combination, to properly support developer tools."
$nl
"The combination quotation passed to " { $link define-generic } " has stack effect " { $snippet "( word -- quot )" } ". It's job is to call various introspection words, including at least obtaining the set of methods defined on the generic word, then combining these methods in some way to produce a quotation."
$nl
"Method combination utilities:"
{ $subsection single-combination }
{ $subsection class-predicates }
{ $subsection simplify-alist }
{ $subsection math-upgrade }
{ $subsection object-method }
{ $subsection error-method }
"More quotation construction utilities can be found in " { $link "quotations" } " and " { $link "combinators-quot" } "."
{ $see-also "generic-introspection" } ;

ARTICLE: "generic" "Generic words and methods"
"A " { $emphasis "generic word" } " is composed of zero or more " { $emphasis "methods" } " together with a " { $emphasis "method combination" } ". A method " { $emphasis "specializes" } " on a class; when a generic word executed, the method combination chooses the most appropriate method and calls its definition."
$nl
"A generic word behaves roughly like a long series of class predicate conditionals in a " { $link cond } " form, however methods can be defined in independent source files, reducing coupling and increasing extensibility. The method combination determines which object the generic word will " { $emphasis "dispatch" } " on; this could be the top of the stack, or some other value."
$nl
"Generic words which dispatch on the object at the top of the stack:"
{ $subsection POSTPONE: GENERIC: }
"A method combination which dispatches on a specified stack position:"
{ $subsection POSTPONE: GENERIC# }
"A method combination which dispatches on the value of a variable at the time the generic word is called:"
{ $subsection POSTPONE: HOOK: }
"A method combination which dispatches on a pair of stack values, which must be numbers, and upgrades both to the same type of number:"
{ $subsection POSTPONE: MATH: }
"Method definition:"
{ $subsection POSTPONE: M: }
"Generic words must declare their stack effect in order to compile. See " { $link "effect-declaration" } "."
{ $subsection "method-order" }
{ $subsection "generic-introspection" }
{ $subsection "method-combination" }
"Generic words specialize behavior based on the class of an object; sometimes behavior needs to be specialized on the object's " { $emphasis "structure" } "; this is known as " { $emphasis "pattern matching" } " and is implemented in the " { $vocab-link "match" } " vocabulary." ;

ABOUT: "generic"

HELP: generic
{ $class-description "The class of generic words, documented in " { $link "generic" } "." } ;

{ generic define-generic define-simple-generic POSTPONE: GENERIC: POSTPONE: GENERIC# POSTPONE: MATH: POSTPONE: HOOK: } related-words

HELP: make-generic
{ $values { "word" generic } }
{ $description "Regenerates the definition of a generic word by applying the method combination to the set of defined methods." }
$low-level-note ;

HELP: define-generic
{ $values { "word" word } { "combination" "a method combination" } }
{ $description "Defines a generic word. A method combination is an object which responds to the " { $link perform-combination } " generic word." }
{ $contract "The method combination quotation is called each time the generic word has to be updated (for example, when a method is added), and thus must be side-effect free." } ;

HELP: method-spec
{ $class-description "The class of method specifiers, which are two-element arrays consisting of a class word followed by a generic word." }
{ $examples { $code "{ fixnum + }" "{ editor draw-gadget* }" } } ;

HELP: method-body
{ $class-description "The class of method bodies, which are words with special word properties set." } ;

HELP: method
{ $values { "class" class } { "generic" generic } { "method/f" "a " { $link method-body } " or " { $link f } } }
{ $description "Looks up a method definition." } ;

{ method create-method POSTPONE: M: } related-words

HELP: <method>
{ $values { "class" class } { "generic" generic } { "method" "a new method definition" } }
{ $description "Creates a new method." } ;

HELP: methods
{ $values { "word" generic } { "assoc" "an association list mapping classes to quotations" } }
{ $description "Outputs a sequence of pairs, where the first element of each pair is a class and the second element is the corresponding method quotation. The methods are sorted by class order; see " { $link sort-classes } "." } ;

HELP: order
{ $values { "generic" generic } { "seq" "a sequence of classes" } }
{ $description "Outputs a sequence of classes for which methods have been defined on this generic word. The sequence is sorted in method dispatch order." } ;

HELP: check-method
{ $values { "class" class } { "generic" generic } }
{ $description "Asserts that " { $snippet "class" } " is a class word and " { $snippet "generic" } " is a generic word, throwing a " { $link check-method } " error if the assertion fails." }
{ $error-description "Thrown if " { $link POSTPONE: M: } " or " { $link create-method } " is given an invalid class or generic word." } ;

HELP: with-methods
{ $values { "generic" generic } { "quot" "a quotation with stack effect " { $snippet "( methods -- )" } } }
{ $description "Applies a quotation to the generic word's methods hashtable, and regenerates the generic word's definition when the quotation returns." }
$low-level-note ;

HELP: create-method
{ $values { "class" class } { "generic" generic } { "method" method-body } }
{ $description "Creates a method or returns an existing one. This is the runtime equivalent of " { $link POSTPONE: M: } "." }
{ $notes "To define a method, pass the output value to " { $link define } "." } ;

HELP: implementors
{ $values { "class" class } { "seq" "a sequence of generic words" } }
{ $description "Finds all generic words in the dictionary implementing methods for this class." } ;

HELP: forget-methods
{ $values { "class" class } }
{ $description "Remove all method definitions which specialize on the class." } ;

{ sort-classes methods order } related-words
