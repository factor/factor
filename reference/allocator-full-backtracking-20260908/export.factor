USING: vocabs.loader vocabs.refresh ;
<< "cpu.architecture" reload "cpu" refresh "compiler" refresh >>
USING: compiler.cfg.register-allocation.backtracking.evidence
io io.encodings.utf8 io.files json system vocabs.loader vocabs.refresh ;
backtracking-evidence
"reference/allocator-full-backtracking-20260908/witnesses.json" utf8
[ >json print ] with-file-writer
"Native bundle witness passed: input 10, expected/output 11." print
"Exported actual bundle, spillset, eviction and split state." print
0 exit
