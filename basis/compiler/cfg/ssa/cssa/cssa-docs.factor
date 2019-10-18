USING: compiler.cfg.representations help.markup help.syntax ;
IN: compiler.cfg.ssa.cssa

ARTICLE: "compiler.cfg.ssa.cssa" "Conventional SSA Form"
"Convert SSA to conventional SSA. This pass runs after representation selection (see " { $link select-representations } "), so it must keep track of representations when introducing new values." ;

ABOUT: "compiler.cfg.ssa.cssa"
