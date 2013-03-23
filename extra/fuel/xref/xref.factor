! Copyright (C) 2009 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs definitions help.topics io.pathnames
kernel math math.order memoize namespaces sequences sets sorting
tools.completion tools.crossref vocabs vocabs.parser vocabs.hierarchy
words ;

IN: fuel.xref

<PRIVATE

: normalize-loc ( seq -- path line )
    [ dup length 0 > [ first absolute-path ] [ drop f ] if ]
    [ dup length 1 > [ second ] [ drop 1 ] if ] bi ;

: get-loc ( object -- loc ) normalize-loc 2array ;

: word>xref ( word -- xref )
    [ name>> ] [ vocabulary>> ] [ where normalize-loc ] tri 4array ;

: vocab>xref ( vocab -- xref )
    dup dup >vocab-link where normalize-loc 4array ;

: sort-xrefs ( seq -- seq' )
    [ first ] sort-with ;

: format-xrefs ( seq -- seq' )
    [ word? ] filter [ word>xref ] map ;

: filter-prefix ( seq prefix -- seq )
    [ drop-prefix nip length 0 = ] curry filter members ;

MEMO: (vocab-words) ( name -- seq )
    >vocab-link words [ name>> ] map ;

: current-words ( -- seq )
    manifest get
    [ search-vocabs>> ] [ qualified-vocabs>> ] bi [ [ words>> ] map ] bi@
    append H{ } [ assoc-union ] reduce keys ;

: vocabs-words ( names -- seq )
    members [ (vocab-words) ] map concat ;

PRIVATE>

: callers-xref ( word -- seq ) usage format-xrefs sort-xrefs ;

: callees-xref ( word -- seq ) uses format-xrefs sort-xrefs ;

: apropos-xref ( str -- seq ) words-matching format-xrefs ;

: vocab-xref ( vocab -- seq ) words format-xrefs ;

: word-location ( word -- loc ) where get-loc ;

: vocab-location ( vocab -- loc ) >vocab-link where get-loc ;

: vocab-uses-xref ( vocab -- seq ) vocab-uses [ vocab>xref ] map ;

: vocab-usage-xref ( vocab -- seq ) vocab-usage [ vocab>xref ] map ;

: doc-location ( word -- loc ) props>> "help-loc" of get-loc ;

: article-location ( name -- loc ) lookup-article loc>> get-loc ;

: get-vocabs ( -- seq ) all-vocab-names ;

: get-vocabs/prefix ( prefix -- seq ) get-vocabs swap filter-prefix ;

: get-vocabs-words/prefix ( prefix names/f -- seq )
    [ vocabs-words ] [ current-words ] if* natural-sort swap filter-prefix ;
