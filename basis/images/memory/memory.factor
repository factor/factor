! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data destructors images
kernel libc math sequences ;
IN: images.memory

! Some code shared by core-graphics and cairo for constructing
! images from off-screen graphics contexts. There is probably
! no reason to call it directly.

<PRIVATE

: bitmap-size ( dim -- n ) product uint heap-size * ;

: malloc-bitmap-data ( dim -- alien ) bitmap-size 1 calloc &free ;

: bitmap-data ( alien dim -- data ) bitmap-size memory>byte-array ;

: <bitmap-image> ( alien dim -- image )
    [ bitmap-data ] keep
    <image>
        swap >>dim
        swap >>bitmap ;

PRIVATE>

: make-memory-bitmap ( dim quot -- image )
    '[
        [ malloc-bitmap-data ] keep _ [ <bitmap-image> ] 2bi
    ] with-destructors ; inline
