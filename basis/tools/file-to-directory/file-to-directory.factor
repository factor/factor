! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: base85 combinators command-line fry io.directories
io.encodings.binary io.encodings.utf8 io.files io.pathnames
kernel modern modern.out namespaces sequences splitting strings ;
IN: tools.file-to-directory

ERROR: expected-one-path got ;
ERROR: expected-modern-path got ;

: write-directory-files ( path -- )
    [ ".modern" ?tail drop dup make-directories ]
    [ path>literals ] bi
    '[
        _ first second rest [
            dup first "DIRECTORY:" head?
            [ second first second >string make-directories ]
            [
                second first2
                [ second >string ] [
                    first3 nip swap "base85" head? [
                        base85> binary
                    ] [
                        utf8
                    ] if
                ] bi* swapd
                [ dup parent-directory make-directories ] dip set-file-contents
            ] if
        ] each
    ] with-directory ;

: get-file-to-directory-path ( array -- path )
    dup length 1 = [ expected-one-path ] unless
    first dup ".modern" tail? [ expected-modern-path ] unless ;

: file-to-directory ( -- )
    command-line get get-file-to-directory-path write-directory-files ;

MAIN: file-to-directory
