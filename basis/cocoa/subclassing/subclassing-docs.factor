USING: help.markup help.syntax ;
IN: cocoa.subclassing

HELP: <CLASS:
{ $syntax "<CLASS: name < superclass protocols... imeth... ;CLASS>" }
{ $values { "name" "a new class name" } { "superclass" "a superclass name" } { "protocols" "zero or more protocol names" } { "imeth" "instance method definitions using " { $link POSTPONE: METHOD: } } }
{ $description "Defines a new Objective C class. Instance methods are defined with the " { $link POSTPONE: METHOD: } " parsing word."
$nl
"This word is preferred to calling " { $link define-objc-class } ", because it creates a class word in the " { $vocab-link "cocoa.classes" } " vocabulary at parse time, allowing code to refer to the class word in the same source file where the class is defined." } ;

{ define-objc-class POSTPONE: <CLASS: POSTPONE: METHOD: } related-words

HELP: METHOD:
{ $syntax "METHOD: return foo: type1 arg1 bar: type2 arg2 baz: ... [ body ] ;" }
{ $values { "return" "a C type name" } { "type1" "a C type name" } { "arg1" "a local variable name" } { "body" "arbitrary code" } }
{ $description "Defines a method inside of a " { $link POSTPONE: <CLASS: } " form." } ;

ARTICLE: "objc-subclassing" "Subclassing Objective C classes"
"Objective C classes can be subclassed, with new methods defined in Factor, using parsing words:"
{ $subsections POSTPONE: <CLASS: POSTPONE: METHOD: }
"Objective C class definitions are saved in the image. If the image is saved and Factor is restarted with the saved image, custom class definitions are made available to the Objective C runtime when they are first accessed from within Factor." ;

ABOUT: "objc-subclassing"
