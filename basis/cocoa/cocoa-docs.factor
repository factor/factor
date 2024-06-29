USING: cocoa.messages help.markup help.syntax strings
alien core-foundation ;
IN: cocoa

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

HELP: IMPORT:
{ $syntax "IMPORT: name" }
{ $description "Makes an Objective C class available for use." }
{ $examples
    { $code "IMPORT: QTMovie" "QTMovie \"My Movie.mov\" <NSString> f -> movieWithFile:error:" }
} ;

ARTICLE: "objc-calling" "Calling Objective C code"
"Before an Objective C class can be used, it must be imported; by default, a small set of common classes are imported automatically, but additional classes can be imported as needed."
{ $subsections POSTPONE: IMPORT: }
"Every imported Objective C class has as corresponding class word in the " { $vocab-link "cocoa.classes" } " vocabulary. Class words push the class object in the stack, allowing class methods to be invoked."
$nl
"Messages can be sent to classes and instances using a pair of parsing words:"
{ $subsections
    POSTPONE: ->
    POSTPONE: SUPER->
}
"These parsing words are actually syntax sugar for a pair of ordinary words; they can be used instead of the parsing words if the selector name is dynamically computed:"
{ $subsections
    send
    super-send
} ;

ARTICLE: "cocoa" "Cocoa bridge"
"The " { $vocab-link "cocoa" } " vocabulary implements a Factor-Cocoa bridge for macOS (GNUstep is not supported)."
$nl
"The lowest layer uses the " { $link "alien" } " to define bindings for the various functions in Apple's Objective-C runtime. This is defined in the " { $vocab-link "cocoa.runtime" } " vocabulary."
$nl
"On top of this, a dynamic message send facility is built:"
{ $subsections
    "objc-calling"
    "objc-subclassing"
}
"A utility library is built to facilitate the development of Cocoa applications in Factor:"
{ $subsections
    "cocoa-application-utils"
    "cocoa-dialogs"
    "cocoa-pasteboard-utils"
    "cocoa-view-utils"
    "cocoa-window-utils"
} ;

ABOUT: "cocoa"
