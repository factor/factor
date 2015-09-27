! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.pathnames io.files io.encodings.ascii
io.encodings.binary io.encodings.utf8 assocs sequences
splitting kernel make fry memoize ;
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

: mime-type ( filename -- mime-type )
    file-extension mime-types at "application/octet-stream" or ;

: mime-type-encoding ( mime-type -- encoding )
    "text/" head? utf8 binary ? ;
