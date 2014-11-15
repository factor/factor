USING: assocs compiler.cfg compiler.cfg.stack-frame help.markup help.syntax ;
IN: compiler.cfg.build-stack-frame

ARTICLE: "compiler.cfg.build-stack-frame" "Computing stack frame size and layout"
"The " { $vocab-link "compiler.cfg.build-stack-frame" } " vocab builds stack frames for cfg:s." ;

HELP: frame-required?
{ $var-description "Whether the word being compiled requires a stack frame or not. Most words does, but very simple words does not." } ;

HELP: compute-stack-frame
{ $values { "cfg" cfg } { "stack-frame/f" stack-frame } }
{ $description "Initializes a stack frame for a cfg, if it needs one." }
{ $see-also frame-required? } ;

HELP: finalize-stack-frame
{ $values { "stack-frame" stack-frame } }
{ $description "Calculates the " { $slot "allot-area-base" } ", " { $slot "spill-area-base" } " and " { $slot "total-size" } " slots of a stack frame." } ;

ABOUT: "compiler.cfg.build-stack-frame"
