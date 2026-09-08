USE: vocabs.refresh
refresh-all
USING: db.postgresql accessors assocs compiler.cfg.value-numbering compiler.errors debugger io kernel math namespaces
prettyprint quotations sequences system tools.annotations tools.test
tools.test.private words ;
f restartable-tests? set-global
global-value-numbering? on
silent-tests? on
T{ postgresql-db { host "127.0.0.1" } { port "64581" } { username "erg" } } \ postgresql-db set-global
\ run-test-file [ [ dup "TEST-FILE " write print flush ] prepose ] annotate
\ notify-test-failed [ [
    "FAILURE-DETAIL " write
    test-failures get last
    [ path>> print ] [ line#>> . ] [ error>> print-error ] tri flush
] append ] annotate
"TEST-ALL START" print flush
test-all
"TEST-ALL COMPLETE" print
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ [ path>> print ] [ line#>> . ] [ error>> print-error ] tri ] each
compiler-errors get values [ print-error ] each flush
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
