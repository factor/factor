USING: assocs compiler.errors kernel namespaces sequences system tools.test ;
f restartable-tests? set-global
"resource:basis/io/files/unix/fixtures/fifo.factor" run-test-file
"resource:basis/io/files/unix/fixtures/fifo-append.factor" run-test-file
:test-failures
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
