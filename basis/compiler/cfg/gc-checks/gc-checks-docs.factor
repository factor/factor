USING: compiler.cfg compiler.cfg.instructions help.markup help.syntax kernel
layouts math sequences slots.private ;
IN: compiler.cfg.gc-checks

<PRIVATE

HELP: insert-gc-checks
{ $values { "cfg" cfg } { "cfg'" cfg } }
{ $description "Inserts gc checks in each " { $link basic-block } " in the cfg where they are needed." } ;

HELP: insert-gc-check?
{ $values { "bb" basic-block } { "?" "a boolean" } }
{ $description "Whether to insert a gc check in the block or not." } ;

HELP: blocks-with-gc
{ $values { "cfg" cfg } { "bbs" "a " { $link sequence } " of " { $link basic-block } } }
{ $description "Lists all basic blocks in the cfg that needs gc checks." } ;

HELP: allocation-size*
{ $values { "insn" insn } { "n" number } }
{ $description "Number of bytes allocated by the given instruction." } ;

HELP: allocation-size
{ $values { "insns" { $link sequence } " of " { $link insn } } { "n" number } }
{ $description "Calculates the total number of bytes allocated by the block." }
{ $examples
  { $example
    "USING: accessors compiler.cfg.debugger compiler.cfg.gc-checks.private kernel prettyprint sequences ;"
    "[ V{ } clone ] test-ssa first entry>> successors>> first instructions>> allocation-size ."
    "32"
  }
} ;

PRIVATE>

ARTICLE: "compiler.cfg.gc-checks" "Garbage collection check insertion"
"This pass runs after representation selection, since it needs to know which vregs can contain tagged pointers." ;

HELP: process-block
{ $values { "bb" basic-block } }
{ $description "Process a block that needs a gc check. New blocks are allocated and connected for the gc branches." } ;
