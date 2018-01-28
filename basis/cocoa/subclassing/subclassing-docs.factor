USING: help.markup help.syntax strings alien hashtables ;
IN: cocoa.subclassing

HELP: \<CLASS:
{ $syntax "<CLASS: name < superclass protocols... imeth... ;CLASS>" }
{ $values { "name" "a new class name" } { "superclass" "a superclass name" } { "protocols" "zero or more protocol names" } { "imeth" "instance method definitions using " { $link postpone: \COCOA-METHOD: } } }
{ $description "Defines a new Objective C class. Instance methods are defined with the " { $link postpone: \COCOA-METHOD: } " parsing word."
$nl
"This word is preferred to calling " { $link define-objc-class } ", because it creates a class word in the " { $vocab-link "cocoa.classes" } " vocabulary at parse time, allowing code to refer to the class word in the same source file where the class is defined." } ;

{ define-objc-class postpone: \<CLASS: postpone: \COCOA-METHOD: } related-words

HELP: \COCOA-METHOD:
{ $syntax "COCOA-METHOD: return foo: type1 arg1 bar: type2 arg2 baz: ... [ body ] ;" }
{ $values { "return" "a C type name" } { "type1" "a C type name" } { "arg1" "a local variable name" } { "body" "arbitrary code" } }
{ $description "Defines a method inside of a " { $link postpone: \<CLASS: } " form." } ;

ARTICLE: "objc-subclassing" "Subclassing Objective C classes"
"Objective C classes can be subclassed, with new methods defined in Factor, using parsing words:"
{ $subsections postpone: \<CLASS: postpone: \COCOA-METHOD: }
"Objective C class definitions are saved in the image. If the image is saved and Factor is restarted with the saved image, custom class definitions are made available to the Objective C runtime when they are first accessed from within Factor." ;

ABOUT: "objc-subclassing"
