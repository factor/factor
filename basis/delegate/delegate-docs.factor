USING: help.syntax help.markup delegate.private ;
IN: delegate

HELP: define-protocol
{ $values { "protocol" "a word for the new protocol" } { "wordlist" "a sequence of words" } }
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
{ $syntax "CONSULT: group class
    code ;" }
{ $values { "group" "a protocol, generic word or tuple class" } { "class" "a class" } { "code" "code to get the object to which the method should be forwarded" } }
{ $description "Declares that objects of " { $snippet "class" } " will delegate the generic words contained in " { $snippet "group" } " to the object returned by executing " { $snippet "code" } " with the original object as an input. " { $snippet "CONSULT:" } " will overwrite any existing methods on " { $snippet "class" } " for the members of " { $snippet "group" } ", but new methods can be added after the " { $snippet "CONSULT:" } " to override the delegation. Currently, this is only supported for " { $snippet "standard-combination" } " and " { $snippet "hook-combination" } " generics." }
{ $heading "Example" }
"The following code creates an " { $snippet "example-theme" } " that makes the status bar text green instead of white, and delegates all other " { $snippet "theme-protocol" } " words to " { $snippet "dark-theme" } "." $nl
{ $code "USING: delegate ui.theme ;" "" "SINGLETON: example-theme" "CONSULT: theme-protocol example-theme dark-theme ;" "" "M: example-theme status-bar-foreground COLOR: green ;" } ;

HELP: BROADCAST:
{ $syntax "BROADCAST: group class
    code ;" }
{ $values { "group" "a protocol, generic word or tuple class" } { "class" "a class" } { "code" "code to get the sequence of objects to all of which the method should be forwarded" } }
{ $description "Declares that objects of " { $snippet "class" } " will delegate the generic words contained in " { $snippet "group" } " to every object in the sequence returned by executing " { $snippet "code" } " with the original object as an input. " { $snippet "BROADCAST:" } " will overwrite any existing methods on " { $snippet "class" } " for the members of " { $snippet "group" } ", but new methods can be added after the " { $snippet "BROADCAST:" } " to override the delegation. Every generic word in " { $snippet "group" } " must return no outputs; otherwise, a " { $link broadcast-words-must-have-no-outputs } " error will be raised." } ;

HELP: SLOT-PROTOCOL:
{ $syntax "SLOT-PROTOCOL: protocol-name slots... ;" }
{ $description "Defines a protocol consisting of reader and writer words for the listed slot names." } ;

{ define-protocol POSTPONE: PROTOCOL: } related-words

{ define-consult POSTPONE: BROADCAST: POSTPONE: CONSULT: } related-words

HELP: group-words
{ $values { "group" "a group" } { "words" "an array of words" } }
{ $description "Given a protocol or tuple class, this returns the corresponding generic words that this group contains." } ;

ARTICLE: "delegate" "Delegation"
"The " { $vocab-link "delegate" } " vocabulary implements run-time consultation for method dispatch."
$nl
"A " { $emphasis "protocol" } " is a collection of related generic words. An object is said to " { $emphasis "consult" } " another object if it implements a protocol by forwarding all methods onto the other object."
$nl
"Using this vocabulary, protocols can be defined and consultation can be set up without any repetitive boilerplate."
$nl
"Unlike " { $link "tuple-subclassing" } ", which expresses " { $emphasis "is-a" } " relationships by statically including the methods and slots of the superclass in all subclasses, consultation forwards generic word calls to another distinct object."
$nl
"Defining new protocols:"
{ $subsections
    POSTPONE: PROTOCOL:
    define-protocol
}
"Defining new protocols consisting of slot accessors:"
{ $subsections POSTPONE: SLOT-PROTOCOL: }
"Defining consultation:"
{ $subsections
    POSTPONE: BROADCAST:
    POSTPONE: CONSULT:
    define-consult
}
"Every tuple class has an associated protocol consisting of all of its slot accessor methods. The " { $vocab-link "delegate.protocols" } " vocabulary defines formal protocols for the various informal protocols used in the Factor core, such as " { $link "sequence-protocol" } ", " { $link "assocs-protocol" } " or " { $link "stream-protocol" } "." ;

ABOUT: "delegate"
