! Copyright (C) 2009 Doug Coleman, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: ascii assocs byte-arrays combinators destructors
io.encodings.binary io.files io.pathnames io.streams.byte-array
kernel namespaces strings system vocabs ;
IN: images.loader

ERROR: unknown-image-extension extension ;

<PRIVATE

SYMBOL: types
types [ H{ } clone ] initialize

: (image-class) ( type -- class )
    >lower types get ?at [ unknown-image-extension ] unless ;

: image-class ( path -- class )
    file-extension (image-class) ;

PRIVATE>

! Image Decode

GENERIC#: load-image* 1 ( obj class -- image )

GENERIC: stream>image* ( stream class -- image )

: stream>image ( stream class -- image )
    '[ _ &dispose _ stream>image* ] with-destructors ; inline

: register-image-class ( extension class -- )
    swap types get set-at ;

: ?register-image-class ( extension class -- )
    over types get key? [ 2drop ] [ register-image-class ] if ;

: load-image ( path -- image )
    dup image-class load-image* ;

M: object load-image* stream>image ;

M: byte-array load-image*
    [ binary <byte-reader> ] dip stream>image ;

M: string load-image*
    [ binary <file-reader> ] dip stream>image ;

M: pathname load-image*
    [ binary <file-reader> ] dip stream>image ;

! Image Encode
GENERIC: image>stream ( image extension class -- )

: save-graphic-image ( image path -- )
    dup file-extension dup (image-class) rot
    binary [ image>stream ] with-file-writer ;

{
    { [ os macos? ] [ "images.loader.cocoa" require ] }
    { [ os windows? ] [ "images.loader.gdiplus" require ] }
    { [ os freebsd? ] [ "images.png" require "images.tiff" require ] }
    [ "images.loader.gtk" require ]
} cond
