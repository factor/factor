! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: fry io io.directories io.encodings.ascii
io.encodings.utf8 io.launcher io.pathnames kernel lexer
namespaces parser sequences splitting vocabs vocabs.loader ;
IN: vocabs.git

<PRIVATE
: git-object-id ( filename rev -- id/f )
    [ [ parent-directory ] [ file-name ] bi ] dip swap '[
        { "git" "ls-tree" } _ suffix _ suffix ascii [
            readln
            [ " " split1 nip " " split1 nip "\t" split1 drop ]
            [ f ] if*
        ] with-process-reader
    ] with-directory ;

: with-git-object-stream ( id quot -- )
    [ { "git" "cat-file" "-p" } swap suffix utf8 ] dip with-process-reader ; inline
PRIVATE>

ERROR: git-revision-not-found path ;

: use-vocab-rev ( vocab-name rev -- )
    [ create-vocab vocab-source-path dup ] dip git-object-id
    [ [ input-stream get swap parse-stream call( -- ) ] with-git-object-stream ]
    [ git-revision-not-found ] if* ;

SYNTAX: USE-REV: scan-token scan-token use-vocab-rev ;
