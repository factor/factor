USING: classes classes.algebra combinators effects generic.hook
generic.math generic.single generic.standard help.markup
help.syntax math words ;
IN: generic

ARTICLE: "method-order" "Method precedence"
"Conceptually, method dispatch is implemented by testing the object against the predicate word for every class, in linear order (" { $link "class-linearization" } ")."
$nl
"Here is an example:"
{ $code
    "GENERIC: explain ( object -- )"
    "M: object explain drop \"an object\" print ;"
    "M: generic explain drop \"a generic word\" print ;"
    "M: class explain drop \"a class word\" print ;"
}
"The linear order is the following, from least-specific to most-specific:"
{ $code "{ object generic class }" }
"Neither " { $link class } " nor " { $link generic } " are subclasses of each other, and their intersection is non-empty. Calling " { $snippet "explain" } " with a word on the stack that is both a class and a generic word will print " { $snippet "a class word" } " because " { $link class } " is more specific than " { $link generic } " in the class linearization order. (One example of a word which is both a class and a generic word is the class of classes, " { $link class } ", which is also a word to get the class of an object.)"
$nl
"The " { $link dispatch-order } " word can be useful to clarify method dispatch order:"
{ $subsections dispatch-order } ;

ARTICLE: "generic-introspection" "Generic word introspection"
"In most cases, generic words and methods are defined at parse time with " { $link POSTPONE: GENERIC: } " (or some other parsing word) and " { $link POSTPONE: M: } "."
$nl
"Sometimes, generic words need to be inspected or defined at run time; words for performing these tasks are found in the " { $vocab-link "generic" } " vocabulary."
$nl
"The set of generic words is a class which implements the " { $link "definition-protocol" } ":"
{ $subsections
    generic
    generic?
}
"New generic words can be defined:"
{ $subsections
    define-generic
    define-simple-generic
}
"Methods can be added to existing generic words:"
{ $subsections create-method }
"Method definitions can be looked up:"
{ $subsections lookup-method ?lookup-method }
"Finding the most specific method for an object:"
{ $subsections effective-method }
"A generic word contains methods; the list of methods specializing on a class can also be obtained:"
{ $subsections implementors }
"Low-level word which rebuilds the generic word after methods are added or removed, or the method combination is changed:"
{ $subsections make-generic }
"Low-level method constructor:"
{ $subsections <method> }
"Methods may be pushed on the stack with a literal syntax:"
{ $subsections POSTPONE: M\ }
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
    { { $link POSTPONE: GENERIC#: } { $link standard-combination } }
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
{ $subsections POSTPONE: call-next-method }
"A lower-level word which the above expands into:"
{ $subsections (call-next-method) }
"To look up the next applicable method reflectively:"
{ $subsections next-method }
"Errors thrown by improper calls to " { $link POSTPONE: call-next-method } ":"
{ $subsections
    inconsistent-next-method
    no-next-method
} ;

ARTICLE: "generic" "Generic words and methods"
"A " { $emphasis "generic word" } " is composed of zero or more " { $emphasis "methods" } " together with a " { $emphasis "method combination" } ". A method " { $emphasis "specializes" } " on a class; when a generic word is executed, the method combination chooses the most appropriate method and calls its definition."
$nl
"A generic word behaves roughly like a long series of class predicate conditionals in a " { $link cond } " form, however methods can be defined in independent source files, reducing coupling and increasing extensibility. The method combination determines which object the generic word will " { $emphasis "dispatch" } " on; this could be the top of the stack, or some other value."
$nl
"Generic words which dispatch on the object at the top of the stack:"
{ $subsections POSTPONE: GENERIC: }
"A method combination which dispatches on a specified stack position:"
{ $subsections POSTPONE: GENERIC#: }
"A method combination which dispatches on the value of a variable at the time the generic word is called:"
{ $subsections POSTPONE: HOOK: }
"A method combination which dispatches on a pair of stack values, which must be numbers, and upgrades both to the same type of number:"
{ $subsections POSTPONE: MATH: }
"Method definition:"
{ $subsections POSTPONE: M: }
"Generic words must declare their stack effect in order to compile. See " { $link "effects" } "."
{ $subsections
    "method-order"
    "call-next-method"
    "method-combination"
    "generic-introspection"
}
"Generic words specialize behavior based on the class of an object; sometimes behavior needs to be specialized on the object's " { $emphasis "structure" } "; this is known as " { $emphasis "pattern matching" } " and is implemented in the " { $vocab-link "match" } " vocabulary." ;

ABOUT: "generic"

HELP: generic
{ $class-description "The class of generic words, documented in " { $link "generic" } "." } ;

{ generic define-generic define-simple-generic POSTPONE: GENERIC: POSTPONE: GENERIC#: POSTPONE: MATH: POSTPONE: HOOK: } related-words

HELP: make-generic
{ $values { "word" generic } }
{ $description "Regenerates the definition of a generic word by applying the method combination to the set of defined methods." }
$low-level-note ;

HELP: define-generic
{ $values { "word" word } { "combination" "a method combination" } { "effect" effect } }
{ $description "Defines a generic word. A method combination is an object which responds to the " { $link perform-combination } " generic word." }
{ $contract "The method combination quotation is called each time the generic word has to be updated (for example, when a method is added), and thus must be side-effect free." } ;

HELP: M\
{ $syntax "M\\ class generic" }
{ $description "Pushes a method on the stack." }
{ $examples { $code "M\\ fixnum + see" } { $code "USING: ui.gadgets.editors ui.render ;" "M\\ editor draw-gadget* edit" } } ;

HELP: method
{ $class-description "The class of method bodies, which are words with special word properties set." } ;

HELP: lookup-method
{ $values { "class" class } { "generic" generic } { "method" method } }
{ $description "Looks up a method definition." }
{ $errors "Throws an error if the method does not exist." } ;

HELP: ?lookup-method
{ $values { "class" class } { "generic" generic } { "method/f" { $maybe method } } }
{ $description "Looks up a method definition." } ;

{ lookup-method ?lookup-method create-method POSTPONE: M: } related-words

HELP: <method>
{ $values { "class" class } { "generic" generic } { "method" "a new method definition" } }
{ $description "Creates a new method." } ;

HELP: dispatch-order
{ $values { "generic" generic } { "seq" { $sequence class } } }
{ $description "Outputs a sequence of classes for which methods have been defined on this generic word. The sequence is sorted in method dispatch order." } ;

HELP: check-method
{ $values { "class" class } { "generic" generic } }
{ $description "Asserts that " { $snippet "class" } " is a class word and " { $snippet "generic" } " is a generic word, throwing a " { $link check-method } " error if the assertion fails." }
{ $error-description "Thrown if " { $link POSTPONE: M: } " or " { $link create-method } " is given an invalid class or generic word." } ;

HELP: with-methods
{ $values { "class" class } { "generic" generic } { "quot" { $quotation ( methods -- ) } } }
{ $description "Applies a quotation to the generic word's methods hashtable, and regenerates the generic word's definition when the quotation returns." }
$low-level-note ;

HELP: create-method
{ $values { "class" class } { "generic" generic } { "method" method } }
{ $description "Creates a method or returns an existing one. This is the runtime equivalent of " { $link POSTPONE: M: } "." }
{ $notes "To define a method, pass the output value to " { $link define } "." } ;

{ sort-classes dispatch-order } related-words

HELP: (call-next-method)
{ $values { "method" method } }
{ $description "Low-level word implementing " { $link POSTPONE: call-next-method } "." }
{ $notes
    "The " { $link POSTPONE: call-next-method } " word parses into this word. The following are equivalent:"
    { $code
        "M: class generic call-next-method ;"
        "M: class generic M\\ class generic (call-next-method) ;"
    }
} ;

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

HELP: make-consult-quot
! { $values { "consultation" object } { "word" word } { "quot" quotation } { "combination" combination } }
{ $contract "This generic produces the body quotation that will be used to actually effect a method consultation from the " { $vocab-link "delegate" } "vocabulary." }
{ $notes "This is already implemented for " { $snippet "standard-combination" } " and " { $snippet "hook-combination" } ", and thus only needs to be specialized if you are implementing " { $snippet "CONSULT:" } " for a different kind of combination." }
{ $heading "Reasoning" }
"For standard method combinations, this calls the quotation to obtain the consulted object, and then executes the generic word, which naturally dispatches against the object on the stack. This is not sufficient for hook combinations, which must have the generic word executed with a variable bound to the result of the quotation. This generic is what allows for specializing the behavior of the methods that " { $snippet "CONSULT:" } " creates." ;
