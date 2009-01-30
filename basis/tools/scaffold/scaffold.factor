! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs io.files io.pathnames io.directories
io.encodings.utf8 hashtables kernel namespaces sequences
vocabs.loader io combinators calendar accessors math.parser
io.streams.string ui.tools.operations quotations strings arrays
prettyprint words vocabs sorting sets classes math alien urls
splitting ascii ;
IN: tools.scaffold

SYMBOL: developer-name
SYMBOL: using

ERROR: not-a-vocab-root string ;
ERROR: vocab-name-contains-separator path ;
ERROR: vocab-name-contains-dot path ;
ERROR: no-vocab vocab ;

<PRIVATE

: root? ( string -- ? ) vocab-roots get member? ;

: contains-dot? ( string -- ? ) ".." swap subseq? ;

: contains-separator? ( string -- ? ) [ path-separator? ] any? ;

: check-vocab-name ( string -- string )
    dup contains-dot? [ vocab-name-contains-dot ] when
    dup contains-separator? [ vocab-name-contains-separator ] when ;

: check-root ( string -- string )
    dup root? [ not-a-vocab-root ] unless ;

: directory-exists ( path -- )
    "Not creating a directory, it already exists: " write print ;

: scaffold-directory ( path -- )
    dup exists? [ directory-exists ] [ make-directories ] if ;

: not-scaffolding ( path -- )
    "Not creating scaffolding for " write <pathname> . ;

: scaffolding ( path -- )
    "Creating scaffolding for " write <pathname> . ;

: (scaffold-path) ( path string -- path )
    dupd [ file-name ] dip append append-path ;

: scaffold-path ( path string -- path ? )
    (scaffold-path)
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
    "new" ?head drop [ [ CHAR: ' = ] [ digit? ] bi or ] trim-tail
    H{
        { "object" object } { "obj" object }
        { "quot" quotation }
        { "string" string }
        { "str" string }
        { "hash" hashtable }
        { "hashtable" hashtable }
        { "?" "a boolean" }
        { "ch" "a character" }
        { "word" word }
        { "array" array }
        { "duration" duration }
        { "path" "a pathname string" }
        { "vocab" "a vocabulary specifier" }
        { "vocab-root" "a vocabulary root string" }
        { "c-ptr" c-ptr }
        { "seq" sequence }
        { "assoc" assoc }
        { "alist" "an array of key/value pairs" }
        { "keys" sequence } { "values" sequence }
        { "class" class } { "tuple" tuple }
        { "url" url }
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
            nl "}" print
        ] if
    ] when* ;

: $description. ( word -- )
    drop
    "{ $description \"\" } ;" print ;

: help-header. ( word -- )
    "HELP: " write name>> print ;

: (help.) ( word -- )
    [ help-header. ] [ $values. ] [ $description. ] tri ;

: interesting-words ( vocab -- array )
    words
    [ [ "help" word-prop ] [ predicate? ] bi or not ] filter
    natural-sort ;

: interesting-words. ( vocab -- )
    interesting-words [ (help.) nl ] each ;

: help-file-string ( vocab -- str2 )
    [
        {
            [ "IN: " write print nl ]
            [ interesting-words. ]
            [
                [ "ARTICLE: " write unparse dup write bl print ]
                [ "{ $vocab-link " write pprint " }" print ] bi
                ";" print nl
            ]
            [ "ABOUT: " write unparse print ]
        } cleave
    ] with-string-writer ;

: write-using ( vocab -- )
    "USING:" write
    using get keys
    { "help.markup" "help.syntax" } append natural-sort remove
    [ bl write ] each
    " ;" print ;

: set-scaffold-help-file ( path vocab -- )
    swap utf8 <file-writer> [
        scaffold-copyright
        [ help-file-string ] [ write-using ] bi
        write
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

: link-vocab ( vocab -- )
    check-vocab
    "Edit documentation: " write
    [ find-vocab-root ]
    [ vocab>scaffold-path ] bi
    "-docs.factor" (scaffold-path) <pathname> . ;

: help. ( word -- )
    [ (help.) ] [ nl vocabulary>> link-vocab ] bi ;

: scaffold-help ( string -- )
    [
        [ find-vocab-root ] [ check-vocab ] bi
        prepare-scaffold
        [ "-docs.factor" scaffold-path ] dip
        swap [ set-scaffold-help-file ] [ 2drop ] if
    ] with-scaffold ;

: scaffold-undocumented ( string -- )
    [ interesting-words. ] [ link-vocab ] bi ;

: scaffold-vocab ( vocab-root string -- )
    prepare-scaffold
    {
        [ drop scaffold-directory ]
        [ scaffold-main ]
        [ scaffold-tests ]
        [ drop scaffold-authors ]
        [ nip require ]
    } 2cleave ;

SYMBOL: examples-flag

: example ( -- )
    {
        "{ $example \"\" \"USING: prettyprint ;\""
        "           \"\""
        "           \"\""
        "}"
    } [ examples-flag get [ "    " write ] when print ] each ;

: examples ( n -- )
    t \ examples-flag [
        "{ $examples " print
        [ example ] times
        "}" print
    ] with-variable ;

: scaffold-rc ( path -- )
    [ touch-file ] [ "Click to edit: " write <pathname> . ] bi ;

: scaffold-factor-boot-rc ( -- )
    home ".factor-boot-rc" append-path scaffold-rc ;

: scaffold-factor-rc ( -- )
    home ".factor-rc" append-path scaffold-rc ;
