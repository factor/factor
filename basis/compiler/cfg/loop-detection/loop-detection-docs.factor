USING: compiler.cfg help.markup help.syntax ;
IN: compiler.cfg.loop-detection

HELP: needs-loops
{ $values { "cfg" cfg } }
{ $description "Runs loop detection for the cfg if it isn't valid." } ;
