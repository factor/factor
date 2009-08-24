! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs classes destructors fry kernel math namespaces
prettyprint sequences sets sorting ;
IN: tools.destructors

<PRIVATE

: disposable-tally ( -- assoc )
    disposables get
    H{ } clone [ [ keys ] dip '[ class _ inc-at ] each ] keep ;

: subtract-values ( assoc1 assoc2 -- assoc )
    [ [ keys ] bi@ append prune ] 2keep
    H{ } clone [
        '[
            [ _ _ [ at 0 or ] bi-curry@ bi - ] keep _ set-at
        ] each
    ] keep ;

: (disposables.) ( assoc -- )
    >alist sort-keys simple-table. ;

PRIVATE>

: disposables. ( -- )
    disposable-tally (disposables.) ;

: leaks ( quot -- )
    disposable-tally [ call disposable-tally ] dip subtract-values
    (disposables.) ; inline
