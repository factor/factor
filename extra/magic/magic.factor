! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: destructors io.backend kernel magic.ffi ;

IN: magic

<PRIVATE

: check-magic-error ( magic num -- )
    -1 = [ magic_error throw ] [ drop ] if ;

: magic-file ( path flags -- result )
    [
        magic_open &magic_close
        [ dup f magic_load check-magic-error ]
        [ swap normalize-path magic_file ] bi
    ] with-destructors ;

PRIVATE>

: guess-file ( path -- file-type )
    MAGIC_NONE magic-file ;

: guess-mime-type ( path -- mime-type )
    MAGIC_MIME_TYPE magic-file ;

: guess-mime-encoding ( path -- encoding )
    MAGIC_MIME_ENCODING magic-file ;
