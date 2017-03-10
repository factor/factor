! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes combinators.smart
continuations destructors fry io io.styles kernel namespaces
prettyprint sequences sets sorting ;
IN: tools.destructors

<PRIVATE

: class-tally ( set -- assoc' )
    members [ class-of ] collect-by ;

: (disposables.) ( set -- )
    class-tally >alist [ first2 [ length ] keep 3array ] map [ second ] sort-with
    standard-table-style [
        [
            [ "Disposable class" write ] with-cell
            [ "Instances" write ] with-cell
            [ ] with-cell
        ] with-row
        [
            [
                [
                    [ pprint-cell ]
                    [ pprint-cell ]
                    [ [ "[ List instances ]" swap write-object ] with-cell ]
                    tri*
                ] input<sequence
            ] with-row
        ] each
    ] tabular-output nl ;

: sort-disposables ( seq -- seq' )
    [ disposable? ] partition [ [ id>> ] sort-with ] dip append ;

PRIVATE>

: disposables. ( -- )
    disposables get (disposables.) ;

: disposables-of-class. ( class -- )
    [ disposables get members sort-disposables ] dip
    '[ _ instance? ] filter stack. ;

: leaks ( quot -- disposables )
    disposables get clone
    t debug-leaks? set-global
    [
        [ call disposables get clone ] dip
    ] [ f debug-leaks? set-global ] [ ] cleanup
    diff ; inline

: leaks. ( quot -- )
    leaks (disposables.) ; inline
