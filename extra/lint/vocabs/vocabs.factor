! Copyright (C) 2022 CapitalEx
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit compiler.units formatting hash-sets
hashtables io io.encodings.utf8 io.files io.styles kernel
namespaces sequences sequences.parser sets sorting strings 
unicode vectors vocabs vocabs.loader vocabs.prettyprint 
vocabs.prettyprint.private ;
FROM: namespaces => set ;
IN: lint.vocabs

<PRIVATE
SYMBOL: old-dictionary
SYMBOL: cache
 
! Words for working with the dictionary.
: save-dictionary ( -- )
    dictionary     get clone 
    old-dictionary set       ;

: restore-dictionary ( -- )
    dictionary     get keys >hash-set
    old-dictionary get keys >hash-set
    diff members [ [ forget-vocab ] each ] with-compilation-unit ;

: vocab-loaded? ( name -- ? )
    dictionary get key? ;


! Helper words
: tokenize ( string -- sequence-parser )
    <sequence-parser> ;

: skip-after ( sequence-parser seq -- sequence-parser )
    [ take-until-sequence* drop ] curry keep ;

: skip-after* ( sequence-parser object -- sequence-parser )
    [ take-until-object drop ] curry keep ;

: next-line ( sequence-parser -- sequence-parser )
    "\n" skip-after ;

: quotation-mark? ( token -- ? )
    first CHAR: " = ;

: comment? ( token -- ? )
    "!" = ;

: string-literal? ( token -- ? )
    first CHAR: " = ;


! Words for parsing tokens
DEFER: next-token

: reject-token ( sequence-parser token -- string )
    drop next-line next-token ;

: accept-token ( sequence-parser token -- string )
    nip >string ;

: get-token ( sequence-parser -- token )
    skip-whitespace [ current blank? ] take-until ;

: next-token ( sequence-parser -- string )
    dup get-token dup comment?
        [ reject-token ] 
        [ accept-token ] if ;

: skip-token ( sequence-parser -- sequence-parser )
    dup next-token drop  ;


