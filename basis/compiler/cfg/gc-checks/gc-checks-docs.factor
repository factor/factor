USING: compiler.cfg compiler.cfg.gc-checks compiler.cfg.gc-checks.private
compiler.cfg.instructions help.markup help.syntax kernel layouts math sequences
slots.private ;
IN: compiler.cfg.gc-checks

HELP: add-gc-checks
{ $values { "insns-seq" "a sequence of instruction sequences" } }
{ $description "Insert a GC check at the end of every chunk but the last one. This ensures that every section other than the first has a GC check in the section immediately preceeding it." } ;

HELP: allocation-size
{ $values { "insns" { $link sequence } " of " { $link insn } } { "n" number } }
{ $description "Calculates the total number of bytes allocated by the instructions in a block." }
{ $examples
  { $unchecked-example
    "USING: accessors compiler.cfg.debugger compiler.cfg.gc-checks.private kernel prettyprint sequences ;"
    "[ V{ } clone ] test-ssa first entry>> successors>> first instructions>> allocation-size ."
    "32 ! 16 on 32-bit"
  }
} ;

HELP: allocation-size*
{ $values { "insn" insn } { "n" number } }
{ $description "Number of bytes allocated by the given instruction." } ;

HELP: blocks-with-gc
{ $values { "cfg" cfg } { "bbs" "a " { $link sequence } " of " { $link basic-block } } }
{ $description "Lists all basic blocks in the cfg that needs gc checks." } ;

HELP: gc-check-offsets
{ $values { "insns" sequence } { "seq" sequence } }
{ $description "A basic block is divided into sections by " { $link ##call } " and " { $link ##phi } " instructions. For every section with at least one allocation, record the offset of its first instruction in a sequence." } ;

HELP: insert-gc-check?
{ $values { "bb" basic-block } { "?" boolean } }
{ $description "Whether to insert a gc check in the block or not. Only blocks with allocation instructions require gc checks." }
{ $see-also allocation-insn } ;

HELP: insert-gc-checks
{ $values { "cfg" cfg } }
{ $description "Inserts gc checks in each " { $link basic-block } " in the cfg where they are needed." } ;

HELP: process-block
{ $values { "bb" basic-block } }
{ $description "Process a block that needs a gc check. New blocks are allocated and connected for the gc branches." } ;


ARTICLE: "compiler.cfg.gc-checks" "Garbage collection check insertion"
"This pass runs after representation selection, since it needs to know which vregs can contain tagged pointers." ;

ABOUT: "compiler.cfg.gc-checks"
