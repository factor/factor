USING: assocs compiler.cfg compiler.cfg.instructions compiler.cfg.stack-frame
help.markup help.syntax kernel math ;
IN: compiler.cfg.build-stack-frame

HELP: build-stack-frame
{ $values { "cfg" cfg } }
{ $description "Main word of the " { $vocab-link "compiler.cfg.build-stack-frame" } " compiler pass." } ;

HELP: compute-stack-frame
{ $values { "cfg" cfg } { "stack-frame/f" stack-frame } }
{ $description "Initializes a stack frame for a cfg, if it needs one." }
{ $see-also compute-stack-frame* } ;

HELP: compute-stack-frame*
{ $values { "insn" insn } { "?" boolean } }
{ $description "Computes required stack frame size for the instruction. If a stack frame is needed, then " { $link t } " is returned." } ;

HELP: param-area-size
{ $var-description "Temporary variable used when building stack frames to calculate the parameter area size." }
{ $see-also build-stack-frame } ;

HELP: finalize-stack-frame
{ $values { "stack-frame" stack-frame } }
{ $description "Calculates and stores the " { $slot "allot-area-base" } ", " { $slot "spill-area-base" } " and " { $slot "total-size" } " slots of a stack frame." }
{ $errors "Throws " { $link stack-frame-too-large } " if the total size exceeds " { $link max-stack-frame-size } "." } ;

HELP: stack-frame-too-large
{ $values { "size" integer } { "max" integer } }
{ $description "Throws an error indicating that a word needs a stack frame of " { $snippet "size" } " bytes, larger than the " { $snippet "max" } " bytes the VM can record in a code block header." } ;

ARTICLE: "compiler.cfg.build-stack-frame" "Computing stack frame size and layout"
"The " { $vocab-link "compiler.cfg.build-stack-frame" } " vocab builds stack frames for cfg:s."
$nl
"Main word:"
{ $subsections build-stack-frame } ;

ABOUT: "compiler.cfg.build-stack-frame"
