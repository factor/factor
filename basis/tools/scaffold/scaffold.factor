! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs io.files io.pathnames io.directories
io.encodings.utf8 hashtables kernel namespaces sequences
vocabs.loader io combinators calendar accessors math.parser
io.streams.string ui.tools.operations quotations strings arrays
prettyprint words vocabs sorting sets classes math alien urls
splitting ascii combinators.short-circuit alarms words.symbol
system summary ;
IN: tools.scaffold

SYMBOL: developer-name
SYMBOL: using

ERROR: not-a-vocab-root string ;
ERROR: vocab-name-contains-separator path ;
ERROR: vocab-name-contains-dot path ;
ERROR: no-vocab vocab ;
ERROR: bad-developer-name name ;

M: bad-developer-name summary
    drop "Developer name must be a string." ;

<PRIVATE

: vocab-root? ( string -- ? ) vocab-roots get member? ;

: contains-dot? ( string -- ? ) ".." swap subseq? ;

: contains-separator? ( string -- ? ) [ path-separator? ] any? ;

: ensure-vocab-exists ( string -- string )
    dup vocabs member? [ no-vocab ] unless ;

: check-vocab-name ( string -- string )
    [ ]
    [ contains-dot? [ vocab-name-contains-dot ] when ]
    [ contains-separator? [ vocab-name-contains-separator ] when ] tri ;

: check-root ( string -- string )
    dup vocab-root? [ not-a-vocab-root ] unless ;

: check-vocab ( vocab -- vocab )
    dup find-vocab-root [ no-vocab ] unless ;

: check-vocab-root/vocab ( vocab-root string -- vocab-root string )
    [ check-root ] [ check-vocab-name ] bi* ;

: replace-vocab-separators ( vocab -- path )
    path-separator first CHAR: . associate substitute ; inline

: vocab-root/vocab>path ( vocab-root vocab -- path )
    check-vocab-root/vocab
    [ ] [ replace-vocab-separators ] bi* append-path ;

: vocab>path ( vocab -- path )
    check-vocab
    [ find-vocab-root ] keep vocab-root/vocab>path ;

: vocab-root/vocab/file>path ( vocab-root vocab file -- path )
    [ vocab-root/vocab>path ] dip append-path ;

: vocab-root/vocab/suffix>path ( vocab-root vocab suffix -- path )
    [ vocab-root/vocab>path dup file-name append-path ] dip append ;

: vocab/suffix>path ( vocab suffix -- path )
    [ vocab>path dup file-name append-path ] dip append ;

: directory-exists ( path -- )
    "Not creating a directory, it already exists: " write print ;

: scaffold-directory ( vocab-root vocab -- )
    vocab-root/vocab>path
    dup exists? [ directory-exists ] [ make-directories ] if ;

: not-scaffolding ( path -- path )
    "Not creating scaffolding for " write dup <pathname> . ;

: scaffolding ( path -- path )
    "Creating scaffolding for " write dup <pathname> . ;

: scaffolding? ( path -- path ? )
    dup exists? [ not-scaffolding f ] [ scaffolding t ] if ;

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

: set-scaffold-main-file ( vocab path -- )
    [ main-file-string ] dip utf8 set-file-contents ;

: scaffold-main ( vocab-root vocab -- )
    tuck ".factor" vocab-root/vocab/suffix>path scaffolding? [
        set-scaffold-main-file
    ] [
        2drop
    ] if ;

: scaffold-authors ( vocab-root vocab -- )
    developer-name get [
        dup string? [ bad-developer-name ] unless
        "authors.txt" vocab-root/vocab/file>path scaffolding? [
            utf8 set-file-contents
        ] [
            2drop
        ] if
    ] [
        2drop
    ] if* ;

