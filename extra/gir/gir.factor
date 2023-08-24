! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit io.directories io.encodings.utf8
io.files kernel modern.html multiline sequences strings unicode
vectors ;
IN: gir

: all-blank? ( string -- ? ) { [ sequence? ] [ [ blank? ] all? ] } 1&& ;

ERROR: unknown-gir-tag triple ;

: process-tag ( triple -- array )
    dup first {
        { "repository" [ ] }

        { "include" [ ] }
        { "c:include" [ ] }
        { "package" [ ] }
        { "namespace" [ ] }

        { "type" [ ] }
        { "parameters" [ ] }
        { "parameter" [ ] }
        { "attribute" [ ] }
        { "property" [ ] }
        { "field" [ ] }
        { "prerequisite" [ ] }
        { "return-value" [ ] }
        { "instance-parameter" [ ] }
        { "constant" [ ] }
        { "bitfield" [ ] }
        { "union" [ ] }
        { "class" [ ] }
        { "record" [ ] }
        { "enumeration" [ ] }
        { "array" [ ] }
        { "varargs" [ ] }
        { "member" [ ] }
        { "implements" [ ] }
        { "interface" [ ] }
        { "alias" [ ] }
        { "function-macro" [ ] }
        { "function" [ ] }
        { "constructor" [ ] }
        { "virtual-method" [ ] }
        { "method" [ ] }
        { "callback" [ ] }
        { "doc" [ ] }
        { "doc-deprecated" [ ] }
        { "doc-version" [ ] }
        { "docsection" [ ] }
        { "glib:boxed" [ ] }
        { "glib:signal" [ ] }
        [ drop unknown-gir-tag ]
    } case ;

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
