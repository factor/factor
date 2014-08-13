USING: compiler.cfg compiler.cfg.instructions help.markup help.syntax ;
IN: compiler.cfg.stacks.uninitialized

HELP: compute-uninitialized-sets
{ $values { "cfg" cfg } }
{ $description "Runs the uninitialized compiler pass. The pass serves two purposes; if a " { $link ##peek } " reads an uninitialized stack location, then an error is thrown. Second, it assigns the " { $slot "scrub-d" } " and " { $slot "scrub-r" } " slots of all " { $link gc-map } " instances in the cfg." } ;