: lookup-type ( string -- object/string ? )
    "new" ?head drop [ { [ CHAR: ' = ] [ digit? ] } 1|| ] trim-tail
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
        { "alarm" alarm }
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
    [ bl ] [
        "{ " write
        dup array? [ first ] when
        dup lookup-type [
            [ unparse write bl ]
            [ [ pprint ] [ dup string? [ drop ] [ add-using ] if ] bi ] bi*
        ] [
            drop unparse write bl null pprint
            null add-using
        ] if
        " }" write
    ] interleave ;

: 4bl ( -- )
    "    " write ; inline

: $values. ( word -- )
    "declared-effect" word-prop [
        [ in>> ] [ out>> ] bi
        2dup [ empty? ] bi@ and [
            2drop
        ] [
            "{ $values" print
            [ 4bl ($values.) ]
            [ [ nl 4bl ($values.) ] unless-empty ] bi*
            nl "}" print
        ] if
    ] when* ;

: symbol-description. ( word -- )
    drop
    "{ $var-description \"\" } ;" print ;

: $description. ( word -- )
    drop
    "{ $description \"\" } ;" print ;

: docs-body. ( word/symbol -- )
    dup symbol? [
        symbol-description.
    ] [
        [ $values. ] [ $description. ] bi
    ] if ;

: docs-header. ( word -- )
    "HELP: " write name>> print ;

: (help.) ( word -- )
    [ docs-header. ] [ docs-body. ] bi ;

: interesting-words ( vocab -- array )
    words
    [ { [ "help" word-prop ] [ predicate? ] } 1|| not ] filter
    natural-sort ;

: interesting-words. ( vocab -- )
    interesting-words [ (help.) nl ] each ;

: docs-file-string ( vocab -- str2 )
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

: set-scaffold-docs-file ( vocab path -- )
    utf8 <file-writer> [
        scaffold-copyright
        [ docs-file-string ] [ write-using ] bi
        write
    ] with-output-stream ;

: with-scaffold ( quot -- )
    [ H{ } clone using ] dip with-variable ; inline

: link-vocab ( vocab -- )
    check-vocab
    "Edit documentation: " write
    "-docs.factor" vocab/suffix>path <pathname> . ;

PRIVATE>

: help. ( word -- )
    [ (help.) ] [ nl vocabulary>> link-vocab ] bi ;

: scaffold-help ( vocab -- )
    ensure-vocab-exists
    [
        dup "-docs.factor" vocab/suffix>path scaffolding? [
            set-scaffold-docs-file
        ] [
            2drop
        ] if
    ] with-scaffold ;

: scaffold-undocumented ( string -- )
    [ interesting-words. ] [ link-vocab ] bi ;

: scaffold-vocab ( vocab-root string -- )
    {
        [ scaffold-directory ]
        [ scaffold-main ]
        [ scaffold-authors ]
        [ nip require ]
    } 2cleave ;

<PRIVATE

: tests-file-string ( vocab -- string )
    [
        scaffold-copyright
        "USING: tools.test " write dup write " ;" print
        "IN: " write write ".tests" print
    ] with-string-writer ;

: set-scaffold-tests-file ( vocab path -- )
    [ tests-file-string ] dip utf8 set-file-contents ;

PRIVATE>

: scaffold-tests ( vocab -- )
    ensure-vocab-exists
    dup "-tests.factor" vocab/suffix>path
    scaffolding? [
        set-scaffold-tests-file
    ] [
        2drop
    ] if ;

SYMBOL: examples-flag

: example ( -- )
    {
        "{ $example \"\" \"USING: prettyprint ;\""
        "           \"\""
        "           \"\""
        "}"
    } [ examples-flag get [ 4bl ] when print ] each ;

: examples ( n -- )
    t \ examples-flag [
        "{ $examples " print
        [ example ] times
        "}" print
    ] with-variable ;

: touch. ( path -- )
    [ touch-file ]
    [ "Click to edit: " write <pathname> . ] bi ;

: scaffold-rc ( path -- )
    [ home ] dip append-path touch. ;

: scaffold-factor-boot-rc ( -- )
    os windows? "factor-boot-rc" ".factor-boot-rc" ? scaffold-rc ;

: scaffold-factor-rc ( -- )
    os windows? "factor-rc" ".factor-rc" ? scaffold-rc ;


HOOK: scaffold-emacs os ( -- )

M: unix scaffold-emacs ( -- ) ".emacs" scaffold-rc ;
