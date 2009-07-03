! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.inline.compiler alien.libraries
alien.parser arrays assocs effects fry generalizations grouping
io.files io.files.info io.files.temp kernel lexer math
math.order math.ranges multiline namespaces sequences splitting
strings system vocabs.loader vocabs.parser words ;
IN: alien.inline

<PRIVATE
SYMBOL: c-library
SYMBOL: library-is-c++
SYMBOL: compiler-args
SYMBOL: c-strings

: function-types-effect ( -- function types effect )
    scan scan swap ")" parse-tokens
    [ "(" subseq? not ] filter parse-arglist ;

: types-effect>params-return ( types effect -- params return )
    [ nip out>> first ] [ in>> zip ] 2bi ;

: arg-list ( types -- params )
    CHAR: a swap length CHAR: a + [a,b]
    [ 1string ] map ;

: factorize-type ( str -- str' )
    "const-" ?head drop ;

: cify-type ( str -- str' )
    { { CHAR: ~ CHAR: space } } substitute ;

: factor-function ( function types effect -- )
    [ c-library get ] 3dip [ [ factorize-type ] map ] dip
    types-effect>params-return factorize-type -roll
    make-function define-declared ;

: prototype-string ( function types effect -- str )
    [ [ cify-type ] map ] dip
    types-effect>params-return cify-type -rot
    2 group [ " " join "," append ] map " " join
    "(" prepend ")" append 3array " " join
    library-is-c++ get [ "extern \"C\" " prepend ] when ;

: prototype-string' ( function types return -- str )
    [ dup arg-list ] <effect> prototype-string ;

: append-function-body ( prototype-str -- str )
    " {\n" append parse-here append "\n}\n" append ;


: library-path ( -- str )
    "lib" c-library get library-suffix
    3array concat temp-file ;

: compile-library? ( -- ? )
    library-path dup exists? [
        current-vocab vocab-source-path
        [ file-info modified>> ] bi@ <=> +lt+ =
    ] [ drop t ] if ;

: compile-library ( -- )
    library-is-c++ get [ C++ ] [ C ] if
    compiler-args get
    c-strings get "\n" join
    c-library get compile-to-library ;
PRIVATE>

: define-c-library ( name -- )
    c-library set
    V{ } clone c-strings set
    V{ } clone compiler-args set ;

: compile-c-library ( -- )
    compile-library? [ compile-library ] when
    c-library get library-path "cdecl" add-library ;

: define-c-function ( function types effect -- )
    [ factor-function ] 3keep prototype-string
    append-function-body c-strings get push ;

: define-c-function' ( function effect -- )
    [ in>> ] keep [ factor-function ] 3keep
    out>> prototype-string'
    append-function-body c-strings get push ;

: define-c-link ( str -- )
    "-l" prepend compiler-args get push ;

: define-c-framework ( str -- )
    "-framework" swap compiler-args get '[ _ push ] bi@ ;

: define-c-link/framework ( str -- )
    os macosx? [ define-c-framework ] [ define-c-link ] if ;

: define-c-include ( str -- )
    "#include " prepend c-strings get push ;

SYNTAX: C-LIBRARY: scan define-c-library ;

SYNTAX: COMPILE-AS-C++ t library-is-c++ set ;

SYNTAX: C-LINK: scan define-c-link ;

SYNTAX: C-FRAMEWORK: scan define-c-framework ;

SYNTAX: C-LINK/FRAMEWORK: scan define-c-link/framework ;

SYNTAX: C-INCLUDE: scan define-c-include ;

SYNTAX: C-FUNCTION: function-types-effect define-c-function ;

SYNTAX: ;C-LIBRARY compile-c-library ;
