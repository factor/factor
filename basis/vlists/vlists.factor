! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs grouping kernel math parser
persistent.assocs persistent.sequences sequences
sequences.private vectors vocabs.loader ;
IN: vlists

TUPLE: vlist
{ length array-capacity read-only }
{ vector vector read-only } ;

: <vlist> ( -- vlist ) 0 V{ } clone vlist boa ; inline

M: vlist length length>> ;

M: vlist nth-unsafe vector>> nth-unsafe ;

<PRIVATE

: >vlist< ( vlist -- len vec )
    [ length>> ] [ vector>> ] bi ; inline

: unshare ( len vec -- len vec' )
    clone [ set-length ] 2keep ; inline

PRIVATE>

M: vlist ppush
    >vlist<
    2dup length = [ unshare ] unless
    [ [ 1 + swap ] dip push ] keep vlist boa ;

ERROR: empty-vlist-error ;

M: vlist ppop
    [ empty-vlist-error ]
    [ [ length>> 1 - ] [ vector>> ] bi vlist boa ] if-empty ;

M: vlist clone
    [ length>> ] [ vector>> >vector ] bi vlist boa ;

M: vlist equal?
    over vlist? [ sequence= ] [ 2drop f ] if ;

: >vlist ( seq -- vlist )
    [ length ] [ >vector ] bi vlist boa ; inline

M: vlist like
    drop dup vlist? [ >vlist ] unless ;

INSTANCE: vlist immutable-sequence

SYNTAX: VL{ \ } [ >vlist ] parse-literal ;

TUPLE: valist { vlist vlist read-only } ;

: <valist> ( -- valist ) <vlist> valist boa ; inline

M: valist assoc-size vlist>> length 2/ ;

: valist-at ( key i array -- value ? )
    over 0 >= [
        3dup nth-unsafe = [
            [ 1 + ] dip nth-unsafe nip t
        ] [
            [ 2 - ] dip valist-at
        ] if
    ] [ 3drop f f ] if ; inline recursive

M: valist at*
    vlist>> >vlist< [ 2 - ] [ underlying>> ] bi* valist-at ;

M: valist new-at
    vlist>> ppush ppush valist boa ;

M: valist >alist
    vlist>> 2 <groups> [ { } like ] map ;

: >valist ( assoc -- valist )
    >alist concat >vlist valist boa ; inline

M: valist assoc-like
    drop dup valist? [ >valist ] unless ;

INSTANCE: valist assoc

SYNTAX: VA{ \ } [ >valist ] parse-literal ;

{ "vlists" "prettyprint" } "vlists.prettyprint" require-when
