! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien arrays assocs byte-arrays calendar
classes classes.error combinators combinators.short-circuit fry
hashtables help.markup interpolate io io.directories
io.encodings.utf8 io.files io.pathnames io.streams.string kernel
math math.parser namespaces prettyprint quotations sequences
sets sorting splitting strings system timers unicode urls vocabs
vocabs.loader vocabs.metadata words words.symbol ;
IN: tools.scaffold

SYMBOL: developer-name
SYMBOL: using

ERROR: not-a-vocab-root string ;

ERROR: vocab-must-not-exist string ;

<PRIVATE

: vocab-root? ( string -- ? )
    trim-tail-separators vocab-roots get member? ;

: ensure-vocab-exists ( string -- string )
    dup lookup-vocab [ no-vocab ] unless ;

: check-root ( string -- string )
    dup vocab-root? [ not-a-vocab-root ] unless ;

: check-vocab-root/vocab ( vocab-root string -- vocab-root string )
    [ check-root ] [ check-vocab-name ] bi* ;

: replace-vocab-separators ( vocab -- path )
    path-separator first CHAR: . associate substitute ;

: vocab-root/vocab>path ( vocab-root vocab -- path )
    check-vocab-root/vocab
    [ ] [ replace-vocab-separators ] bi* append-path ;

: vocab>path ( vocab -- path )
    check-vocab [ find-vocab-root ] keep vocab-root/vocab>path ;

: vocab-root/vocab/file>path ( vocab-root vocab file -- path )
    [ vocab-root/vocab>path ] dip append-path ;

: vocab-root/vocab/suffix>path ( vocab-root vocab suffix -- path )
    [ vocab-root/vocab>path dup file-name append-path ] dip append ;

: vocab/file>path ( vocab file -- path )
    [ vocab>path ] dip append-path ;

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
    [ main-file-string 1array ] dip utf8 set-file-lines ;

: scaffold-main ( vocab-root vocab -- )
    [ ".factor" vocab-root/vocab/suffix>path ] keep swap scaffolding? [
        set-scaffold-main-file
    ] [
        2drop
    ] if ;

: scaffold-metadata ( vocab file contents -- )
    [ ensure-vocab-exists ] 2dip
    [
        [ vocab/file>path ] dip 1array swap scaffolding? [
            utf8 set-file-lines
        ] [
            2drop
        ] if
    ] [
        2drop
    ] if* ;

