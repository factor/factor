USING: assocs compiler.cfg compiler.cfg.instructions compiler.cfg.stack-frame
help.markup help.syntax kernel ;
IN: compiler.cfg.build-stack-frame

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
{ $description "Calculates and stores the " { $slot "allot-area-base" } ", " { $slot "spill-area-base" } " and " { $slot "total-size" } " slots of a stack frame." } ;

ARTICLE: "compiler.cfg.build-stack-frame" "Computing stack frame size and layout"
"The " { $vocab-link "compiler.cfg.build-stack-frame" } " vocab builds stack frames for cfg:s." ;

ABOUT: "compiler.cfg.build-stack-frame"
