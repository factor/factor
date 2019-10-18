USING: compiler.cfg.instructions compiler.cfg.stacks.finalize
help.markup help.syntax ;
IN: compiler.cfg.stacks.global

HELP: avail
{ $class-description "A stack location is available at a location if all paths from the entry block to the location load the location into a register." } ;

HELP: anticip
{ $class-description "A stack location is anticipated at a location if every path from the location to an exit block will read the stack location before writing it." } ;

HELP: dead
{ $class-description "A stack location is dead at a location if no paths from the location to the exit block read the location before writing it." } ;

HELP: live
{ $class-description "A stack location is live at a location if some path from the location to an exit block will read the stack location before writing it." } ;

HELP: pending
{ $class-description "A stack location is pending at a location if all paths from the entry block to the location write the location." } ;

ARTICLE: "compiler.cfg.stacks.global" "Global stack analysis"
"This vocab defines a bunch of dataflow analyses:"
{ $subsections avail anticip dead live pending }
"The info they gather is used by " { $link finalize-stack-shuffling } " for optimal insertion of " { $link ##peek } " and " { $link ##replace } " instructions." ;

ABOUT: "compiler.cfg.stacks.global"
