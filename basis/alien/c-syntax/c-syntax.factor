USING: accessors alien.compile alien.libraries alien.parser
arrays fry generalizations io.files.info io.files.temp kernel
lexer math.order multiline namespaces sequences system
vocabs.loader vocabs.parser words ;
IN: alien.c-syntax

<PRIVATE
: (C-LIBRARY:) ( -- )
    scan "c-library" set
    V{ } clone "c-library-vector" set
    V{ } clone "c-compiler-args" set ;

: (C-LINK:) ( -- )
    "-l" scan append "c-compiler-args" get push ;

: (C-FRAMEWORK:) ( -- )
    "-framework" scan "c-compiler-args" get '[ _ push ] bi@ ;

: return-library-function-params ( -- return library function params )
    scan "c-library" get scan ")" parse-tokens
    [ "(" subseq? not ] filter ;

: (C-FUNCTION:) ( return library function params -- str )
    [ nip ] dip " " join "(" prepend ")" append 3array " " join
    "library-is-c++" get [ "extern \"C\" " prepend ] when ;

: library-path ( -- str )
    "lib" "c-library" get library-suffix
    3array concat temp-file ;

: compile-library? ( -- ? )
    library-path current-vocab vocab-source-path
    [ file-info modified>> ] bi@ <=> +lt+ = ;

: compile-library ( -- )
    "library-is-c++" get [ "g++" ] [ "gcc" ] if
    "c-compiler-args" get
    "c-library-vector" get "\n" join
    "c-library" get compile-to-library ;

: (;C-LIBRARY) ( -- )
    compile-library? [ compile-library ] when
    "c-library" get library-path "cdecl" add-library ;
PRIVATE>

SYNTAX: C-LIBRARY: (C-LIBRARY:) ;

SYNTAX: C++-LIBRARY: (C-LIBRARY:) t "library-is-c++" set ;

SYNTAX: C-LINK: (C-LINK:) ;

SYNTAX: C-FRAMEWORK: (C-FRAMEWORK:) ;

SYNTAX: C-LINK/FRAMEWORK:
    os macosx? [ (C-LINK:) ] [ (C-FRAMEWORK:) ] if ;

SYNTAX: C-INCLUDE:
    "#include " scan append "c-library-vector" get push ;

SYNTAX: C-FUNCTION:
    return-library-function-params
    [ make-function define-declared ]
    4 nkeep (C-FUNCTION:)
    " {\n" append parse-here append "\n}\n" append
    "c-library-vector" get push ;

SYNTAX: ;C-LIBRARY (;C-LIBRARY) ;

SYNTAX: ;C++-LIBRARY (;C-LIBRARY) ;