: lookup-type ( string -- object/string ? )
    "/f" ?tail swap
    "new" ?head drop [ { [ CHAR: ' = ] [ digit? ] } 1|| ] trim-tail
    H{
        { "object" object }
        { "obj" object }
        { "quot" quotation }
        { "string" string }
        { "str" string }
        { "hash" hashtable }
        { "hashtable" hashtable }
        { "?" boolean }
        { "ch" "a character" }
        { "word" word }
        { "array" array }
        { "byte-array" byte-array }
        { "timer" timer }
        { "duration" duration }
        { "path" "a pathname string" }
        { "vocab" "a vocabulary specifier" }
        { "vocab-root" "a vocabulary root string" }
        { "c-ptr" c-ptr }
        { "sequence" sequence }
        { "seq" sequence }
        { "exemplar" object }
        { "assoc" assoc }
        { "alist" "an array of key/value pairs" }
        { "keys" sequence }
        { "values" sequence }
        { "class" class }
        { "tuple" tuple }
        { "url" url }
    } at* [ swap [ \ $maybe swap 2array ] when ] dip ;

GENERIC: add-using ( object -- )

M: array add-using [ add-using ] each ;

M: string add-using drop ;

M: object add-using ( object -- )
    vocabulary>> using get [ adjoin ] [ drop ] if* ;

: ($values.) ( array -- )
    [
        "    " write
        [ bl ] [
            "{ " write
            dup array? [ first ] when
            dup lookup-type [
                [ unparse write bl ]
                [ [ pprint ] [ add-using ] bi ] bi*
            ] [
                drop unparse write bl null pprint
                null add-using
            ] if
            " }" write
        ] interleave
    ] unless-empty ;

: ?print-nl ( seq1 seq2 -- )
    [ empty? ] either? [ nl ] unless ;

: $values. ( word -- )
    "declared-effect" word-prop [
        [ in>> ] [ out>> ] bi
        2dup [ empty? ] both? [
            2drop
        ] [
            [ members ] dip over diff
            "{ $values" print
            [ drop ($values.) ]
            [ ?print-nl ]
            [ nip ($values.) ] 2tri
            nl "}" print
        ] if
    ] when* ;

: error-description. ( word -- )
    [ $values. ] [
        "{ $description \"Throws " write
        name>> dup a/an write " \" { $link " write
        write " } \" error.\" }" print
    ] bi "{ $error-description \"\" } ;" print ;

: class-description. ( word -- )
    drop "{ $class-description \"\" } ;" print ;

: symbol-description. ( word -- )
    drop "{ $var-description \"\" } ;" print ;

: $description. ( word -- )
    drop "{ $description \"\" } ;" print ;

: docs-body. ( word/symbol -- )
    {
        { [ dup error-class? ] [ error-description. ] }
        { [ dup class? ] [ class-description. ] }
        { [ dup symbol? ] [ symbol-description. ] }
        [ [ $values. ] [ $description. ] bi ]
    } cond ;

: docs-header. ( word -- )
    "HELP: " write name>> print ;

: (help.) ( word -- )
    [ docs-header. ] [ docs-body. ] bi ;

: interesting-words ( vocab -- array )
    vocab-words
    [ { [ "help" word-prop ] [ predicate? ] } 1|| ] reject
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
    using get members
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
    [ HS{ } clone using ] dip with-variable ; inline

: link-vocab ( vocab -- )
    check-vocab
    "Edit documentation: " write
    "-docs.factor" vocab/suffix>path <pathname> . ;

PRIVATE>

: help. ( word -- )
    [ (help.) ] [ nl vocabulary>> link-vocab ] bi ;

: scaffold-docs ( vocab -- )
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

: scaffold-authors ( vocab -- )
    "authors.txt" developer-name get scaffold-metadata ;

: scaffold-tags ( vocab tags -- )
    [ "tags.txt" ] dip scaffold-metadata ;

: scaffold-summary ( vocab summary -- )
    [ "summary.txt" ] dip scaffold-metadata ;

: scaffold-platforms ( vocab platforms -- )
    [ "platforms.txt" ] dip scaffold-metadata ;

: delete-from-root-cache ( string -- )
    root-cache get delete-at ;

: scaffold-vocab ( vocab-root string -- )
    dup delete-from-root-cache
    {
        [ scaffold-directory ]
        [ scaffold-main ]
        [ nip require ]
        [ nip scaffold-authors ]
    } 2cleave ;

: scaffold-core ( string -- ) "resource:core" swap scaffold-vocab ;

: scaffold-basis ( string -- ) "resource:basis" swap scaffold-vocab ;

: scaffold-extra ( string -- ) "resource:extra" swap scaffold-vocab ;

: scaffold-work ( string -- ) "resource:work" swap scaffold-vocab ;

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

SYMBOL: nested-examples

: example-using ( using -- )
    " " join "example-using" [
        nested-examples get 4 0 ? CHAR: \s <string> "example-indent" [
            "${example-indent}\"Example:\"
${example-indent}{ $example \"USING: ${example-using} ;\"
${example-indent}    \"\"
${example-indent}    \"\"
${example-indent}}
"
            interpolate
        ] with-variable
    ] with-variable ;

: n-examples-using ( n using -- )
    '[ _ example-using ] times ;

: scaffold-n-examples ( n word -- )
    vocabulary>> "prettyprint" 2array
    [ t nested-examples ] 2dip
    '[
        "{ $examples" print
        _ _ n-examples-using
        "}" print
    ] with-variable ;

: scaffold-examples ( word -- )
    2 swap scaffold-n-examples ;

: scaffold-file ( path -- )
    [ touch-file ]
    [ "Click to edit: " write <pathname> . ] bi ;

: scaffold-rc ( path -- )
    [ home ] dip append-path scaffold-file ;

: scaffold-factor-boot-rc ( -- )
    ".factor-boot-rc" scaffold-rc ;

: scaffold-factor-rc ( -- )
    ".factor-rc" scaffold-rc ;

: scaffold-mason-rc ( -- )
    ".factor-mason-rc" scaffold-rc ;

: scaffold-factor-roots ( -- )
    ".factor-roots" scaffold-rc ;

HOOK: scaffold-emacs os ( -- )

M: unix scaffold-emacs ( -- ) ".emacs" scaffold-rc ;
