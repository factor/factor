! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: generic inspector lists kernel namespaces
prettyprint io strings sequences math hashtables parser ;

: vocab-apropos ( substring vocab -- list )
    #! Push a list of all words in a vocabulary whose names
    #! contain a string.
    words [ word-name subseq? ] subset-with ;

: vocab-apropos. ( substring vocab -- )
    #! List all words in a vocabulary that contain a string.
    tuck vocab-apropos dup [
        "IN: " write swap print sequence.
    ] [
        2drop
    ] ifte ;

: apropos. ( substring -- )
    #! List all words that contain a string.
    vocabs [ vocab-apropos. ] each-with ;

: word-file ( word -- file )
    "file" word-prop dup [
        "resource:/" ?head [
            resource-path swap path+
        ] when
    ] when ;

: reload ( word -- )
    #! Reload the source file the word originated from.
    word-file run-file ;

: implementors ( class -- list )
    #! Find a list of generics that implement a method
    #! specializing on this class.
    [
        "methods" word-prop [ dupd hash ] [ f ] ifte*
    ] word-subset nip ;

: classes ( -- list )
    [ metaclass ] word-subset ;
