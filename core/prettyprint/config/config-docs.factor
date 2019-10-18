USING: help.markup help.syntax io kernel prettyprint
prettyprint.sections words ;
IN: prettyprint.config

ABOUT: "prettyprint-variables"

HELP: indent
{ $var-description "The prettyprinter's current indent level." } ;

HELP: pprinter-stack
{ $var-description "A stack of " { $link block } " objects currently being constructed by the prettyprinter." } ;

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

HELP: string-limit
{ $var-description "Toggles whether printed strings are truncated to the margin." } ;
