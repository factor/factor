USING: compiler.cfg compiler.cfg.registers cpu.architecture
help.markup help.syntax ;
IN: compiler.cfg.representations

HELP: select-representations
{ $values { "cfg" cfg } }
{ $description "Entry point for the representation selection compiler pass. After this word hasn run, the " { $link representations } " hashtable has been filled with vregs and what their preferred representations are." } ;

ARTICLE: "compiler.cfg.representations" "Virtual register representation selection"
"Virtual register representation selection. This is where decisions about integer tagging and float and vector boxing are made. The appropriate conversion operations inserted after a cost analysis."
$nl
"Good representation selection is very important for Factor because it uses tagged pointers. If the best representations are selected, then the number of conversions between " { $link int-rep } " and " { $link tagged-rep } " is minimized."
$nl
"Entry point:"
{ $subsections select-representations } ;

ABOUT: "compiler.cfg.representations"
