! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: errors hashtables kernel lists namespaces sequences
strings ;

SYMBOL: bootstrapping?

SYMBOL: vocabularies

: word ( -- word ) \ word global hash ;

: set-word ( word -- ) \ word set-global ;

: vocabs ( -- seq ) vocabularies get hash-keys string-sort ;

: vocab ( name -- vocab ) vocabularies get hash ;

: ensure-vocab ( name -- ) vocabularies get [ nest drop ] bind ;

: words ( vocab -- list ) vocab dup [ hash-values ] when ;

: all-words ( -- list ) vocabs [ words ] map concat ;

: each-word ( quot -- ) all-words swap each ; inline

: word-subset ( pred -- list )
    all-words swap subset ; inline

: word-subset-with ( obj pred -- list | pred: obj word -- ? )
    all-words swap subset-with ; inline

: recrossref ( -- )
    crossref get clear-hash [ add-crossref ] each-word ;

: lookup ( name vocab -- word ) vocab ?hash ;

: reveal ( word -- )
    vocabularies get [
        dup word-name over word-vocabulary nest set-hash
    ] bind ;

: check-create ( name vocab -- )
    string? [ "Vocabulary name is not a string" throw ] unless
    string? [ "Word name is not a string" throw ] unless ;

: create ( name vocab -- word )
    2dup check-create 2dup lookup dup
    [ 2nip ] [ drop <word> dup init-word dup reveal ] if ;

: constructor-word ( string vocab -- word )
    >r "<" swap ">" append3 r> create ;

: forget ( word -- )
    dup uncrossref
    crossref get [ dupd remove-hash ] when*
    dup word-name swap word-vocabulary vocab remove-hash ;

: target-word ( word -- word )
    dup word-name swap word-vocabulary lookup ;

: interned? ( word -- ? ) dup target-word eq? ;

: bootstrap-word ( word -- word )
    dup word-name swap word-vocabulary
    bootstrapping? get [
        dup "syntax" = [ drop "!syntax" ] when
    ] when lookup ;
