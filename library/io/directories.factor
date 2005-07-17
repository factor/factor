! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: kernel hashtables lists namespaces presentation
sequences strings unparser ;

! Hyperlinked directory listings.

: dir-icon "/library/icons/Folder.png" ;
: file-icon "/library/icons/File.png" ;
: file-icon. directory? dir-icon file-icon ? write-icon ;

: file-link. ( dir name -- )
    tuck path+ "file" swons unit write-attr ;

: file. ( dir name -- )
    #! If "doc-root" set, create links relative to it.
    2dup path+ file-icon. bl file-link. terpri ;

: directory. ( dir -- )
    #! If "doc-root" set, create links relative to it.
    dup directory [
        dup [ "." ".." ] member? [ 2drop ] [ file. ] ifte
    ] each-with ;
