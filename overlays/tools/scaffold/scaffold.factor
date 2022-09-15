USING: arrays io io.encodings.utf8 io.files io.pathnames
io.streams.string kernel namespaces sequences tools.scaffold.private ;

IN: tools.scaffold
<PRIVATE
: scaffold-filename ( path -- )
    "! File: " write
    file-name print ;

: scaffold-version ( -- )
    "! Version: 0.1" print ;

: scaffold-dri ( -- )
    "! DRI: "
    developer-name get [ "Your name" ] unless*  append print ;

: scaffold-description ( -- )
    "! Description: Another fine Factor file!" print ;

: scaffold-headers ( path -- )
    scaffold-filename
    scaffold-version
    scaffold-dri
    scaffold-description
    scaffold-copyright ;
    
: main-file-string ( path -- string )
    [ scaffold-headers ] with-string-writer ;

: set-scaffold-main-file ( vocab path -- )
    [ main-file-string 1array ] dip utf8 set-file-lines ;

: scaffold-main ( vocab-root vocab -- )
    [ ".factor" vocab-root/vocab/suffix>path ] keep swap scaffolding? [
        set-scaffold-main-file
    ] [
        2drop
    ] if ;
PRIVATE>
