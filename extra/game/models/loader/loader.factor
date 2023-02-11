! Copyright (C) 2010 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs byte-arrays combinators game.models
io.encodings.ascii io.files io.pathnames io.streams.byte-array
kernel namespaces sequences splitting
strings unicode arrays io.encodings ;
IN: game.models.loader

ERROR: unknown-models-extension extension ;

<PRIVATE

SYMBOL: types
types [ H{ } clone ] initialize

: models-class ( path -- class )
    file-extension >lower types get ?at
    [ unknown-models-extension ] unless second ;

: models-encoding ( path -- encoding )
    file-extension >lower types get ?at
    [ unknown-models-extension ] unless first ;

: open-models-file ( path encoding -- stream )
    <file-reader> ;

PRIVATE>

GENERIC#: load-models* 2 ( obj encoding class -- models )

GENERIC: stream>models ( stream class -- models )

: register-models-class ( extension encoding class -- )
    2array swap types get set-at ;

: load-models ( path -- models )
    [ dup models-encoding open-models-file ] [ models-encoding ] [ models-class ] tri load-models* ;

M: byte-array load-models*
    [ <byte-reader> ] dip stream>models ;

M: decoder load-models* nip stream>models ;

M: string load-models* [ open-models-file ] dip stream>models ;

M: pathname load-models* [ open-models-file ] dip stream>models ;
