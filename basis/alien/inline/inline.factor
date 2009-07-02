! Copyright (C) 2009 Jeremy Hughes.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.inline.compiler alien.libraries
alien.parser arrays fry generalizations io.files io.files.info
io.files.temp kernel lexer math.order multiline namespaces
sequences system vocabs.loader vocabs.parser words ;
IN: alien.inline

<PRIVATE
SYMBOL: c-library
SYMBOL: library-is-c++
SYMBOL: compiler-args
SYMBOL: c-strings

: (C-LIBRARY:) ( -- )
    scan c-library set
    V{ } clone c-strings set
    V{ } clone compiler-args set ;

: (C-LINK:) ( -- )
    "-l" scan append compiler-args get push ;

: (C-FRAMEWORK:) ( -- )
    "-framework" scan compiler-args get '[ _ push ] bi@ ;

: return-library-function-params ( -- return library function params )
    scan c-library get scan ")" parse-tokens
    [ "(" subseq? not ] filter [
        [ dup CHAR: - = [ drop CHAR: space ] when ] map
    ] 3dip ;

: factor-function ( return library functions params -- )
    [ dup "const " head? [ 6 tail ] when ] 3dip
    make-function define-declared ;

: (C-FUNCTION:) ( return library function params -- str )
    [ nip ] dip
    " " join "(" prepend ")" append 3array " " join
    library-is-c++ get [ "extern \"C\" " prepend ] when ;

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

: (;C-LIBRARY) ( -- )
    compile-library? [ compile-library ] when
    c-library get library-path "cdecl" add-library ;
PRIVATE>

SYNTAX: C-LIBRARY: (C-LIBRARY:) ;

SYNTAX: COMPILE-AS-C++ t library-is-c++ set ;

SYNTAX: C-LINK: (C-LINK:) ;

SYNTAX: C-FRAMEWORK: (C-FRAMEWORK:) ;

SYNTAX: C-LINK/FRAMEWORK:
    os macosx? [ (C-FRAMEWORK:) ] [ (C-LINK:) ] if ;

SYNTAX: C-INCLUDE:
    "#include " scan append c-strings get push ;

SYNTAX: C-FUNCTION:
    return-library-function-params
    [ factor-function ]
    4 nkeep (C-FUNCTION:)
    " {\n" append parse-here append "\n}\n" append
    c-strings get push ;

SYNTAX: ;C-LIBRARY (;C-LIBRARY) ;
