IN: tools.disassembler
USING: help.markup help.syntax sequences.private ;

HELP: disassemble
{ $values { "obj" "a word or a pair of addresses" } }
{ $description "Disassembles either a compiled word definition or an arbitrary memory range (in the case " { $snippet "obj" } " is a pair of integers)." }
{ $notes "In some cases the Factor compiler emits data inline with code, which can confuse the disassembler. This occurs in words which call " { $link dispatch } ", where the jump table addresses are compiled inline." } ;

ARTICLE: "tools.disassembler" "Disassembling words"
"The " { $vocab-link "tools.disassembler" } " vocabulary provides support for disassembling compiled word definitions. It uses the " { $snippet "libudis86" } " library on x86-32 and x86-64, and " { $snippet "gdb" } " on PowerPC."
$nl
"See also " { $vocab-link "compiler.tree.debugger" } " and " { $vocab-link "compiler.cfg.debugger" } "."
$nl
{ $subsections disassemble } ;

ABOUT: "tools.disassembler"
