! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: xml xml.state kernel sequences fry assocs xml.data
accessors strings make multiline parser namespaces macros
sequences.deep generalizations words combinators
math present arrays unicode.categories ;
IN: xml.interpolate

<PRIVATE

: string>chunk ( string -- chunk )
    t interpolating? [ string>xml-chunk ] with-variable ;

: string>doc ( string -- xml )
    t interpolating? [ string>xml ] with-variable ;

DEFER: interpolate-sequence

: interpolate-attrs ( table attrs -- attrs )
    swap '[
        dup interpolated?
        [ var>> _ at dup [ present ] when ] when
    ] assoc-map [ nip ] assoc-filter ;

: interpolate-tag ( table tag -- tag )
    [ nip name>> ]
    [ attrs>> interpolate-attrs ]
    [ children>> [ interpolate-sequence ] [ drop f ] if* ] 2tri
    <tag> ;

GENERIC: push-item ( item -- )
M: string push-item , ;
M: xml-data push-item , ;
M: object push-item present , ;
M: sequence push-item
    dup xml-data? [ , ] [ [ push-item ] each ] if ;
M: number push-item present , ;
M: xml-chunk push-item % ;

GENERIC: interpolate-item ( table item -- )
M: object interpolate-item nip , ;
M: tag interpolate-item interpolate-tag , ;
M: interpolated interpolate-item
    var>> swap at push-item ;

: interpolate-sequence ( table seq -- seq )
    [ [ interpolate-item ] with each ] { } make ;

: interpolate-xml-doc ( table xml -- xml )
    (clone) [ interpolate-tag ] change-body ;

: (each-interpolated) ( item quot: ( interpolated -- ) -- )
     {
        { [ over interpolated? ] [ call ] }
        { [ over tag? ] [
            [ attrs>> values [ interpolated? ] filter ] dip each
        ] }
        { [ over xml? ] [ [ body>> ] dip (each-interpolated) ] }
        [ 2drop ]
     } cond ; inline recursive

: each-interpolated ( xml quot -- )
    '[ _ (each-interpolated) ] deep-each ; inline

: number<-> ( doc -- dup )
    0 over [
        dup var>> [
            over >>var [ 1+ ] dip
        ] unless drop
    ] each-interpolated drop ;

GENERIC: interpolate-xml ( table xml -- xml )

M: xml interpolate-xml
    interpolate-xml-doc ;

M: xml-chunk interpolate-xml
    interpolate-sequence <xml-chunk> ;

: >search-hash ( seq -- hash )
    [ dup search ] H{ } map>assoc ;

: extract-variables ( xml -- seq )
    [ [ var>> , ] each-interpolated ] { } make ;

: nenum ( ... n -- assoc )
    narray <enum> ; inline

: collect ( accum variables -- accum ? )
    {
        { [ dup empty? ] [ drop f ] } ! Just a literal
        { [ dup [ ] all? ] [ >search-hash parsed t ] } ! locals
        { [ dup [ not ] all? ] [ length parsed \ nenum parsed t ] } ! fry
        [ drop "XML interpolation contains both fry and locals" throw ] ! mixed
    } cond ;

: parse-def ( accum delimiter quot -- accum )
    [ parse-multiline-string [ blank? ] trim ] dip call
    [ extract-variables collect ] keep swap
    [ number<-> parsed ] dip
    [ \ interpolate-xml parsed ] when ; inline

PRIVATE>

: <XML
    "XML>" [ string>doc ] parse-def ; parsing

: [XML
    "XML]" [ string>chunk ] parse-def ; parsing
