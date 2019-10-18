! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.inline.compiler alien.inline.types
alien.libraries alien.parser arrays assocs effects fry
generalizations grouping io.directories io.files
io.files.info io.files.temp kernel lexer math math.order
math.ranges multiline namespaces sequences source-files
splitting strings system vocabs.loader vocabs.parser words
alien.c-types alien.structs make parser continuations ;
IN: alien.inline

SYMBOL: c-library
SYMBOL: library-is-c++
SYMBOL: linker-args
SYMBOL: c-strings

<PRIVATE
: cleanup-variables ( -- )
    { c-library library-is-c++ linker-args c-strings }
    [ off ] each ;

: arg-list ( types -- params )
    CHAR: a swap length CHAR: a + [a,b]
    [ 1string ] map ;

: compile-library? ( -- ? )
    c-library get library-path dup exists? [
        file get [
            path>>
            [ file-info modified>> ] bi@ <=> +lt+ =
        ] [ drop t ] if*
    ] [ drop t ] if ;

: compile-library ( -- )
    library-is-c++ get [ C++ ] [ C ] if
    linker-args get
    c-strings get "\n" join
    c-library get compile-to-library ;

: c-library-name ( name -- name' )
    [ current-vocab name>> % "_" % % ] "" make ;
PRIVATE>

: parse-arglist ( parameters return -- types effect )
    [ 2 group unzip [ "," ?tail drop ] map ]
    [ [ { } ] [ 1array ] if-void ]
    bi* <effect> ;

: append-function-body ( prototype-str body -- str )
    [ swap % " {\n" % % "\n}\n" % ] "" make ;

: function-types-effect ( -- function types effect )
    scan scan swap ")" parse-tokens
    [ "(" subseq? not ] filter swap parse-arglist ;

: prototype-string ( function types effect -- str )
    [ [ cify-type ] map ] dip
    types-effect>params-return cify-type -rot
    [ " " join ] map ", " join
    "(" prepend ")" append 3array " " join
    library-is-c++ get [ "extern \"C\" " prepend ] when ;

: prototype-string' ( function types return -- str )
    [ dup arg-list ] <effect> prototype-string ;

: factor-function ( function types effect -- word quot effect )
    annotate-effect [ c-library get ] 3dip
    [ [ factorize-type ] map ] dip
    types-effect>params-return factorize-type -roll
    concat make-function ;

: define-c-library ( name -- )
    c-library-name [ c-library set ] [ "c-library" set ] bi
    V{ } clone c-strings set
    V{ } clone linker-args set ;

: compile-c-library ( -- )
    compile-library? [ compile-library ] when
    c-library get dup library-path "cdecl" add-library ;

: define-c-function ( function types effect body -- )
    [
        [ factor-function define-declared ]
        [ prototype-string ] 3bi
    ] dip append-function-body c-strings get push ;

: define-c-function' ( function effect body -- )
    [
        [ in>> ] keep
        [ factor-function define-declared ]
        [ out>> prototype-string' ] 3bi
    ] dip append-function-body c-strings get push ;

: c-link-to ( str -- )
    "-l" prepend linker-args get push ;

: c-use-framework ( str -- )
    "-framework" swap linker-args get '[ _ push ] bi@ ;

: c-link-to/use-framework ( str -- )
    os macosx? [ c-use-framework ] [ c-link-to ] if ;

: c-include ( str -- )
    "#include " prepend c-strings get push ;

: define-c-typedef ( old new -- )
    [ typedef ] [
        [ swap "typedef " % % " " % % ";" % ]
        "" make c-strings get push
    ] 2bi ;

: define-c-struct ( name fields -- )
    [ current-vocab swap define-struct ] [
        over
        [
            "typedef struct " % "_" % % " {\n" %
            [ first2 swap % " " % % ";\n" % ] each
            "} " % % ";\n" %
        ] "" make c-strings get push
    ] 2bi ;

: delete-inline-library ( name -- )
    c-library-name [ remove-library ]
    [ library-path dup exists? [ delete-file ] [ drop ] if ] bi ;

: with-c-library ( name quot -- )
    [ [ define-c-library ] dip call compile-c-library ]
    [ cleanup-variables ] [ ] cleanup ; inline

: raw-c ( str -- )
    [ "\n" % % "\n" % ] "" make c-strings get push ;
