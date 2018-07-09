! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: base64 command-line fry io.directories
io.encodings.binary io.encodings.utf8 io.files io.pathnames
kernel modern modern.out namespaces sequences splitting strings ;
IN: tools.file-to-directory

ERROR: expected-one-path got ;
ERROR: expected-modern-path got ;

: write-directory-files ( path -- )
    [ ".modern" ?tail drop dup make-directories ]
    [ path>literals ] bi
    '[
        _ [
            second first2 [ third >string ] dip

            [ third ] [
                first "base64" head?
                [ [ >string ] [ base64> ] bi* swap binary ]
                [ [ >string ] bi@ swap utf8 ] if
            ] bi
            [ dup parent-directory make-directories ] dip set-file-contents
        ] each
    ] with-directory ;

: get-file-to-directory-path ( array -- path )
    dup length 1 = [ expected-one-path ] unless
    first dup ".modern" tail? [ expected-modern-path ] unless ;

: file-to-directory ( -- )
    command-line get get-file-to-directory-path write-directory-files ;

MAIN: file-to-directory
