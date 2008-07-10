! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays strings sequences sequences.private
fry kernel words parser lexer assocs ;
IN: tr

<PRIVATE

: compute-tr ( quot from to -- mapping )
    zip [ 256 ] 2dip '[ [ @ , at ] keep or ] B{ } map-as ; inline

: tr-hints ( word -- )
    { { byte-array } { string } } "specializer" set-word-prop ;

: create-tr ( token -- word )
    create-in dup tr-hints ;

: define-tr ( word mapping -- )
    '[ [ , nth ] map ]
    (( seq -- translated ))
    define-declared ;

: define-fast-tr ( word mapping -- )
    '[ [ , nth-unsafe ] change-each ]
    (( seq -- ))
    define-declared ;

PRIVATE>

: TR:
    scan parse-definition
    unclip-last [ unclip-last ] dip compute-tr
    [ [ create-tr ] dip define-tr ]
    [ [ "-fast" append create-tr ] dip define-fast-tr ] 2bi ;
    parsing
