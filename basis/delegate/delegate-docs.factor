USING: help.syntax help.markup delegate.private ;
IN: delegate

HELP: define-protocol
{ $values { "wordlist" "a sequence of words" } { "protocol" "a word for the new protocol" } }
{ $description "Defines a symbol as a protocol." }
{ $notes "Usually, " { $link POSTPONE: PROTOCOL: } " should be used instead. This is only for runtime use." } ;

HELP: PROTOCOL:
{ $syntax "PROTOCOL: protocol-name words... ;" }
{ $description "Defines an explicit protocol, which can be used as a basis for delegation." } ;

{ define-protocol POSTPONE: PROTOCOL: } related-words

HELP: define-consult
{ $values { "consultation" consultation } }
{ $description "Defines a class to consult, using the quotation, on the generic words contained in the group." }
{ $notes "Usually, " { $link POSTPONE: CONSULT: } " should be used instead. This is only for runtime use." } ;

HELP: CONSULT:
{ $syntax "CONSULT: group class getter... ;" } 
{ $values { "group" "a protocol, generic word or tuple class" } { "class" "a class" } { "getter" "code to get where the method should be forwarded" } }
{ $description "Defines a class to consult, using the given code, on the generic words contained in the group. This means that, when one of the words in the group is called on an object of this class, the quotation will be called, and then the generic word called again. If the getter is empty, this will cause an infinite loop. Consultation overwrites the existing methods, but others can be defined afterwards." } ;

HELP: SLOT-PROTOCOL:
{ $syntax "SLOT-PROTOCOL: protocol-name slots... ;" }
{ $description "Defines a protocol consisting of reader and writer words for the listed slot names." } ;

{ define-protocol POSTPONE: PROTOCOL: } related-words

{ define-consult POSTPONE: CONSULT: } related-words

HELP: group-words
{ $values { "group" "a group" } { "words" "an array of words" } }
{ $description "Given a protocol or tuple class, this returns the corresponding generic words that this group contains." } ;

ARTICLE: "delegate" "Delegation"
"The " { $vocab-link "delegate" } " vocabulary implements run-time consultation for method dispatch."
$nl
"A " { $emphasis "protocol" } " is a collection of related generic words. An object is said to " { $emphasis "consult" } " another object if it implements a protocol by forwarding all methods onto the other object."
$nl
"Using this vocabulary, protocols can be defined and consulation can be set up without any repetitive boilerplate."
$nl
"Unlike " { $link "tuple-subclassing" } ", which expresses " { $emphasis "is-a" } " relationships by statically including the methods and slots of the superclass in all subclasses, consultation forwards generic word calls to another distinct object."
$nl
"Defining new protocols:"
{ $subsection POSTPONE: PROTOCOL: }
{ $subsection define-protocol }
"Defining new protocols consisting of slot accessors:"
{ $subsection POSTPONE: SLOT-PROTOCOL: }
"Defining consultation:"
{ $subsection POSTPONE: CONSULT: }
{ $subsection define-consult }
"Every tuple class has an associated protocol consisting of all of its slot accessor methods. The " { $vocab-link "delegate.protocols" } " vocabulary defines formal protocols for the various informal protocols used in the Factor core, such as " { $link "sequence-protocol" } ", " { $link "assocs-protocol" } " or " { $link "stream-protocol" } ;

ABOUT: "delegate"
