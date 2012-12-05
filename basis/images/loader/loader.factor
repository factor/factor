! Copyright (C) 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: ascii assocs byte-arrays io.encodings.binary io.files
io.pathnames io.streams.byte-array kernel namespaces sequences
strings fry ;
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

GENERIC# load-image* 1 ( obj class -- image )

GENERIC: stream>image ( stream class -- image )

: register-image-class ( extension class -- )
    swap types get set-at ;

: load-image ( path -- image )
    [ binary <file-reader> ] [ image-class ] bi load-image* ;

M: object load-image* stream>image ;

M: byte-array load-image*
    [ binary <byte-reader> ] dip stream>image ;

M: string load-image*
    [ binary <file-reader> ] dip stream>image ;

M: pathname load-image*
    [ binary <file-reader> ] dip stream>image ;

! Image Encode

GENERIC: image>stream ( image class -- )

: save-graphic-image ( image path -- )
    [ image-class ] [ ] bi
    binary [ image>stream ] with-file-writer ;
