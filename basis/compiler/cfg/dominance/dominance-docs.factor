USING: compiler.cfg compiler.cfg.dominance.private help.markup help.syntax
sequences ;
IN: compiler.cfg.dominance

HELP: dom-parents
{ $var-description "Maps bb -> idom(bb)" } ;

HELP: dom-children
{ $values { "bb" basic-block } { "seq" sequence } }
{ $description "Maps bb -> {bb' | idom(bb') = bb}" } ;

ARTICLE: "compiler.cfg.dominance" "A Simple, Fast Dominance Algorithm" $nl
"A Simple, Fast Dominance Algorithm" $nl
"Keith D. Cooper, Timothy J. Harvey, and Ken Kennedy" $nl
"http://www.cs.rice.edu/~keith/EMBED/dom.pdf"
$nl
"Also, a nice overview is given in these lecture notes:" $nl
"http://llvm.cs.uiuc.edu/~vadve/CS526/public_html/Notes/4ssa.4up.pdf" ;

ABOUT: "compiler.cfg.dominance"
