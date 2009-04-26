USING: help.markup help.syntax words classes classes.algebra
definitions kernel alien sequences math quotations
generic.standard generic.math combinators prettyprint effects ;
IN: generic

ARTICLE: "method-order" "Method precedence"
"Conceptually, method dispatch is implemented by testing the object against the predicate word for every class, in linear order (" { $link "class-linearization" } ")."
$nl
"Here is an example:"
{ $code
    "GENERIC: explain"
    "M: object explain drop \"an object\" print ;"
    "M: number explain drop \"a number\" print ;"
    "M: sequence explain drop \"a sequence\" print ;"
}
"The linear order is the following, from least-specific to most-specific:"
{ $code "{ object sequence number }" }
"Neither " { $link number } " nor " { $link sequence } " are subclasses of each other, yet their intersection is the non-empty " { $link integer } " class. Calling " { $snippet "explain" } " with an integer on the stack will print " { $snippet "a number" } " because " { $link number } " precedes " { $link sequence } " in the class linearization order. If this was not the desired outcome, define a method on the intersection:"
{ $code "M: integer explain drop \"a sequence\" print ;" }
"Now, the linear order is the following, from least-specific to most-specific:"
{ $code "{ object sequence number integer }" }
"The " { $link order } " word can be useful to clarify method dispatch order:"
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
"Finding the most specific method for an object:"
{ $subsection effective-method }
"A generic word contains methods; the list of methods specializing on a class can also be obtained:"
{ $subsection implementors }
"Low-level word which rebuilds the generic word after methods are added or removed, or the method combination is changed:"
{ $subsection make-generic }
"Low-level method constructor:"
{ $subsection <method> }
"Methods may be pushed on the stack with a literal syntax:"
{ $subsection POSTPONE: M\ }
{ $see-also "see" } ;

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
"Developing a custom method combination requires that a parsing word calling " { $link define-generic } " be defined; additionally, it is a good idea to implement the " { $link "definition-protocol" } " on the class of words having this method combination, to properly support developer tools."
$nl
"The combination quotation passed to " { $link define-generic } " has stack effect " { $snippet "( word -- quot )" } ". It's job is to call various introspection words, including at least obtaining the set of methods defined on the generic word, then combining these methods in some way to produce a quotation."
{ $see-also "generic-introspection" } ;

ARTICLE: "call-next-method" "Calling less-specific methods"
"If a generic word is called with an object and multiple methods specialize on classes that this object is an instance of, usually the most specific method is called (" { $link "method-order" } ")."
$nl
"Less-specific methods can be called directly:"
{ $subsection POSTPONE: call-next-method }
"A lower-level word which the above expands into:"
{ $subsection (call-next-method) }
"To look up the next applicable method reflectively:"
{ $subsection next-method }
"Errors thrown by improper calls to " { $link POSTPONE: call-next-method } ":"
{ $subsection inconsistent-next-method }
{ $subsection no-next-method } ;

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
"Generic words must declare their stack effect in order to compile. See " { $link "effects" } "."
{ $subsection "method-order" }
{ $subsection "call-next-method" }
{ $subsection "method-combination" }
{ $subsection "generic-introspection" }
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
{ $values { "word" word } { "effect" effect } { "combination" "a method combination" } }
{ $description "Defines a generic word. A method combination is an object which responds to the " { $link perform-combination } " generic word." }
{ $contract "The method combination quotation is called each time the generic word has to be updated (for example, when a method is added), and thus must be side-effect free." } ;

HELP: M\
{ $syntax "M\\ class generic" }
{ $class-description "Pushes a method on the stack." }
{ $examples { $code "M\\ fixnum + see" } { $code "USING: ui.gadgets ui.gadgets.editors ;" "M\\ editor draw-gadget* edit" } } ;

HELP: method-body
{ $class-description "The class of method bodies, which are words with special word properties set." } ;

HELP: method
{ $values { "class" class } { "generic" generic } { "method/f" { $maybe method-body } } }
{ $description "Looks up a method definition." } ;

{ method create-method POSTPONE: M: } related-words

HELP: <method>
{ $values { "class" class } { "generic" generic } { "method" "a new method definition" } }
{ $description "Creates a new method." } ;

HELP: order
{ $values { "generic" generic } { "seq" "a sequence of classes" } }
{ $description "Outputs a sequence of classes for which methods have been defined on this generic word. The sequence is sorted in method dispatch order." } ;

HELP: check-method
{ $values { "class" class } { "generic" generic } }
{ $description "Asserts that " { $snippet "class" } " is a class word and " { $snippet "generic" } " is a generic word, throwing a " { $link check-method } " error if the assertion fails." }
{ $error-description "Thrown if " { $link POSTPONE: M: } " or " { $link create-method } " is given an invalid class or generic word." } ;

HELP: with-methods
{ $values { "class" class } { "generic" generic } { "quot" { $quotation "( methods -- )" } } }
{ $description "Applies a quotation to the generic word's methods hashtable, and regenerates the generic word's definition when the quotation returns." }
$low-level-note ;

HELP: create-method
{ $values { "class" class } { "generic" generic } { "method" method-body } }
{ $description "Creates a method or returns an existing one. This is the runtime equivalent of " { $link POSTPONE: M: } "." }
{ $notes "To define a method, pass the output value to " { $link define } "." } ;

HELP: forget-methods
{ $values { "class" class } }
{ $description "Remove all method definitions which specialize on the class." } ;

{ sort-classes order } related-words

HELP: (call-next-method)
{ $values { "method" method-body } }
{ $description "Low-level word implementing " { $link POSTPONE: call-next-method } "." }
{ $notes "In most cases, " { $link POSTPONE: call-next-method } " should be used instead." } ;

HELP: no-next-method
{ $error-description "Thrown by " { $link POSTPONE: call-next-method } " if the current method is already the least specific method." }
{ $examples
    "The following code throws this error:"
    { $code
        "GENERIC: error-test ( object -- )"
        ""
        "M: number error-test 3 + call-next-method ;"
        ""
        "M: integer error-test recip call-next-method ;"
        ""
        "123 error-test"
    }
    "This results in the method on " { $link integer } " being called, which then calls the method on " { $link number } ". The latter then calls " { $link POSTPONE: call-next-method } ", however there is no method less specific than the method on " { $link number } " and so an error is thrown."
} ;
