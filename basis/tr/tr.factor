! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: byte-arrays strings sequences sequences.private ascii
fry kernel words parser lexer assocs math math.order summary ;
IN: tr

ERROR: bad-tr ;

M: bad-tr summary
    drop "TR: can only be used with ASCII characters" ;

<PRIVATE

: tr-nth ( n mapping -- ch ) nth-unsafe 127 bitand ; inline

: check-tr ( from to -- )
    [ [ ascii? ] all? ] both? [ bad-tr ] unless ;

: compute-tr ( quot from to -- mapping )
    [ 128 ] 3dip zip
    '[ [ _ call( x -- y ) _ at ] keep or ] B{ } map-as ; inline

: tr-hints ( word -- )
    { { byte-array } { string } } "specializer" set-word-prop ;

: create-tr ( token -- word )
    create-in dup tr-hints ;

: tr-quot ( mapping -- quot )
    '[ [ dup ascii? [ _ tr-nth ] when ] map ] ;

: define-tr ( word mapping -- )
    tr-quot (( seq -- translated )) define-declared ;

: fast-tr-quot ( mapping -- quot )
    '[ [ _ tr-nth ] map! drop ] ;

: define-fast-tr ( word mapping -- )
    fast-tr-quot (( seq -- )) define-declared ;

PRIVATE>

SYNTAX: TR:
    scan parse-definition
    unclip-last [ unclip-last ] dip compute-tr
    [ check-tr ]
    [ [ create-tr ] dip define-tr ]
    [ [ "-fast" append create-tr ] dip define-fast-tr ] 2tri ;
