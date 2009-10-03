! Copyright (C) 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs byte-arrays combinators images
io.encodings.binary io.files io.pathnames io.streams.byte-array
io.streams.limited kernel namespaces sequences splitting
strings unicode.case ;
IN: images.loader

ERROR: unknown-image-extension extension ;

<PRIVATE

SYMBOL: types
types [ H{ } clone ] initialize

: image-class ( path -- class )
    file-extension >lower types get ?at
    [ unknown-image-extension ] unless ;

: open-image-file ( path -- stream )
    binary stream-throws <limited-file-reader> ;

PRIVATE>

! Image Decode

GENERIC# load-image* 1 ( obj class -- image )

GENERIC: stream>image ( stream class -- image )

: register-image-class ( extension class -- )
    swap types get set-at ;

: load-image ( path -- image )
    [ open-image-file ] [ image-class ] bi load-image* ;

M: byte-array load-image*
    [
        [ binary <byte-reader> ]
        [ length stream-throws <limited-stream> ] bi
    ] dip stream>image ;

M: limited-stream load-image* stream>image ;

M: string load-image* [ open-image-file ] dip stream>image ;

M: pathname load-image* [ open-image-file ] dip stream>image ;

! Image Encode

GENERIC: image>stream ( image class -- )

: save-graphic-image ( image path -- )
    [ image-class ] [ ] bi
    binary [ image>stream ] with-file-writer ;
