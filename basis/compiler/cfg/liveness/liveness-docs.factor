USING: compiler.cfg.instructions help.markup help.syntax ;
IN: compiler.cfg.liveness

HELP: fill-gc-map
{ $values { "live-set" "no idea" } { "insn" insn } }
{ $description "Assigns values to the " { $slot "gc-roots" } " and " { $slot "derived-roots" } " slots of an instructions " { $link gc-map } "." } ;
