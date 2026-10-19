! SH3 CPU selection is a metadata import control, not native SH execution.
! The VM capability is real; optimizer suppression is scoped to this import.
USING: arrays command-line compiler.units continuations io kernel locals math
math.floats.env math.floats.env.private namespaces parser sequences
system prettyprint ;
IN: sh.integer-env.probe
: rejects-env? ( quot -- ? )
    [ call( -- ) f ] [ nip floating-point-unsupported? ] recover ;
: false-env-controls ( -- ? )
    {
        [ fp-exception-flags drop ]
        [ fp-traps drop ]
        [ rounding-mode drop ]
        [ denormal-mode drop ]
        [ { } set-fp-exception-flags ]
        [ { } set-fp-traps ]
        [ +round-nearest+ set-rounding-mode ]
        [ +denormal-keep+ set-denormal-mode ]
        [ get-fp-env 2drop 2drop ]
        [ f f f f set-fp-env ]
        [ clear-fp-exception-flags ]
        [ [ ] collect-fp-exceptions drop ]
    } [ rejects-env? ] map dup . [ ] all? ;
: true-env-control ( -- ? )
    get-fp-env 4array dup [ first4 set-fp-env ] dip
    get-fp-env 4array = ;
:: sh3-load ( path -- )
    cpu :> original
    [
        sh3.32 \ cpu set-global
        [ path run-file ] [ original \ cpu set-global ] finally
    ] without-optimizer ;
: unsupported-cpu? ( path -- ? )
    [ sh3-load f ]
    [ nip "CPU architecture unsupported by math.floats.env" = ] recover ;
: main ( -- )
    floating-point-supported? [ 9 exit ] when
    command-line get first2
    "original" = [
        unsupported-cpu? dup "SH3-ORIGINAL-METADATA-REJECTED" print .
        [ 1 ] [ 3 ] if exit
    ] [
        dup sh3-load
        "SH3-INTEGER-METADATA-IMPORT-PASS" print
        drop false-env-controls [ 0 ] [ 4 ] if exit
    ] if ;
main
