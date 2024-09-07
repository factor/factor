! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs combinators.short-circuit hashtables
io.encodings.ascii io.encodings.binary io.encodings.utf8
io.files io.pathnames kernel make sequences splitting ;
IN: mime.types

MEMO: mime-db ( -- seq )
    "vocab:mime/types/mime.types" ascii file-lines
    [ "#" head? ] reject [ " \t" split harvest ] map harvest ;

: nonstandard-mime-types ( -- assoc )
    H{
        { "factor" "text/plain"                       }
        { "cgi"    "application/x-cgi-script"         }
        { "fhtml"  "application/x-factor-server-page" }
    } ;

! These mime types were previously in mime.types.
! Let's keep them!
: removed-mime-types ( -- assoc )
    H{
        { "pntg" "image/x-macpaint" }
        { "m4a" "audio/mp4a-latm" }
        { "pnt" "image/x-macpaint" }
        { "dv" "video/x-dv" }
        { "otm" "application/vnd.oasis.opendocument.text-master" }
        { "mac" "image/x-macpaint" }
        { "m4p" "audio/mp4a-latm" }
        { "pict" "image/pict" }
        { "scpt" "application/octet-stream" }
        { "qti" "image/x-quicktime" }
        { "dif" "video/x-dv" }
        { "jp2" "image/jp2" }
        { "qtif" "image/x-quicktime" }
    } ;

MEMO: mime-types ( -- assoc )
    [
        mime-db [ unclip '[ [ _ ] dip ,, ] each ] each
    ] H{ } make
    nonstandard-mime-types assoc-union
    removed-mime-types assoc-union ;

MEMO: mime-extensions ( -- assoc )
    mime-db >hashtable ;

: mime-type ( filename -- mime-type )
    file-extension mime-types at "application/octet-stream" or ;

: mime-type-encoding ( mime-type -- encoding )
    {
        [ "text/" head? ]
        [ "application/json" = ]
    } 1|| utf8 binary ? ;

: mime-type>extension ( mime-type -- extension )
    mime-extensions at ;
