! Copyright (C) 2010 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.destructors assocs kernel math math.bitwise
namespaces ;
IN: alien.handles

<PRIVATE

SYMBOLS: alien-handle-counter alien-handles ;

alien-handle-counter [ 0 ] initialize
alien-handles [ H{ } clone ] initialize

: biggest-handle ( -- n )
    -1 32 bits ; inline

: (next-handle) ( -- n )
    alien-handle-counter [ 1 + biggest-handle bitand dup ] change-global ; inline

: next-handle ( -- n )
    [ (next-handle) dup alien-handles get-global key? ] [ drop ] while ;

PRIVATE>

: <alien-handle> ( object -- int )
    next-handle [ alien-handles get-global set-at ] keep ; inline
: alien-handle> ( int -- object )
    alien-handles get-global at ; inline

: alien-handle? ( int -- ? )
    alien-handles get-global key? >boolean ; inline

: release-alien-handle ( int -- )
    alien-handles get-global delete-at ; inline

DESTRUCTOR: release-alien-handle

: <alien-handle-ptr> ( object -- void* )
    <alien-handle> <alien> ; inline
: alien-handle-ptr> ( void* -- object )
    alien-address alien-handle> ; inline

: alien-handle-ptr? ( alien -- ? )
    alien-address alien-handle? ; inline

: release-alien-handle-ptr ( alien -- )
    alien-address release-alien-handle ; inline

DESTRUCTOR: release-alien-handle-ptr
