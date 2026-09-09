USING: help.markup help.syntax kernel strings ;
IN: libudev

HELP: udev-function-available?
{ $values { "name" string } { "?" boolean } }
{ $description "Returns whether the loaded libudev exports the named function. Legacy functions may be absent on current runtimes." } ;

HELP: unavailable-udev-function
{ $description "The loaded libudev does not export the requested legacy entry point. Check udev-function-available? before using an optional interface. Socket-based legacy monitoring is not silently replaced by netlink monitoring." } ;
