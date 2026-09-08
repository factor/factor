USING: help.markup help.syntax ;
IN: compiler.cfg.value-numbering

HELP: global-value-numbering?
{ $var-description "Enables global common subexpression elimination in the value-numbering stage. Disabled by default pending broader performance evidence. Bind this variable while compiling to compare global reuse with the local simplifier." }
{ $description "Global numbering analyzes a fixed SSA graph, then reuses available congruent values. It handles integer calculations and phis. Floating-point operations, mutable loads and derived-pointer conversions are excluded. Literal loads remain near their uses to avoid increasing register pressure. The existing local simplifier performs all instruction rewriting and constant folding." } ;

ARTICLE: "compiler.cfg.value-numbering" "Value numbering"
"The value-numbering stage simplifies instructions and eliminates repeated expressions within each basic block. SSA literal information is shared across blocks so the existing folder can fold exact integer-to-float conversions. Inexact floating-point conversions remain at runtime."
{ $subsections global-value-numbering? } ;

ABOUT: "compiler.cfg.value-numbering"
