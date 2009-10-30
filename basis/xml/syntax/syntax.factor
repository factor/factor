! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: words assocs kernel accessors parser vocabs.parser effects.parser
sequences summary lexer splitting combinators locals
memoize sequences.deep xml.data xml.state xml namespaces present
arrays generalizations strings make math macros multiline
inverse combinators.short-circuit sorting fry unicode.categories
effects ;
IN: xml.syntax

<PRIVATE

TUPLE: no-tag name word ;
M: no-tag summary
    drop "The tag-dispatching word has no method for the given tag name" ;

: compile-tags ( word xtable -- quot )
    >alist swap '[ _ no-tag boa throw ] suffix
    '[ dup main>> _ case ] ;

: define-tags ( word effect -- )
    [ dup dup "xtable" word-prop compile-tags ] dip define-declared ;

:: define-tag ( string word quot -- )
    quot string word "xtable" word-prop set-at
    word word stack-effect define-tags ;

PRIVATE>

SYNTAX: TAGS:
    CREATE-WORD complete-effect
    [ drop H{ } clone "xtable" set-word-prop ]
    [ define-tags ]
    2bi ;

SYNTAX: TAG:
    scan scan-word parse-definition define-tag ;

SYNTAX: XML-NS:
    CREATE-WORD scan '[ f swap _ <name> ] (( string -- name )) define-memoized ;

<PRIVATE

: each-attrs ( attrs quot -- )
    [ values [ interpolated? ] filter ] dip each ; inline

: (each-interpolated) ( item quot: ( interpolated -- ) -- )
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
    var>> '[ [ _ swap at ] keep ] ;

: ?present ( object -- string )
    dup [ present ] when ;

: interpolate-attr ( key value -- quot )
    dup interpolated?
    [ get-interpolated '[ _ swap @ [ ?present 2array ] dip ] ]
    [ 2array '[ _ swap ] ] if ;

: filter-nulls ( assoc -- newassoc )
    [ nip ] assoc-filter ;

: interpolate-attrs ( attrs -- quot )
    [
        [ [ interpolate-attr ] { } assoc>map [ ] join ]
        [ assoc-size ] bi
        '[ @ _ swap [ narray filter-nulls <attrs> ] dip ]
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
    [ dup search ] H{ } map>assoc ;

: extract-variables ( xml -- seq )
    [ [ var>> , ] each-interpolated ] { } make ;

: nenum ( ... n -- assoc )
    narray <enum> ; inline

: collect ( accum variables -- accum ? )
    {
        { [ dup empty? ] [ drop f ] } ! Just a literal
        { [ dup [ ] all? ] [ >search-hash suffix! t ] } ! locals
        { [ dup [ not ] all? ] [ length suffix! \ nenum suffix! t ] } ! fry
        [ drop "XML interpolation contains both fry and locals" throw ] ! mixed
    } cond ;

: parse-def ( accum delimiter quot -- accum )
    [ parse-multiline-string [ blank? ] trim ] dip call
    [ extract-variables collect ] keep swap
    [ number<-> suffix! ] dip
    [ \ interpolate-xml suffix! ] when ; inline

PRIVATE>

SYNTAX: <XML
    "XML>" [ string>doc ] parse-def ;

SYNTAX: [XML
    "XML]" [ string>chunk ] parse-def ;

<PRIVATE

: remove-blanks ( seq -- newseq )
    [ { [ string? not ] [ [ blank? ] all? not ] } 1|| ] filter ;

GENERIC: >xml ( xml -- tag )
M: xml >xml body>> ;
M: tag >xml ;
M: xml-chunk >xml
    remove-blanks
    [ length 1 =/fail ]
    [ first dup tag? [ fail ] unless ] bi ;
M: object >xml fail ;

: 1chunk ( object -- xml-chunk )
    1array <xml-chunk> ;

GENERIC: >xml-chunk ( xml -- chunk )
M: xml >xml-chunk body>> 1chunk ;
M: xml-chunk >xml-chunk ;
M: object >xml-chunk 1chunk ;

GENERIC: [undo-xml] ( xml -- quot )

M: xml [undo-xml]
    body>> [undo-xml] '[ >xml @ ] ;

M: xml-chunk [undo-xml]
    seq>> [undo-xml] '[ >xml-chunk @ ] ;

: undo-attrs ( attrs -- quot: ( attrs -- ) )
    [
        [ main>> ] dip dup interpolated?
        [ var>> '[ _ attr _ set ] ]
        [ '[ _ attr _ =/fail ] ] if
    ] { } assoc>map '[ _ cleave ] ;

M: tag [undo-xml] ( tag -- quot: ( tag -- ) )
    {
        [ name>> main>> '[ name>> main>> _ =/fail ] ]
        [ attrs>> undo-attrs ] 
        [ children>> [undo-xml] '[ children>> @ ] ]
    } cleave '[ _ _ _ tri ] ;

: firstn-strong ( seq n -- ... )
    [ swap length =/fail ]
    [ firstn ] 2bi ; inline

M: sequence [undo-xml] ( sequence -- quot: ( seq -- ) )
    remove-blanks [ length ] [ [ [undo-xml] ] { } map-as ] bi
    '[ remove-blanks _ firstn-strong _ spread ] ;

M: string [undo-xml] ( string -- quot: ( string -- ) )
    '[ _ =/fail ] ;

M: xml-data [undo-xml] ( datum -- quot: ( datum -- ) )
    '[ _ =/fail ] ;

M: interpolated [undo-xml]
    var>> '[ _ set ] ;

: >enum ( assoc -- enum )
    ! Assumes keys are 0..n
    >alist sort-keys values <enum> ;

: undo-xml ( xml -- quot )
    [undo-xml] '[ H{ } clone [ _ bind ] keep >enum ] ;

\ interpolate-xml 1 [ undo-xml ] define-pop-inverse

PRIVATE>
