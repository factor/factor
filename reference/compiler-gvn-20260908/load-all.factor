USE: vocabs.refresh
refresh-all
USING: assocs compiler.cfg.value-numbering compiler.errors debugger io kernel memory namespaces parser.notes
prettyprint sequences system vocabs vocabs.hierarchy ;
parser-quiet? off auto-use? off
global-value-numbering? on
"LOAD-ALL START" print flush
load-all
"LOAD-ALL COMPLETE" print
"LOADED VOCABS " write loaded-vocab-names length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
compiler-errors get values [ print-error ] each flush
"/Users/erg/factor.worktrees/compiler-gvn/gvn-loaded.image" save-image
compiler-errors get assoc-empty? 0 1 ? exit
