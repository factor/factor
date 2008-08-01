! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays strings sequences sequences.private
fry kernel words parser lexer assocs math.order ;
IN: tr

<PRIVATE

: compute-tr ( quot from to -- mapping )
    zip [ 256 ] 2dip '[ [ @ , at ] keep or ] B{ } map-as ; inline

: tr-hints ( word -- )
    { { byte-array } { string } } "specializer" set-word-prop ;

: create-tr ( token -- word )
    create-in dup tr-hints ;

: tr-quot ( mapping -- quot )
    '[ [ dup 0 255 between? [ , nth-unsafe ] when ] map ] ;

: define-tr ( word mapping -- )
    tr-quot (( seq -- translated )) define-declared ;

: fast-tr-quot ( mapping -- quot )
    '[ [ , nth-unsafe ] change-each ] ;

: define-fast-tr ( word mapping -- )
    fast-tr-quot (( seq -- )) define-declared ;

PRIVATE>

: TR:
    scan parse-definition
    unclip-last [ unclip-last ] dip compute-tr
    [ [ create-tr ] dip define-tr ]
    [ [ "-fast" append create-tr ] dip define-fast-tr ] 2bi ;
    parsing
