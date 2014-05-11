USING: help.markup help.syntax make stack-checker.alien ;
IN: compiler.cfg.builder.alien

HELP: caller-return
{ $values { "params" alien-node-params } }
{ $description "If the last alien call returns a value, then this word will emit an instruction to the current sequence being constructed by " { $link make } " which boxes it." } ;
