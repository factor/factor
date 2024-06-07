! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators effects
effects.parser kernel lexer make math memoize multiline
namespaces parser present sequences sequences.deep
sequences.generalizations strings summary unicode
words xml xml.data xml.state ;
IN: xml.syntax

<PRIVATE

ERROR: no-tag name word ;

M: no-tag summary
    drop "The tag-dispatching word has no method for the given tag name" ;

: compile-tags ( word xtable -- quot )
    >alist swap '[ _ no-tag ] suffix '[ dup main>> _ case ] ;

: define-tags ( word effect -- )
    [ dup dup "xtable" word-prop compile-tags ] dip define-declared ;

:: define-tag ( string word quot -- )
    quot string word "xtable" word-prop set-at
    word word stack-effect define-tags ;

PRIVATE>

SYNTAX: TAGS:
    scan-new-word scan-effect
    [ drop H{ } clone "xtable" set-word-prop ]
    [ define-tags ]
    2bi ;

SYNTAX: TAG:
    scan-token scan-word parse-definition define-tag ;

SYNTAX: XML-NS:
    scan-new-word scan-token '[ f swap _ <name> ] ( string -- name ) define-memoized ;

<PRIVATE

: each-attrs ( attrs quot -- )
    [ values [ interpolated? ] filter ] dip each ; inline

: (each-interpolated) ( ... item quot: ( ... interpolated -- ... ) -- ... )
    {
        { [ over interpolated? ] [ call ] }
        { [ over tag? ] [ [ attrs>> ] dip each-attrs ] }
        { [ over attrs? ] [ each-attrs ] }
        { [ over xml? ] [ [ body>> ] dip (each-interpolated) ] }
        [ 2drop ]
    } cond ; inline recursive

: each-interpolated ( xml quot -- )
    '[ _ (each-interpolated) ] deep-each ; inline

: has-interpolated? ( xml -- ? )
    ! If this becomes a performance problem, it can be improved
    f swap [ 2drop t ] each-interpolated ;

: when-interpolated ( xml quot -- genquot )
    [ dup has-interpolated? ] dip [ '[ _ swap ] ] if ; inline

: string>chunk ( string -- chunk )
    t interpolating? [ string>xml-chunk ] with-variable ;

: string>doc ( string -- xml )
    t interpolating? [ string>xml ] with-variable ;

DEFER: interpolate-sequence

: get-interpolated ( interpolated -- quot )
    var>> '[ [ _ of ] keep ] ;

: ?present ( object -- string )
    dup [ present ] when ;

: interpolate-attr ( key value -- quot )
    dup interpolated?
    [ get-interpolated '[ _ swap @ [ ?present 2array ] dip ] ]
    [ 2array '[ _ swap ] ] if ;

: interpolate-attrs ( attrs -- quot )
    [
        [ [ interpolate-attr ] { } assoc>map [ ] join ]
        [ assoc-size ] bi
        '[ @ _ swap [ narray sift-values <attrs> ] dip ]
    ] when-interpolated ;

: interpolate-tag ( tag -- quot )
    [
        [ name>> ]
        [ attrs>> interpolate-attrs ]
        [ children>> interpolate-sequence ] tri
        '[ _ swap @ @ [ <tag> ] dip ]
    ] when-interpolated ;

GENERIC: push-item ( item -- )
M: string push-item , ;
M: xml-data push-item , ;
M: object push-item present , ;
M: sequence push-item
    dup xml-data? [ , ] [ [ push-item ] each ] if ;
M: xml push-item
    [ before>> push-item ]
    [ body>> push-item ]
    [ after>> push-item ] tri ;
M: number push-item present , ;
M: xml-chunk push-item % ;

: concat-interpolate ( array -- newarray )
    [ [ push-item ] each ] { } make ;

GENERIC: interpolate-item ( item -- quot )
M: object interpolate-item [ swap ] curry ;
M: tag interpolate-item interpolate-tag ;
M: interpolated interpolate-item get-interpolated ;

: interpolate-sequence ( seq -- quot )
    [
        [ [ interpolate-item ] map concat ]
        [ length ] bi
        '[ @ _ swap [ narray concat-interpolate ] dip ]
    ] when-interpolated ;

GENERIC: [interpolate-xml] ( xml -- quot )

M: xml [interpolate-xml]
    dup body>> interpolate-tag
    '[ _ (clone) swap @ drop >>body ] ;

M: xml-chunk [interpolate-xml]
    interpolate-sequence
    '[ @ drop <xml-chunk> ] ;

MACRO: interpolate-xml ( xml -- quot )
    [interpolate-xml] ;

: number<-> ( doc -- dup )
    0 over [
        dup var>> [
            over >>var [ 1 + ] dip
        ] unless drop
    ] each-interpolated drop ;

: >search-hash ( seq -- hash )
    [ dup parse-word ] H{ } map>assoc ;

: extract-variables ( xml -- seq )
    [ [ var>> , ] each-interpolated ] { } make ;

: nenum ( ... n -- assoc )
    narray <enumerated> ; inline

: collect ( accum variables -- accum ? )
    {
        { [ dup empty? ] [ drop f ] } ! Just a literal
        { [ dup [ ] all? ] [ >search-hash suffix! t ] } ! locals
        { [ dup [ not ] all? ] [ length suffix! \ nenum suffix! t ] } ! fry
        [ drop "XML interpolation contains both fry and locals" throw ] ! mixed
    } cond ;

: parse-def ( accum delimiter quot -- accum )
    [ parse-multiline-string [ blank? ] trim ] dip call
    [ extract-variables collect ] guard
    [ number<-> suffix! ] dip
    [ \ interpolate-xml suffix! ] when ; inline

PRIVATE>

SYNTAX: <XML
    "XML>" [ string>doc ] parse-def ;

SYNTAX: [XML
    "XML]" [ string>chunk ] parse-def ;

USE: vocabs.loader

{ "xml.syntax" "inverse" } "xml.syntax.inverse" require-when
