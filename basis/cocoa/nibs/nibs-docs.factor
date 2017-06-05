USING: help.markup help.syntax sequences strings ;
IN: cocoa.nibs

HELP: load-nib
{ $values { "name" string } }
{ $description "Loads an Interface Builder " { $snippet ".nib" } " file with the given name." } ;

HELP: nib-named
{ $values { "nib-name" string } { "anNSNib" "an instance of NSNib" } }
{ $description "Looks up the " { $snippet ".nib" } " in the main bundle with the given name, instantiating an autoreleased NSNib object. Useful when combined with the " { $link nib-objects } " word. " { $snippet "f" } " is returned in case of error." }
{ $see-also nib-objects } ;

HELP: nib-objects
{ $values { "anNSNib" "an instance of NSNib" } { "objects/f" { $maybe sequence } } }
{ $description "Instantiates the top-level objects of the " { $snippet ".nib" } " file loaded by anNSNib. First create an NSNib instance using " { $link nib-named } "." }
{ $see-also nib-named } ;
