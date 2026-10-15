USING: io kernel modern.paths namespaces prettyprint sequences system
tools.test tools.test.private ;
IN: qemu.core-check

f restartable-tests? set-global
core-vocabs dup length "QEMU_CORE_VOCABS " write . flush
 test-vocabs
test-failures get dup length "QEMU_CORE_FAILURES " write .
empty? [ 0 ] [ :test-failures 1 ] if exit
