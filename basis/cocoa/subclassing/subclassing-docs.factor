USING: help.markup help.syntax strings alien hashtables ;
IN: cocoa.subclassing

HELP: define-objc-class
{ $values { "imeth" "a sequence of instance method definitions" } { "hash" hashtable } }
{ $description "Defines a new Objective C class. The hashtable can contain the following keys:"
    { $list
        { { $link +name+ } " - a string naming the new class. Required." }
        { { $link +superclass+ } " - a string naming the superclass. Required." }
        { { $link +protocols+ } " - an array of strings naming protocols implemented by the superclass. Optional." }
    }
"Every element of " { $snippet "imeth" } " defines an instance method, and is an array having the shape "
{ $snippet "{ name return args quot }" }
".:"
{ $table
    { "name" { "a selector name" } }
    { "name" { "a C type name; see " { $link "c-data" } } }
    { "args" { "a sequence of C type names; see " { $link "c-data" } } }
    { "quot" { "a quotation to be run as a callback when the method is invoked; see " { $link alien-callback } } }
}
"The quotation is run with the following values on the stack:"
{ $list
    { "the receiver of the message; an " { $link alien } " pointing to an instance of this class" }
    { "the selector naming the message; in most cases this value can be ignored" }
    "arguments passed to the message, if any"
}
"There is no way to define instance variables or class methods using this mechanism. However, instance variables can be simulated by using the receiver to key into an assoc." } ;

HELP: CLASS:
{ $syntax "CLASS: spec imeth... ;" }
{ $values { "spec" "an array of pairs" } { "name" "a new class name" } { "imeth" "instance method definitions using " { $link POSTPONE: METHOD: } } }
{ $description "Defines a new Objective C class. The hashtable can contain the following keys:"
{ $list
    { { $link +name+ } " - a string naming the new class. Required." }
    { { $link +superclass+ } " - a string naming the superclass. Required." }
    { { $link +protocols+ } " - an array of strings naming protocols implemented by the superclass. Optional." }
}
"Instance methods are defined with the " { $link POSTPONE: METHOD: } " parsing word."
$nl
"This word is preferred to calling " { $link define-objc-class } ", because it creates a class word in the " { $vocab-link "cocoa.classes" } " vocabulary at parse time, allowing code to refer to the class word in the same source file where the class is defined." } ;

{ define-objc-class POSTPONE: CLASS: POSTPONE: METHOD: } related-words

HELP: METHOD:
{ $syntax "METHOD: return foo: type1 arg1 bar: type2 arg2 baz: ... [ body ]" }
{ $values { "return" "a C type name" } { "type1" "a C type name" } { "arg1" "a local variable name" } { "body" "arbitrary code" } }
{ $description "Defines a method inside of a " { $link POSTPONE: CLASS: } " form." } ;

ARTICLE: "objc-subclassing" "Subclassing Objective C classes"
"Objective C classes can be subclassed, with new methods defined in Factor, using parsing words:"
{ $subsections POSTPONE: CLASS: POSTPONE: METHOD: }
"This word is actually syntax sugar for an ordinary word:"
{ $subsections define-objc-class }
"Objective C class definitions are saved in the image. If the image is saved and Factor is restarted with the saved image, custom class definitions are made available to the Objective C runtime when they are first accessed from within Factor." ;

IN: cocoa.subclassing
ABOUT: "objc-subclassing"
