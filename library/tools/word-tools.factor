! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: files generic inspector lists kernel namespaces
prettyprint stdio streams strings unparser math hashtables
parser ;

GENERIC: word-uses? ( of in -- ? )
M: word word-uses? 2drop f ;
M: compound word-uses? ( of in -- ? )
    #! Don't say that a word uses itself.
    2dup = [ 2drop f  ] [ word-def tree-contains? ] ifte ;

: generic-uses? ( of in -- ? )
    "methods" word-prop hash>alist tree-contains? ;

M: generic word-uses? ( of in -- ? ) generic-uses? ;
M: 2generic word-uses? ( of in -- ? ) generic-uses? ;

: usages-in-vocab ( of vocab -- usages )
    #! Push a list of all usages of a word in a vocabulary.
    words [
        dup compound? [
            dupd word-uses?
        ] [
            drop f ! Ignore words without a definition
        ] ifte
    ] subset nip ;

: usages-in-vocab. ( of vocab -- )
    #! List all usages of a word in a vocabulary.
    tuck usages-in-vocab dup [
        swap "IN: " write print [.]
    ] [
        2drop
    ] ifte ;

: usages. ( word -- )
    #! List all usages of a word in all vocabularies.
    vocabs [ usages-in-vocab. ] each-with ;

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

: in. ( -- )
    #! Print the vocabulary where new words are added in
    #! interactive parsers.
    "in" get print ;

: use. ( -- )
    #! Print the vocabulary search path for interactive parsers.
    "use" get . ;

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
