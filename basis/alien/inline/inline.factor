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

: return-library-function-params ( -- return library function params )
    scan c-library get scan ")" parse-tokens
    [ "(" subseq? not ] filter [
        [ dup CHAR: - = [ drop CHAR: space ] when ] map
    ] 3dip ;

: factor-function ( return library function params -- )
    [ dup "const " head? [ 6 tail ] when ] 3dip
    make-function define-declared ;

: c-function-string ( return library function params -- str )
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
PRIVATE>

: define-c-library ( name -- )
    c-library set
    V{ } clone c-strings set
    V{ } clone compiler-args set ;

: compile-c-library ( -- )
    compile-library? [ compile-library ] when
    c-library get library-path "cdecl" add-library ;

: define-c-function ( return library function params -- )
    [ factor-function ] 4 nkeep c-function-string
    " {\n" append parse-here append "\n}\n" append
    c-strings get push ;

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

SYNTAX: C-FUNCTION:
    return-library-function-params define-c-function ;

SYNTAX: ;C-LIBRARY compile-c-library ;
