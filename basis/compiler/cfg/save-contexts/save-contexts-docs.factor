USING: compiler.cfg compiler.cfg.instructions help.markup help.syntax ;
IN: compiler.cfg.save-contexts

HELP: insert-save-contexts
{ $values { "cfg" cfg } { "cfg'" cfg } }
{ $description "Inserts " { $link ##save-context } " instructions in each " { $link basic-block } " in the cfg that needs them. Save contexts are needed after instructions that modify the context, or instructions that read parameter registers." }
{ $see-also needs-save-context? } ;

HELP: bb-needs-save-context?
{ $values { "bb" basic-block } { "?" "a boolean" } }
{ $description "Whether to insert a " { $link ##save-context } " instruction in the block or not." }
{ $see-also needs-save-context? } ;

HELP: needs-save-context?
{ $description "Whether the given instruction needs to be preceeded by a " { $link ##save-context } " instruction or not. Only instructions that can allocate memory mandates save contexts." }
{ $see-also gc-map-insn } ;
