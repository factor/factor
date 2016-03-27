USING: compiler.cfg compiler.cfg.instructions help.markup help.syntax
kernel math memory sequences ;
IN: compiler.cfg.save-contexts

HELP: insert-save-contexts
{ $values { "cfg" cfg } }
{ $description "Inserts " { $link ##save-context } " instructions in each " { $link basic-block } " in the cfg that needs them. Save contexts are needed after instructions that modify the context, or instructions that read parameter registers." }
{ $see-also insns-needs-save-context? } ;

HELP: insns-needs-save-context?
{ $values { "insns" sequence } { "?" boolean } }
{ $description "Whether to insert a " { $link ##save-context } " instruction in the given instruction sequence or not. Only instructions that can allocate memory mandates save contexts." }
{ $see-also gc-map-insn } ;

HELP: save-context-offset
{ $values { "insns" sequence } { "n" integer } }
{ $description { $link ##save-context } " must be placed after instructions that modify the context, or instructions that read parameter registers." } ;

ARTICLE: "compiler.cfg.save-contexts" "Insert context saves"
"Inserts " { $link ##save-context } " in blocks that need them. If an instruction does something that might trigger a GC sweep, such as calling a C function, then the context must be saved before."
$nl
"Main word:"
{ $subsections insert-save-contexts }
{ $notes "The " { $link ##call-gc } " instruction does not need a context save because the primitive implementing the instruction (" { $link minor-gc } ") already saves the context for us." } ;

ABOUT: "compiler.cfg.save-contexts"
