USING: compiler.cfg compiler.cfg.instructions help.markup help.syntax ;
IN: compiler.cfg.save-contexts

HELP: insert-save-contexts
{ $values { "cfg" cfg } { "cfg'" cfg } }
{ $description "Inserts " { $link ##save-context } " instructions in each " { $link basic-block } " in the cfg that needs them. Save contexts are needed after instructions that modify the context, or instructions that read parameter registers." } ;

HELP: bb-needs-save-context?
{ $values { "bb" basic-block } { "?" "a boolean" } }
{ $description "Whether to insert a " { $link ##save-context } " instruction in the block or not." } ;
