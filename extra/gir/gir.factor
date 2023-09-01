! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs binary-search combinators
combinators.short-circuit io.directories io.encodings.utf8
io.files kernel modern.html multiline sequences sets strings
unicode vectors ;
IN: gir

: all-blank? ( string -- ? ) { [ sequence? ] [ [ blank? ] all? ] } 1&& ;

ERROR: unknown-gir-tag triple ;

: process-tag ( triple -- array )
    dup first HS{
        "alias"
        "array"
        "attribute"
        "bitfield"
        "c:include"
        "callback"
        "class"
        "constant"
        "constructor"
        "doc-deprecated"
        "doc-version"
        "doc"
        "docsection"
        "enumeration"
        "field"
        "function-macro"
        "function"
        "glib:boxed"
        "glib:signal"
        "implements"
        "include"
        "instance-parameter"
        "interface"
        "member"
        "method"
        "namespace"
        "package"
        "parameter"
        "parameters"
        "prerequisite"
        "property"
        "record"
        "repository"
        "return-value"
        "type"
        "union"
        "varargs"
        "virtual-method"
    } in? [ unknown-gir-tag ] unless ;

ERROR: unknown-html-directive tag ;

: parse-tag ( tag -- parsed/f )
    {
        { [ dup all-blank? ] [ drop f ] }
        { [ dup string? ] [ ] }
        { [ dup vector? ] [ [ parse-tag ] map sift harvest ] }
        { [ dup open-tag? ] [
            [ name>> ] [ props>> ] [ children>> parse-tag ] tri 3array process-tag
        ] }
        { [ dup self-close-tag? ] [
            [ name>> ] [ props>> ] [ children>> parse-tag ] tri 3array process-tag
        ] }
        { [ dup close-tag? ] [ drop f ] }
        { [ dup comment? ] [ drop f ] }
        { [ dup processing-instruction? ] [ drop f ] }
        [ unknown-html-directive ]
    } cond dup vector? [ harvest ] when ;

: parse-gir-file ( path -- seq )
    utf8 file-contents string>html parse-tag ;

! In factor/
! git clone https://github.com/gtk-rs/gir-files
: parse-gir-files ( -- assoc )
    "resource:gir-files" qualified-directory-files
    [ ".gir" tail? ] filter
    [ parse-gir-file ] zip-with ;
