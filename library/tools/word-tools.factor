! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: files generic inspector lists kernel namespaces
prettyprint stdio streams strings unparser math hashtables
parser ;

: usages. ( word -- )
    #! List all usages of a word.
    usages word-sort [.] ;

: usage ( word -- list )
    crossref get hash dup [ hash-keys ] when ;

: usage. ( word -- )
    #! List all direct usages of a word.
    usage word-sort [.] ;

: vocab-apropos ( substring vocab -- list )
    #! Push a list of all words in a vocabulary whose names
    #! contain a string.
    words [ word-name dupd string-contains? ] subset nip ;

: vocab-apropos. ( substring vocab -- )
    #! List all words in a vocabulary that contain a string.
    tuck vocab-apropos dup [
        "IN: " write swap print [.]
    ] [
        2drop
    ] ifte ;

: vocab-completions ( substring vocab -- list )
    #! Used by jEdit plugin. Like vocab-apropos, but only
    #! matches at the start of a word name are considered.
    words [ word-name over ?string-head nip ] subset nip ;

: apropos. ( substring -- )
    #! List all words that contain a string.
    vocabs [ vocab-apropos. ] each-with ;

: vocabs. ( -- )
    vocabs . ;

: words. ( vocab -- )
    words . ;

: word-file ( word -- file )
    "file" word-prop dup [
        "resource:/" ?string-head [
            resource-path swap path+
        ] when
    ] when ;

: reload ( word -- )
    #! Reload the source file the word originated from.
    word-file run-file ;
