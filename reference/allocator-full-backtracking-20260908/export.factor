USING: vocabs.loader vocabs.refresh ;
<< "cpu.architecture" reload "cpu" refresh "compiler" refresh >>
USING: compiler.cfg.register-allocation.backtracking.evidence
io io.encodings.utf8 io.files json system vocabs.loader vocabs.refresh ;
"reference/allocator-full-backtracking-20260908/witnesses.json" utf8
[ backtracking-evidence >json print ] with-file-writer
0 exit
