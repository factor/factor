! Copyright (C) 2007 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: refs

ARTICLE: "refs" "References to assoc entries"
"A " { $emphasis "reference" } " is an object encapsulating an assoc and a key; the reference then refers to either the key itself, or the value associated to the key. References can be read, written, and deleted. References are defined in the " { $vocab-link "refs" } " vocabulary."
{ $subsection get-ref }
{ $subsection set-ref }
{ $subsection delete-ref }
"References to keys:"
{ $subsection key-ref }
{ $subsection <key-ref> }
"References to values:"
{ $subsection value-ref }
{ $subsection <value-ref> }
"References are used by the UI inspector." ;

ABOUT: "refs"

HELP: ref
{ $class-description "A class whose instances identify a key or value location in an associative structure. Instances of this clas are never used directly; only instances of " { $link key-ref } " and " { $link value-ref } " should be created." } ;

HELP: delete-ref
{ $values { "ref" ref } }
{ $description "Deletes the association entry pointed at by this reference." } ;

HELP: get-ref
{ $values { "ref" ref } { "obj" object } }
{ $description "Outputs the key or the value pointed at by this reference." } ;

HELP: set-ref
{ $values { "obj" object } { "ref" ref } }
{ $description "Stores a new key or value at by this reference." } ;

HELP: key-ref
{ $class-description "Instances of this class identify a key in an associative structure. New key references are created by calling " { $link <key-ref> } "." } ;

HELP: <key-ref>
{ $values { "assoc" "an assoc" } { "key" object } { "key-ref" key-ref } }
{ $description "Creates a reference to a key stored in an assoc." } ;

HELP: value-ref
{ $class-description "Instances of this class identify a value associated to a key in an associative structure. New value references are created by calling " { $link <value-ref> } "." } ;

HELP: <value-ref>
{ $values { "assoc" "an assoc" } { "key" object } { "value-ref" value-ref } }
{ $description "Creates a reference to the value associated with " { $snippet "key" } " in " { $snippet "assoc" } "." } ;

{ get-ref set-ref delete-ref } related-words

{ <key-ref> <value-ref> } related-words
