USING: help.markup help.syntax io kernel
prettyprint.sections words ;
IN: prettyprint.config

ABOUT: "prettyprint-variables"

HELP: tab-size
{ $var-description "Prettyprinter tab size. Indent nesting is always a multiple of the tab size." } ;

HELP: margin
{ $var-description "The maximum line length, in characters. Lines longer than the margin are wrapped." } ;

HELP: nesting-limit
{ $var-description "The maximum nesting level. Structures that nest further than this will simply print as a pound sign (#). The default is " { $link f } ", denoting unlimited nesting depth." } ;

HELP: length-limit
{ $var-description "The maximum printed sequence length. Sequences longer than this are truncated, and \"...\" is output in place of remaining elements. The default is " { $link f } ", denoting unlimited sequence length." } ;

HELP: line-limit
{ $var-description "The maximum number of lines output by the prettyprinter before output is truncated with \"...\". The default is " { $link f } ", denoting unlimited line count." } ;

HELP: number-base
{ $var-description "The number base in which the prettyprinter will output numeric literals. A value of " { $snippet "2" } " will print integers and ratios in binary with " { $link POSTPONE: BIN: } ", and " { $snippet "8" } " will print them in octal with " { $link POSTPONE: OCT: } ". A value of " { $snippet "16" } " will print all integers, ratios, and floating-point values in hexadecimal with " { $link POSTPONE: HEX: } ". Other values of " { $snippet "number-base" } " will print numbers in decimal, which is the default." } ;

HELP: string-limit?
{ $var-description "Toggles whether printed strings are truncated to the margin." } ;

HELP: boa-tuples?
{ $var-description "Toggles whether tuples and structs print in BOA-form or assoc-form." }
{ $notes "See " { $link POSTPONE: T{ } " for a description of both literal tuple forms." } ;

HELP: c-object-pointers?
{ $var-description "Toggles whether C objects such as structs and direct arrays only print their underlying address. If this flag isn't set, C objects will attempt to print their contents. If a C object points to invalid memory, it will display only its address regardless." } ;
