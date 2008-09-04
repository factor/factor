! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs io.files hashtables kernel namespaces sequences
vocabs.loader io combinators io.encodings.utf8 calendar accessors
math.parser io.streams.string ui.tools.operations quotations
strings arrays prettyprint words vocabs sorting sets cords
classes sequences.lib combinators.lib ;
IN: tools.scaffold

SYMBOL: developer-name
SYMBOL: using

ERROR: not-a-vocab-root string ;
ERROR: vocab-name-contains-separator path ;
ERROR: vocab-name-contains-dot path ;
ERROR: no-vocab vocab ;

: root? ( string -- ? )
    vocab-roots get member?  ;

<PRIVATE
: check-vocab-name ( string -- string )
    dup dup [ CHAR: . = ] trim [ length ] bi@ =
    [ vocab-name-contains-dot ] unless
    ".." over subseq? [ vocab-name-contains-dot ] when
    dup [ path-separator? ] contains?
    [ vocab-name-contains-separator ] when ;

: check-root ( string -- string )
    check-vocab-name
    dup "resource:" head? [ "resource:" prepend ] unless
    dup root? [ not-a-vocab-root ] unless ;

: directory-exists ( path -- )
    "Not creating a directory, it already exists: " write print ;

: scaffold-directory ( path -- )
    dup exists? [ directory-exists ] [ make-directories ] if ;

: not-scaffolding ( path -- )
    "Not creating scaffolding for " write <pathname> . ;

: scaffolding ( path -- )
    "Creating scaffolding for " write <pathname> . ;

: scaffold-path ( path string -- path ? )
    dupd [ file-name ] dip append append-path
    dup exists? [ dup not-scaffolding f ] [ dup scaffolding t ] if ;

: scaffold-copyright ( -- )
    "! Copyright (C) " write now year>> number>string write
    developer-name get [ "Your name" ] unless* bl write "." print
    "! See http://factorcode.org/license.txt for BSD license." print ;

: main-file-string ( vocab -- string )
    [
        scaffold-copyright
        "USING: ;" print
        "IN: " write print
    ] with-string-writer ;

: set-scaffold-main-file ( path vocab -- )
    main-file-string swap utf8 set-file-contents ;

: scaffold-main ( path vocab -- )
    [ ".factor" scaffold-path ] dip
    swap [ set-scaffold-main-file ] [ 2drop ] if ;

: tests-file-string ( vocab -- string )
    [
        scaffold-copyright
        "USING: tools.test " write dup write " ;" print
        "IN: " write write ".tests" print
    ] with-string-writer ;

: set-scaffold-tests-file ( path vocab -- )
    tests-file-string swap utf8 set-file-contents ;

: scaffold-tests ( path vocab -- )
    [ "-tests.factor" scaffold-path ] dip
    swap [ set-scaffold-tests-file ] [ 2drop ] if ;

: scaffold-authors ( path -- )
    "authors.txt" append-path dup exists? [
        not-scaffolding
    ] [
        dup scaffolding
        developer-name get swap utf8 set-file-contents
    ] if ;

: lookup-type ( string -- object/string ? )
    H{
        { "object" object } { "obj" object }
        { "obj1" object } { "obj2" object }
        { "obj3" object } { "obj4" object }
        { "quot" quotation } { "quot1" quotation }
        { "quot2" quotation } { "quot3" quotation }
        { "string" string } { "string1" string }
        { "string2" string } { "string3" string }
        { "str" string }
        { "str1" string } { "str2" string } { "str3" string }
        { "hash" hashtable }
        { "hashtable" hashtable }
        { "?" "a boolean" }
        { "ch" "a character" }
        { "word" word }
        { "array" array }
        { "path" "a pathname string" }
        { "vocab" "a vocabulary specifier" }
        { "vocab-root" "a vocabulary root string" }
    } at* ;

: add-using ( object -- )
    vocabulary>> using get [ conjoin ] [ drop ] if* ;

: ($values.) ( array -- )
    [
        " { " write
        dup array? [ first ] when
        dup lookup-type [
            [ unparse write bl ]
            [ [ pprint ] [ dup string? [ drop ] [ add-using ] if ] bi ] bi*
        ] [
            drop unparse write bl null pprint
            null add-using
        ] if
        " }" write
    ] each ;

: $values. ( word -- )
    "declared-effect" word-prop [
        [ in>> ] [ out>> ] bi
        2dup [ empty? ] bi@ and [
            2drop
        ] [
            "{ $values" print
            [ "    " write ($values.) ]
            [ [ nl "    " write ($values.) ] unless-empty ] bi*
            " }" write nl
        ] if
    ] when* ;

: $description. ( word -- )
    drop
    "{ $description } ;" print ;

: help-header. ( word -- )
    "HELP: " write name>> print ;
PRIVATE>

: help. ( word -- )
    [ help-header. ] [ $values. ] [ $description. ] tri ;

<PRIVATE
: help-file-string ( str1 -- str2 )
    [
        [ "IN: " write print nl ]
        [ words natural-sort [ help. nl ] each ]
        [ "ARTICLE: " write unparse dup write bl print ";" print nl ]
        [ "ABOUT: " write unparse print ] quad
    ] with-string-writer ;

: write-using ( -- )
    "USING:" write
    using get keys
    { "help.markup" "help.syntax" } cord-append natural-sort 
    [ bl write ] each
    " ;" print ;

: set-scaffold-help-file ( path vocab -- )
    swap utf8 <file-writer> [
        scaffold-copyright help-file-string write-using write
    ] with-output-stream ;

: check-scaffold ( vocab-root string -- vocab-root string )
    [ check-root ] [ check-vocab-name ] bi* ;

: vocab>scaffold-path ( vocab-root string -- path )
    path-separator first CHAR: . associate substitute
    append-path ;

: prepare-scaffold ( vocab-root string -- string path )
    check-scaffold [ vocab>scaffold-path ] keep ;

: with-scaffold ( quot -- )
    [ H{ } clone using ] dip with-variable ; inline

: check-vocab ( vocab -- vocab )
    dup find-vocab-root [ no-vocab ] unless ;
PRIVATE>


: scaffold-help ( vocab-root string -- )
    [
        check-vocab
        prepare-scaffold
        [ "-docs.factor" scaffold-path ] dip
        swap [ set-scaffold-help-file ] [ 2drop ] if
    ] with-scaffold ;

: scaffold-undocumented ( string -- )
    words
    [ [ "help" word-prop ] [ predicate? ] bi or not ] filter
    natural-sort [ help. nl ] each ;

: scaffold-vocab ( vocab-root string -- )
    prepare-scaffold
    {
        [ drop scaffold-directory ]
        [ scaffold-main ]
        [ scaffold-tests ]
        [ drop scaffold-authors ]
        [ nip require ]
    } 2cleave ;
