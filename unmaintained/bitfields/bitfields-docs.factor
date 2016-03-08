USING: help.markup help.syntax ;
IN: bitfields

HELP: BITFIELD:
{ $syntax "BITFIELD: name slot:size... ;" }
{ $values { "name" "name of bitfield" }  { "slot" "names of slots" } { "size" "sizes of slots" } }
{ $description "Creates a new bitfield specification, with the constructor <name> and slot accessors of the form name-slot. Slots' values can be changed by words of the form with-name-slot, with the stack effect " { $code "( newvalue bitfield -- newbitfield )" } ". The slots have the amount of space specified, in bits, after the colon. The constructor and setters do not check to make sure there is no overflow, and any inappropriately high value (except in the first field) will corrupt the bitfield. To check overflow, use " { $link POSTPONE: SAFE-BITFIELD: } " instead. Padding can be included by writing the binary number to be used as a pad in the middle of the bitfield specification. The first slot written will have the most significant digits. Note that bitfields do not form a class; they are merely integers. For efficiency across platforms, it is often the best to keep the total size at or below 29, allowing fixnums to be used on all platforms." }
{ $see-also define-bitfield } ;

HELP: define-bitfield
{ $values { "classname" "a string" } { "slots" "slot specifications" } }
{ $description "Defines a bitfield constructor and slot accessors and setters. The workings of these are described in more detail at " { $link POSTPONE: BITFIELD: } ". The slot specifications should be an assoc. Any key which looks like a binary number will be treated as padding." } ;

HELP: SAFE-BITFIELD:
{ $syntax "SAFE-BITFIELD: name slot:size... ;" }
{ $values { "name" "name of bitfield" } { "slot" "name of slots" } { "size" "size in bits of slots" } }
{ $description "Defines a bitfield in the same way as " { $link POSTPONE: BITFIELD: } " but the constructor and slot setters check for overflow." } ;
