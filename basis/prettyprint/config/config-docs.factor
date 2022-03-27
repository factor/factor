USING: help.markup help.syntax io kernel
prettyprint.sections words quotations ;
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
{ $var-description "The number base in which the prettyprinter will output numeric literals. A value of " { $snippet "2" } " will print integers and ratios in binary with " { $snippet "0b" } ". A value of " { $snippet "8" } " will print them in octal with " { $snippet "0o" } ". A value of " { $snippet "16" } " will print all integers, ratios, and floating-point values in hexadecimal with " { $snippet "0x" } ". Other values of " { $snippet "number-base" } " will print numbers in decimal, which is the default." } ;

HELP: string-limit?
{ $var-description "Toggles whether printed strings are truncated to the margin." } ;

HELP: boa-tuples?
{ $var-description "Toggles whether tuples and structs print in BOA-form or assoc-form." }
{ $notes "See " { $link POSTPONE: T{ } " for a description of both literal tuple forms." } ;

HELP: c-object-pointers?
{ $var-description "Toggles whether C objects such as structs and direct arrays only print their underlying address. If this flag isn't set, C objects will attempt to print their contents. If a C object points to invalid memory, it will display only its address regardless." } ;

HELP: has-limits?
{ $var-description "Used to indicate that prettyprint limits have been set." } ;

HELP: (with-short-limits)
{ $values { "quot" quotation } }
{ $description "Calls a quotation in a new dynamic scope with prettyprinter limits set to produce a single line of output." } ;

HELP: with-short-limits
{ $values { "quot" quotation } }
{ $description "Calls a quotation in a new dynamic scope with prettyprinter limits set to produce a single line of output, if " { $link has-limits? } " is not set." } ;

{ with-short-limits (with-short-limits) } related-words

HELP: (without-limits)
{ $values { "quot" quotation } }
{ $description "Calls a quotation in a new dynamic scope with prettyprinter limits set to produce unlimited output." } ;

HELP: without-limits
{ $values { "quot" quotation } }
{ $description "Calls a quotation in a new dynamic scope with prettyprinter limits set to produce unlimited output, if " { $link has-limits? } " is not set." } ;

{ without-limits (without-limits) } related-words
