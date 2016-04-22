USING: compiler.cfg compiler.cfg.instructions
compiler.cfg.ssa.interference.live-ranges.private help.markup
help.syntax math ;
IN: compiler.cfg.ssa.interference.live-ranges

HELP: compute-live-ranges
{ $values { "cfg" cfg } }
{ $description "Entry point for the live ranges computation compiler pass." } ;

HELP: record-uses
{ $values { "n" integer } { "insn" insn } }
{ $description "Record live intervals so that all but the first input interfere with the output. This lets us coalesce the output with the first input." } ;

ARTICLE: "compiler.cfg.ssa.interference.live-ranges"
"Live ranges for interference testing"
"Live ranges for interference testing" ;

ABOUT: "compiler.cfg.ssa.interference.live-ranges"