! Words for removing syntax that should be ignored
: ends-with-quote? ( token -- ? )
    2 tail* [ first CHAR: \ = not ] 
            [ second CHAR: " =    ] bi and ;

: end-string? ( token -- ? )
    dup length 1 = [ quotation-mark? ] [ ends-with-quote? ] if ;

: skip-string ( sequence-parser string -- sequence-parser )
    end-string? not [ dup next-token skip-string ] when ;

: ?handle-string ( sequence-parser string -- sequence-parser string/f )
    dup { [ empty? not ] [ string-literal? ] } 1&& [ skip-string f ] when ;

: next-word/f ( sequence-parser -- sequence-parser string/f )
    dup next-token {
        ! skip over empty tokens
        { "" [ f ] }

        ! prune syntax stuff
        { "FROM:"     [ ";" skip-after f ] }
        { "SYMBOLS:"  [ ";" skip-after f ] }
        { "R/"        [ "/" skip-after f ] }
        { "("         [ ")" skip-after f ] }
        { "IN:"       [     skip-token f ] }
        { "SYMBOL:"   [     skip-token f ] }
        { ":"         [     skip-token f ] }
        { "POSTPONE:" [     skip-token f ] }
        { "\\"        [     skip-token f ] }
        { "CHAR:"     [     skip-token f ] }

        ! comments
        { "!"           [             next-line f ] }
        { "(("          [ "))"       skip-after f ] }
        { "/*"          [ "*/"       skip-after f ] }
        { "![["         [ "]]"       skip-after f ] }
        { "![=["        [ "]=]"      skip-after f ] }
        { "![==["       [ "]==]"     skip-after f ] }
        { "![===["      [ "]===]"    skip-after f ] }
        { "![====["     [ "]====]"   skip-after f ] }
        { "![=====["    [ "]=====]"  skip-after f ] }
        { "![======["   [ "]======]" skip-after f ] }

        ! strings (special case needed for `"`)
        { "STRING:"    [ ";"        skip-after f ] }
        { "[["         [ "]]"       skip-after f ] }
        { "[=["        [ "]=]"      skip-after f ] }
        { "[==["       [ "]==]"     skip-after f ] }
        { "[===["      [ "]===]"    skip-after f ] }
        { "[====["     [ "]====]"   skip-after f ] }
        { "[=====["    [ "]=====]"  skip-after f ] }
        { "[======["   [ "]======]" skip-after f ] }

        ! EBNF
        { "EBNF[["         [ "]]"       skip-after f ] }
        { "EBNF[=["        [ "]=]"      skip-after f ] }
        { "EBNF[==["       [ "]==]"     skip-after f ] }
        { "EBNF[===["      [ "]===]"    skip-after f ] }
        { "EBNF[====["     [ "]====]"   skip-after f ] }
        { "EBNF[=====["    [ "]=====]"  skip-after f ] }
        { "EBNF[======["   [ "]======]" skip-after f ] }
        
        ! Annotations
        { "!AUTHOR"    [ next-line f ] }
        { "!BROKEN"    [ next-line f ] }
        { "!BUG"       [ next-line f ] }
        { "!FIXME"     [ next-line f ] }
        { "!LICENSE"   [ next-line f ] }
        { "!LOL"       [ next-line f ] }
        { "!NOTE"      [ next-line f ] }
        { "!REVIEW"    [ next-line f ] }
        { "!TODO"      [ next-line f ] }
        { "!XXX"       [ next-line f ] }
        

        [ ]
    } case ?handle-string ;

: ?push ( vector sequence-parser string/? -- vector sequence-parser )
    [ [ swap [ push ] keep ] curry dip ] when* ;

: ?keep-parsing-with ( vector sequence-parser quot -- vector )
    [ dup sequence-parse-end? not ] dip
        [ call( x x -- x ) ] curry [ drop ] if ;

: (strip-code) ( vector sequence-praser -- vector )
    skip-whitespace next-word/f ?push 
        [ (strip-code) ] ?keep-parsing-with harvest ;

: strip-code ( string -- string )
    tokenize V{ } clone swap (strip-code) ;


! Words for finding the words used in a program
! and stripping out import statements
: skip-imports ( sequence-parser -- sequence-parser string/? )
    dup next { 
        { "USING:"  [ ";" skip-after* f ] }
        { "USE:"    [        advance  f ] }
        [ ]
    } case ;

: take-imports ( sequence-parser -- vector )
    dup next {
        { "USING:" [ ";" take-until-object ] }
        { "USE:"   [  1  take-n ] }
        [ 2drop f ]
    } case ;

: (find-used-words) ( vector sequence-parser -- vector )
    skip-imports ?push [ (find-used-words) ] ?keep-parsing-with ;

: find-used-words ( vector -- set )
    <sequence-parser> V{ } clone swap (find-used-words) fast-set ;

: (find-imports) ( vector sequence-parser -- vector )
    dup take-imports rot prepend swap [ (find-imports) ] ?keep-parsing-with ;

: find-imports ( vector -- seq )
    <sequence-parser> V{ } clone swap (find-imports) dup cache set ;

: (get-words) ( name -- vocab )
    dup load-vocab words>> keys 2array ;

: no-vocab-found ( name -- empty )
    { } 2array ;

: [is-used?] ( hash-set  -- quot )
    '[ nip [ _ in? ] any? ] ; inline

: reject-unused-vocabs ( assoc hash-set -- seq )
    [is-used?] assoc-reject keys ;

:: print-new-header ( seq -- )
    "Use the following header to remove unused imports: " print
    manifest-style [ cache get seq diff pprint-using ] with-nesting ;

:: print-unused-vocabs ( name seq -- )
    name "The following vocabs are unused in %s: \n" printf
    seq [ "    - " prepend print ] each 
    seq print-new-header
    nl
    nl ;

: print-no-unused-vocabs ( name _ -- )
    drop "No unused vocabs found in %s.\n" printf ;


! Private details for fetching words and imports
: get-words ( name -- assoc )
    dup vocab-exists? [ (get-words) ] [ no-vocab-found ] if ;

: get-imported-words ( string -- hashtable )
    save-dictionary
        find-imports [ get-words ] map >hashtable
    restore-dictionary ;

PRIVATE>

: find-unused-in-string ( string -- seq )
    strip-code [ get-imported-words ] [ find-used-words ] bi
        reject-unused-vocabs sort ;

: find-unused-in-file ( path -- seq )
    utf8 file-contents find-unused-in-string ;

: find-unused ( name -- seq )
    vocab-source-path dup [ find-unused-in-file ] when ;

: find-unused. ( name -- )
    dup find-unused dup empty?
        [ print-no-unused-vocabs ]
           [ print-unused-vocabs ] if ;
