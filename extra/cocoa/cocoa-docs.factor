USING: cocoa cocoa.messages help.markup help.syntax strings
alien core-foundation ;

HELP: ->
{ $syntax "-> selector" }
{ $values { "selector" "an Objective C method name" } }
{ $description "A sugared form of the following:" }
{ $code "\"selector\" send" } ;

HELP: SUPER->
{ $syntax "-> selector" }
{ $values { "selector" "an Objective C method name" } }
{ $description "A sugared form of the following:" }
{ $code "\"selector\" send-super" } ;

{ send super-send POSTPONE: -> POSTPONE: SUPER-> } related-words

HELP: <NSString>
{ $values { "str" string } { "alien" alien } }
{ $description "Allocates an autoreleased " { $snippet "CFString" } "." } ;

{ <NSString> <CFString> CF>string } related-words

HELP: <NSArray>
{ $values { "seq" "a sequence of " { $link alien } " instances" } { "alien" alien } }
{ $description "Allocates an autoreleased " { $snippet "CFArray" } "." } ;

{ <NSArray> <CFArray> } related-words

ARTICLE: "objc-calling" "Calling Objective C code"
"Before an Objective C class can be used, it must be imported; by default, a small set of common classes are imported automatically, but additional classes can be imported as needed."
{ $subsection import-objc-class }
"Every imported Objective C class has as corresponding class word in the " { $vocab-link "objc-classes" } " vocabulary. Class words push the class object in the stack, allowing class methods to be invoked."
$nl
"Messages can be sent to classes and instances using a pair of parsing words:"
{ $subsection POSTPONE: -> }
{ $subsection POSTPONE: SUPER-> }
"These parsing words are actually syntax sugar for a pair of ordinary words; they can be used instead of the parsing words if the selector name is dynamically computed:"
{ $subsection send }
{ $subsection super-send } ;

IN: cocoa
ABOUT: "objc-calling"
