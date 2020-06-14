USING: compiler.cfg compiler.cfg.loop-detection help.markup
help.syntax ;
IN: compiler.cfg.loop-detection+docs

HELP: needs-loops
{ $values { "cfg" cfg } }
{ $description "Runs loop detection for the cfg if it isn't valid." } ;
