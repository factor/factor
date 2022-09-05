! Copyright (C) 2022 CapitalEx
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.units continuations
formatting hash-sets hashtables io io.encodings.utf8 io.files
kernel namespaces regexp sequences sequences.deep sets sorting
splitting unicode vocabs vocabs.loader ;
FROM: namespaces => set ;
IN: lint.vocabs

<PRIVATE
SYMBOL: old-dictionary

: save-dictionary ( -- )
    dictionary     get clone 
    old-dictionary set       ;

: restore-dictionary ( -- )
    dictionary     get keys >hash-set
    old-dictionary get keys >hash-set
    diff members [ [ forget-vocab ] each ] with-compilation-unit ;

: vocab-loaded? ( name -- ? )
    dictionary get key? ;

: (get-words) ( name -- vocab )
    dup load-vocab words>> keys 2array ;

: no-vocab-found ( name -- empty )
    { } 2array ;

: nl>space ( string -- string )
    "\n" " " replace ;

: find-import-statements ( string -- seq )
    "USING: [^;]+ ;|USE: \\S+" <regexp> all-matching-subseqs ;

: clean-up-source ( string -- string )
    "\"(\\\"|[^\"]*)\"|(R/ (\\\\/|[^/])*/)|\\\\\\s+\\S+|POSTPONE: \\S+|! ([^\n])*" <regexp> "" re-replace ;

: strip-syntax ( seq -- seq )
    [ "USING: | ;|USE: " <regexp> " " re-replace ] map ;

: split-when-blank ( string -- seq )
    [ blank? ] split-when ;

: split-words ( line -- words )
    [ split-when-blank ] map flatten harvest ;

: get-unique-words ( seq -- hash-set )
    harvest split-words >hash-set ;

: [is-used?] ( hash-set  -- quot )
    '[ nip [ _ in? ] any? ] ; inline

: reject-unused-vocabs ( assoc hash-set -- seq )
    [is-used?] assoc-reject keys ;

: print-unused-vocabs ( name seq -- )
    swap "The following vocabs are unused in %s: \n" printf
        [ "    - " prepend print ] each ;

: print-no-unused-vocabs ( name _ -- )
    drop "No unused vocabs found in %s.\n" printf ;

PRIVATE>

: get-words ( name -- assoc )
    dup vocab-exists? 
        [ (get-words) ]
        [ no-vocab-found ] if ;

: get-vocabs ( string -- seq )
    nl>space find-import-statements strip-syntax split-words harvest ;

: get-imported-words ( string -- hashtable )
    save-dictionary 
        get-vocabs [ get-words ] map >hashtable 
    restore-dictionary 
    ;

: find-unused-in-string ( string -- seq )
    clean-up-source
    [ get-imported-words ] [ "\n" split get-unique-words ] bi
    reject-unused-vocabs natural-sort ; inline

: find-unused-in-file ( path -- seq )
    utf8 file-contents find-unused-in-string ;

: find-unused ( name -- seq )
    vocab-source-path dup [ find-unused-in-file ] when ;

: find-unused. ( name -- )
    dup find-unused dup empty?
        [ print-no-unused-vocabs ]
           [ print-unused-vocabs ] if ;
