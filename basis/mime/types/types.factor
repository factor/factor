! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.pathnames io.files io.encodings.ascii
io.encodings.binary io.encodings.utf8 assocs sequences
splitting kernel make fry memoize ;
IN: mime.types

MEMO: mime-db ( -- seq )
    "vocab:mime/types/mime.types" ascii file-lines
    [ "#" head? not ] filter [ " \t" split harvest ] map harvest ;

: nonstandard-mime-types ( -- assoc )
    H{
        { "factor" "text/plain"                       }
        { "cgi"    "application/x-cgi-script"         }
        { "fhtml"  "application/x-factor-server-page" }
    } ;

MEMO: mime-types ( -- assoc )
    [
        mime-db [ unclip '[ [ _ ] dip ,, ] each ] each
    ] H{ } make
    nonstandard-mime-types assoc-union ;

: mime-type ( filename -- mime-type )
    file-extension mime-types at "application/octet-stream" or ;

: mime-type-encoding ( mime-type -- encoding )
    "text/" head? utf8 binary ? ;

