USING: help.syntax help.markup ;
IN: delegate

HELP: define-protocol
{ $values { "wordlist" "a sequence of words" } { "protocol" "a word for the new protocol" } }
{ $description "Defines a symbol as a protocol." }
{ $notes "Usually, " { $link POSTPONE: PROTOCOL: } " should be used instead. This is only for runtime use." } ;

HELP: PROTOCOL:
{ $syntax "PROTOCOL: protocol-name words... ;" }
{ $description "Defines an explicit protocol, which can be used as a basis for delegation or mimicry." } ;

{ define-protocol POSTPONE: PROTOCOL: } related-words

HELP: define-consult
{ $values { "class" "a class" } { "group" "a protocol, generic word or tuple class" } { "quot" "a quotation" } }
{ $description "Defines a class to consult, using the given quotation, on the generic words contained in the group." }
{ $notes "Usually, " { $link POSTPONE: CONSULT: } " should be used instead. This is only for runtime use." } ;

HELP: CONSULT:
{ $syntax "CONSULT: group class getter... ;" } 
{ $values { "group" "a protocol, generic word or tuple class" } { "class" "a class" } { "getter" "code to get where the method should be forwarded" } }
{ $description "Defines a class to consult, using the given code, on the generic words contained in the group. This means that, when one of the words in the group is called on an object of this class, the quotation will be called, and then the generic word called again. If the getter is empty, this will cause an infinite loop. Consultation overwrites the existing methods, but others can be defined afterwards." } ;

{ define-consult POSTPONE: CONSULT: } related-words

HELP: group-words
{ $values { "group" "a group" } { "words" "an array of words" } }
{ $description "Given a protocol or tuple class, this returns the corresponding generic words that this group contains." } ;

ARTICLE: { "delegate" "intro" } "Delegation"
"The " { $vocab-link "delegate" } " vocabulary implements run-time consultation for method dispatch."
$nl
"Fundamental to the concept of " { $emphasis "protocols" } ", which are groups of tuple slot accessors, or groups of arbtirary generic words."
$nl
"This allows an object to implement a certain protocol by passing the method calls to another object."
$nl
"Unlike " { $link "tuple-subclassing" } ", which expresses " { $emphasis "is-a" } " relationships by statically including the methods and slots of the superclass in all subclasses, consultation forwards generic word calls to another distinct object."
$nl
"Fundamentally, a protocol is a word which has a method for " { $link group-words } ". One type of protocol is a tuple, which consists of the slot accessors. To define a protocol as a set of words, use"
{ $subsection POSTPONE: PROTOCOL: }
{ $subsection define-protocol }
"The literal syntax and defining word are:"
{ $subsection POSTPONE: CONSULT: }
{ $subsection define-consult }
"The " { $vocab-link "delegate.protocols" } " vocabulary defines formal protocols for the various informal protocols used in the Factor core, such as " { $link "sequence-protocol" } ", " { $link "assocs-protocol" } " or " { $link "stream-protocol" } ;

IN: delegate
ABOUT: { "delegate" "intro" }
