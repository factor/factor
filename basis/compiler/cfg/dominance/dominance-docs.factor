USING: compiler.cfg compiler.cfg.dominance.private help.markup help.syntax
sequences ;
IN: compiler.cfg.dominance

HELP: dom-parents
{ $var-description "Maps bb -> idom(bb)" } ;

HELP: dom-children
{ $values { "bb" basic-block } { "seq" sequence } }
{ $description "Maps bb -> {bb' | idom(bb') = bb} or in other words, all basic blocks dominated by the given basic block." } ;

HELP: dom-parent
{ $values { "bb" basic-block } { "bb'" basic-block } }
{ $description "The basic block dominating the given block." } ;

HELP: needs-dominance
{ $values { "cfg" cfg } }
{ $description "Recalculates predecessor and dominance info for the given cfg." } ;

ARTICLE: "compiler.cfg.dominance" "A Simple, Fast Dominance Algorithm"
"A Simple, Fast Dominance Algorithm" $nl
"Keith D. Cooper, Timothy J. Harvey, and Ken Kennedy" $nl
"http://www.cs.rice.edu/~keith/EMBED/dom.pdf"
$nl
"Also, a nice overview is given in these lecture notes:" $nl
"http://llvm.cs.uiuc.edu/~vadve/CS526/public_html/Notes/4ssa.4up.pdf"
$nl
"To rebuild dominance information:"
{ $subsections needs-dominance }
"To read the dominance data:"
{ $subsections dom-children dom-parent } ;


ABOUT: "compiler.cfg.dominance"
