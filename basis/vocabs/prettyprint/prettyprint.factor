! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs colors colors.constants fry io
io.styles kernel make math.order namespaces parser
prettyprint.backend prettyprint.sections prettyprint.stylesheet
sequences sets sorting vocabs vocabs.parser ;
FROM: io.styles => inset ;
IN: vocabs.prettyprint

: pprint-vocab ( vocab -- )
    [ vocab-name ] [ vocab vocab-style ] bi styled-text ;

: pprint-in ( vocab -- )
    [ \ IN: pprint-word pprint-vocab ] with-pprint ;

<PRIVATE

: sort-vocabs ( seq -- seq' )
    [ vocab-name ] sort-with ;

: pprint-using ( seq -- )
    [ "syntax" vocab = not ] filter
    sort-vocabs [
        \ USING: pprint-word
        [ pprint-vocab ] each
        \ ; pprint-word
    ] with-pprint ;

GENERIC: pprint-qualified ( qualified -- )

M: qualified pprint-qualified ( qualified -- )
    [
        dup [ vocab>> vocab-name ] [ prefix>> ] bi = [
            \ QUALIFIED: pprint-word
            vocab>> pprint-vocab
        ] [
            \ QUALIFIED-WITH: pprint-word
            [ vocab>> pprint-vocab ] [ prefix>> text ] bi
        ] if
    ] with-pprint ;

M: from pprint-qualified ( from -- )
    [
        \ FROM: pprint-word
        [ vocab>> pprint-vocab "=>" text ]
        [ names>> [ text ] each ] bi
        \ ; pprint-word
    ] with-pprint ;

M: exclude pprint-qualified ( exclude -- )
    [
        \ EXCLUDE: pprint-word
        [ vocab>> pprint-vocab "=>" text ]
        [ names>> [ text ] each ] bi
        \ ; pprint-word
    ] with-pprint ;

M: rename pprint-qualified ( rename -- )
    [
        \ RENAME: pprint-word
        [ word>> text ]
        [ vocab>> text "=>" text ]
        [ words>> >alist first first text ]
        tri
    ] with-pprint ;

: filter-interesting ( seq -- seq' )
    [ [ vocab? ] [ extra-words? ] bi or not ] filter ;

PRIVATE>

: (pprint-manifest ( manifest -- quots )
    [
        [ search-vocabs>> [ '[ _ pprint-using ] , ] unless-empty ]
        [ qualified-vocabs>> filter-interesting [ '[ _ pprint-qualified ] , ] each ]
        [ current-vocab>> [ '[ _ pprint-in ] , ] when* ]
        tri
    ] { } make ;

: pprint-manifest) ( quots -- )
    [ nl ] [ call( -- ) ] interleave ;

: pprint-manifest ( manifest -- )
    (pprint-manifest pprint-manifest) ;

[
    nl
    { { font-style bold } { font-name "sans-serif" } } [
        "Restarts were invoked adding vocabularies to the search path." print
        "To avoid doing this in the future, add the following forms" print
        "at the top of the source file:" print nl
    ] with-style
    {
        { page-color COLOR: FactorLightTan }
        { border-color COLOR: FactorDarkTan }
        { inset { 5 5 } }
    } [ manifest get pprint-manifest ] with-nesting
    nl nl
] print-use-hook set-global