USING: compiler.cfg.instructions cpu.architecture help.markup help.syntax
math ;
IN: compiler.cfg.registers

HELP: vreg-counter
{ $var-description "Virtual registers, used by CFG and machine IRs, are just integers." } ;

HELP: next-vreg
{ $values { "vreg" number } }
{ $description "Creates a new virtual register identifier." }
{ $notes "This word cannot be called after representation selection has run; use " { $link next-vreg-rep } " in that case." } ;

HELP: rep-of
{ $values { "vreg" number } { "rep" representation } }
{ $description "Gets the representation for a virtual register. This word cannot be called before representation selection has run; use any-rep for " { $link ##copy } " instructions and so on." }
{ $notes "Throws " { $link bad-vreg } " if the representation for the vreg isn't known." } ;

HELP: representations
{ $var-description "Mapping from vregs to their representations." } ;

HELP: set-rep-of
{ $values { "rep" representation } { "vreg" number } }
{ $description "Sets the representation for a virtual register." } ;

HELP: next-vreg-rep
{ $values { "rep" representation } { "vreg" number } }
{ $description "Creates a new virtual register identifier and sets its representation." }
{ $notes "This word cannot be called before representation selection has run; use " { $link next-vreg } " in that case." } ;

HELP: loc
{ $class-description "Represents a location on the stack. 'n' is an index starting from the top of the stack going down. So 0 is the top of the stack, 1 is what would be the top of the stack after a 'drop', and so on. It has two subclasses, " { $link ds-loc } " for data stack location and " { $link rs-loc } " for locations on the retain stack." } ;

ARTICLE: "compiler.cfg.registers" "Virtual single-assignment registers"
"Virtual register assignment." ;

ABOUT: "compiler.cfg.registers"
