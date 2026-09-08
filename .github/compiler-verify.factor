USING: assocs compiler.cfg.checker compiler.cfg.linear-scan.allocation.state
compiler.errors debugger io kernel namespaces sequences system tools.test vocabs.hierarchy ;
IN: compiler-verify
f restartable-tests? set-global
check-ssa? on
check-allocation? on
"compiler" [ load ] [ test ] bi
: test-status ( -- status )
    test-failures get empty? compiler-errors get assoc-empty? and [ 0 ] [
        :test-failures compiler-errors get values [ print-error ] each 1
    ] if ;
test-status flush exit
