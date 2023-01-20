! Copyright (C) 2007 Slava Pestov, 2009 Alex Chapman
! See https://factorcode.org/license.txt for BSD license.
USING: boxes help.markup help.syntax kernel math namespaces assocs ;
IN: refs

ARTICLE: "refs" "References"
"References provide a uniform way of accessing and changing values. Some examples of referenced values are variables, tuple slots, and keys or values of assocs. References can be read, written, and deleted. References are defined in the " { $vocab-link "refs" } " vocabulary, and new reference types can be made by implementing a protocol."
{ $subsections
    "refs-protocol"
    "refs-impls"
    "refs-utils"
}
"References are used by the " { $link "ui-inspector" } "." ;

ABOUT: "refs"

ARTICLE: "refs-impls" "Reference implementations"
"References to objects:"
{ $subsections
    obj-ref
    <obj-ref>
}
"References to assoc keys:"
{ $subsections
    key-ref
    <key-ref>
}
"References to assoc values:"
{ $subsections
    value-ref
    <value-ref>
}
"References to variables:"
{ $subsections
    var-ref
    <var-ref>
    global-var-ref
    <global-var-ref>
}
"References to tuple slots:"
{ $subsections
    slot-ref
    <slot-ref>
}
"Using boxes as references:"
{ $subsections "box-refs" } ;

ARTICLE: "refs-utils" "Reference utilities"
{ $subsections
    ref-on
    ref-off
    ref-inc
    ref-dec
    set-ref*
} ;

ARTICLE: "refs-protocol" "Reference protocol"
"To use a class of objects as references you must implement the reference protocol for that class, and mark your class as an instance of the " { $link ref } " mixin class. All references must implement these two words:"
{ $subsections
    get-ref
    set-ref
}
"References may also implement:"
{ $subsections delete-ref } ;

ARTICLE: "box-refs" "Boxes as references"
{ $link "boxes" } " are elements of the " { $link ref } " mixin class, so any box may be used as a reference. Bear in mind that boxes will still throw an error if you call " { $link get-ref } " on an empty box." ;

HELP: ref
{ $class-description "A mixin class whose instances encapsulate a value which can be read, written, and deleted. Instantiable members of this class include:" { $link obj-ref } ", " { $link var-ref } ", " { $link global-var-ref } ", " { $link slot-ref } ", " { $link box } ", " { $link key-ref } ", and " { $link value-ref } "." } ;

HELP: delete-ref
{ $values { "ref" ref } }
{ $description "Deletes the value pointed to by this reference. In most references this simply sets the value to f, but in some cases it is more destructive, such as in " { $link value-ref } " and " { $link key-ref } ", where it actually deletes the entry from the underlying assoc." } ;

HELP: get-ref
{ $values { "ref" ref } { "obj" object } }
{ $description "Outputs the value pointed at by this reference." } ;

HELP: set-ref
{ $values { "obj" object } { "ref" ref } }
{ $description "Stores a new value at this reference." } ;

HELP: obj-ref
{ $class-description "Instances of this class contain a value which can be changed using the " { $link "refs-protocol" } ". New object references are created by calling " { $link <obj-ref> } "." } ;

HELP: <obj-ref>
{ $values { "obj" object } { "obj-ref" obj-ref } }
{ $description "Creates a reference which contains the value it references." } ;

HELP: var-ref
{ $class-description "Instances of this class reference a variable as defined by the " { $vocab-link "namespaces" } " vocabulary. New variable references are created by calling " { $link <var-ref> } "." } ;

HELP: <var-ref>
{ $values { "var" object } { "var-ref" var-ref } }
{ $description "Creates a reference to the given variable. Note that this reference behaves just like any variable when it comes to dynamic scope. For example, if you use " { $link set-ref } " in an inner scope and then leave that scope, then calling " { $link get-ref } " may not return the expected value. If this is not what you want, try using an " { $link obj-ref } " instead." } ;

HELP: global-var-ref
{ $class-description "Instances of this class reference a global variable. New global references are created by calling " { $link <global-var-ref> } "." } ;

HELP: <global-var-ref>
{ $values { "var" object } { "global-var-ref" global-var-ref } }
{ $description "Creates a reference to a global variable." } ;

HELP: slot-ref
{ $class-description "Instances of this class identify a particular slot of a particular instance of a tuple. New slot references are created by calling " { $link <slot-ref> } "." } ;

HELP: <slot-ref>
{ $values { "tuple" tuple } { "slot" integer } { "slot-ref" slot-ref } }
{ $description "Creates a reference to the value in a particular slot of the given tuple. The slot must be given as an integer, where the first user-defined slot is number 2. This is mostly just a proof of concept until we have a way of generating this slot number from a slot name." } ;

HELP: key-ref
{ $class-description "Instances of this class identify a key in an associative structure. New key references are created by calling " { $link <key-ref> } "." } ;

HELP: <key-ref>
{ $values { "assoc" assoc } { "key" object } { "key-ref" key-ref } }
{ $description "Creates a reference to a key stored in an assoc." } ;

HELP: value-ref
{ $class-description "Instances of this class identify a value associated to a key in an associative structure. New value references are created by calling " { $link <value-ref> } "." } ;

HELP: <value-ref>
{ $values { "assoc" assoc } { "key" object } { "value-ref" value-ref } }
{ $description "Creates a reference to the value associated with " { $snippet "key" } " in " { $snippet "assoc" } "." } ;

{ get-ref set-ref delete-ref set-ref* } related-words

{ <obj-ref> <var-ref> <global-var-ref> <slot-ref> <key-ref> <value-ref> } related-words

HELP: set-ref*
{ $values { "ref" ref } { "obj" object } }
{ $description "Just like " { $link set-ref } ", but leave the ref on the stack." } ;

HELP: ref-on
{ $values { "ref" ref } }
{ $description "Sets the value of the ref to t." } ;

HELP: ref-off
{ $values { "ref" ref } }
{ $description "Sets the value of the ref to f." } ;

HELP: ref-inc
{ $values { "ref" ref } }
{ $description "Increment the value of the ref by 1." } ;

HELP: ref-dec
{ $values { "ref" ref } }
{ $description "Decrement the value of the ref by 1." } ;

HELP: take
{ $values { "ref" ref } { "obj" object } }
{ $description "Retrieve the value of the ref and then delete it, returning the value." } ;

{ ref-on ref-off ref-inc ref-dec take } related-words
{ take delete-ref } related-words
{ on ref-on } related-words
{ off ref-off } related-words
{ inc ref-inc } related-words
{ dec ref-dec } related-words
