USING: help.markup help.syntax strings alien hashtables ;
IN: cocoa.subclassing

HELP: define-objc-class
{ $values { "hash" hashtable } { "imeth" "a sequence of instance method definitions" } }
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
"There is no way to define instance variables or class methods using this mechanism. However, instance variables can be simulated by using the receiver to key into a hashtable." } ;

HELP: CLASS:
{ $syntax "CLASS: spec imeth... ;" }
{ $values { "spec" "an array of pairs" } { "name" "a new class name" } { "imeth" "instance method definitions" } }
{ $description "A sugared form of the following:"
    { $code "{ imeth... } \"spec\" define-objc-class" }
"This word is preferred to calling " { $link define-objc-class } ", because it creates a class word in the " { $vocab-link "cocoa.classes" } " vocabulary at parse time, allowing code to refer to the class word in the same source file where the class is defined." } ;

{ define-objc-class POSTPONE: CLASS: } related-words

ARTICLE: "objc-subclassing" "Subclassing Objective C classes"
"Objective C classes can be subclassed, with new methods defined in Factor, using a parsing word:"
{ $subsections POSTPONE: CLASS: }
"This word is actually syntax sugar for an ordinary word:"
{ $subsections define-objc-class }
"Objective C class definitions are saved in the image. If the image is saved and Factor is restarted with the saved image, custom class definitions are made available to the Objective C runtime when they are first accessed from within Factor." ;

IN: cocoa.subclassing
ABOUT: "objc-subclassing"
