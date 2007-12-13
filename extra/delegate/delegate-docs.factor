USING: delegate help.syntax help.markup ;

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

HELP: define-mimic
{ $values { "group" "a protocol, generic word or tuple class" } { "mimicker" "a class" } { "mimicked" "a class" } }
{ $description "For the generic words in the group, the given mimicker copies the methods of the mimicked. This only works for the methods that have already been defined when the word is called." }
{ $notes "Usually, " { $link POSTPONE: MIMIC: } " should be used instead. This is only for runtime use." } ;

HELP: MIMIC:
{ $syntax "MIMIC: group mimicker mimicked" }
{ $values { "group" "a protocol, generic word or tuple class" } { "mimicker" "a class" } { "mimicked" "a class" } }
{ $description "For the generic words in the group, the given mimicker copies the methods of the mimicked. This only works for the methods that have already been defined when the syntax is used. Mimicking overwrites existing methods." } ;

HELP: group-words
{ $values { "group" "a group" } { "words" "an array of words" } }
{ $description "Given a protocol, generic word or tuple class, this returns the corresponding generic words that this group contains." } ;

ARTICLE: { "delegate" "intro" } "Delegation module"
"This vocabulary defines methods for consultation and mimicry, independent of the current Factor object system; it is a replacement for Factor's builtin delegation system. Fundamental to the concept of generic word groups, which can be specific protocols, generic words or tuple slot accessors. Fundamentally, a group is a word which has a method for " { $link group-words } ". To define a group as a set of words, use"
{ $subsection POSTPONE: PROTOCOL: }
{ $subsection define-protocol }
"One method of object extension which this vocabulary defines is consultation. This is slightly different from the current Factor concept of delegation, in that instead of delegating for all generic words not implemented, only generic words included in a specific group are consulted. Additionally, instead of using a single hard-coded delegate slot, you can specify any quotation to execute in order to retrieve who to consult. The literal syntax and defining word are"
{ $subsection POSTPONE: CONSULT: }
{ $subsection define-consult }
"Another object extension mechanism is mimicry. This is the copying of methods in a group from one class to another. For certain applications, this is more appropriate than delegation, as it avoids the slicing problem. It is inappropriate for tuple slots, however. The literal syntax and defining word are"
{ $subsection POSTPONE: MIMIC: }
{ $subsection define-mimic } ;

IN: delegate
ABOUT: { "delegate" "intro" }
