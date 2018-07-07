USING: help.markup help.syntax strings alien ;
IN: cocoa.messages

HELP: send
{ $values { "receiver" alien } { "args..." "method arguments" } { "signature" "signature" } { "selector" string } { "return..." "value returned by method, if any" } }
{ $description "Sends an Objective C message named by " { $snippet "selector" } " to " { $snippet "receiver" } ". The arguments must be on the stack in left-to-right order." }
{ $errors "Throws an error if the receiver does not recognize the message, or if the arguments have inappropriate types." }
{ $notes "This word uses a special fast code path if " { $snippet "selector" } " is a literal and the word containing the call to " { $link send } " is compiled." } ;

HELP: super-send
{ $values { "receiver" alien } { "args..." "method arguments" } { "signature" "signature" } { "selector" string } { "return..." "value returned by method, if any" } }
{ $description "Sends an Objective C message named by " { $snippet "selector" } " to the super class of " { $snippet "receiver" } ". Otherwise behaves identically to " { $link send } "." } ;

HELP: objc-class
{ $values { "string" string } { "class" alien } }
{ $description "Outputs the Objective C class named by " { $snippet "string" } ". This class can then be used as the receiver in message sends calling class methods, for example:"
{ $code "NSMutableArray -> alloc" } }
{ $errors "Throws an error if there is no class named by " { $snippet "string" } "." } ;

HELP: objc-meta-class
{ $values { "string" string } { "class" alien } }
{ $description "Outputs the meta class of the Objective C class named by " { $snippet "string" } "." }
{ $errors "Throws an error if there is no meta class named by " { $snippet "string" } "." } ;

HELP: objc>alien-types
{ $var-description "Hashtable mapping Objective C type identifiers to alien types. See " { $link "c-data" } "." } ;

HELP: alien>objc-types
{ $var-description "Hashtable mapping alien types to Objective C type identifiers. See " { $link "c-data" } "." } ;

{ objc>alien-types alien>objc-types } related-words

HELP: import-objc-class
{ $values { "name" string } { "quot" { $quotation ( -- ) } } }
{ $description "If a class named " { $snippet "name" } " is already known to the Objective C interface, does nothing. Otherwise, first calls the quotation. The quotation should make the class available to the Objective C runtime if necessary, either by loading a framework or defining it directly. After the quotation returns, this word makes the class available to Factor programs by importing methods and creating a class word the class object in the " { $vocab-link "cocoa.classes" } " vocabulary." } ;

HELP: root-class
{ $values { "class" alien } { "root" alien } }
{ $description "Outputs the class at the root of the inheritance hierarchy for " { $snippet "class" } ". In most cases this will be the " { $snippet "NSObject" } " class." } ;
