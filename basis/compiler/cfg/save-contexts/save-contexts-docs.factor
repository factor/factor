USING: compiler.cfg compiler.cfg.instructions help.markup help.syntax
math sequences ;
IN: compiler.cfg.save-contexts

HELP: insert-save-contexts
{ $values { "cfg" cfg } }
{ $description "Inserts " { $link ##save-context } " instructions in each " { $link basic-block } " in the cfg that needs them. Save contexts are needed after instructions that modify the context, or instructions that read parameter registers." }
{ $see-also context-save-needed } ;

HELP: insns-needs-save-context?
{ $values { "insns" sequence } { "?" "a boolean" } }
{ $description "Whether to insert a " { $link ##save-context } " instruction in the given instruction sequence or not." }
{ $see-also context-save-needed } ;

HELP: context-save-needed
{ $class-description "Union class of all instructions that needs to be preceeded by a " { $link ##save-context } " instruction. Only instructions that can allocate memory mandates save contexts." } ;

HELP: save-context-offset
{ $values { "insns" sequence } { "n" integer } }
{ $description { $link "##save-context" } " must be placed after instructions that modify the context, or instructions that read parameter registers." } ;

ARTICLE: "compiler.cfg.save-contexts" "Insert context saves"
"Inserts " { $link ##save-context } " in blocks that need them." ;

ABOUT: "compiler.cfg.save-contexts"
