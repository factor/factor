! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs definitions help.topics
io.pathnames kernel memoize namespaces sequences sets sorting
tools.completion tools.crossref vocabs vocabs.hierarchy
vocabs.parser words ;

IN: fuel.xref

<PRIVATE

: normalize-loc ( pair/f -- path line )
    [ first2 [ absolute-path ] dip ] [ f f ] if* ;

: get-loc ( pair/f -- loc ) normalize-loc 2array ;

: word>xref ( word -- xref )
    [ name>> ] [ vocabulary>> ] [ where normalize-loc ] tri 4array ;

: vocab>xref ( vocab -- xref )
    dup dup >vocab-link where normalize-loc 4array ;

: format-xrefs ( seq -- seq' )
    [ word? ] filter [ word>xref ] map ;

: group-xrefs ( xrefs -- xrefs' )
    sort [ second ] collect-by
    ! Change key from 'name' to { name path }
    [ [ [ third ] map-find drop 2array ] keep ] assoc-map
    >alist sort ;

: filter-prefix ( seq prefix -- seq )
    [ drop-prefix nip empty? ] curry filter members ;

MEMO: (vocab-words) ( name -- seq )
    >vocab-link vocab-words [ name>> ] map ;

: current-words ( -- seq )
    manifest get
    [ search-vocabs>> ] [ qualified-vocabs>> ] bi [ [ words>> ] map ] bi@
    append H{ } [ assoc-union ] reduce keys ;

: vocabs-words ( names -- seq )
    members [ (vocab-words) ] map concat ;

PRIVATE>

: callers-xref ( word -- seq ) usage format-xrefs group-xrefs ;

: callees-xref ( word -- seq ) uses format-xrefs group-xrefs ;

: apropos-xref ( str -- seq ) words-matching keys format-xrefs group-xrefs ;

: vocab-xref ( vocab -- seq )
    dup ".private" append [ vocab-words ] bi@ append
    format-xrefs group-xrefs ;

: word-location ( word -- loc ) where get-loc ;

: vocab-location ( vocab -- loc ) >vocab-link where get-loc ;

: vocab-uses-xref ( vocab -- seq ) vocab-uses [ vocab>xref ] map ;

: vocab-usage-xref ( vocab -- seq ) vocab-usage [ vocab>xref ] map ;

: doc-location ( word -- loc ) props>> "help-loc" of get-loc ;

: article-location ( name -- loc ) lookup-article loc>> get-loc ;

: get-vocabs/prefix ( prefix -- seq ) all-disk-vocab-names swap filter-prefix ;

: get-vocabs-words/prefix ( prefix names/f -- seq )
    [ vocabs-words ] [ current-words ] if* sort swap filter-prefix ;
