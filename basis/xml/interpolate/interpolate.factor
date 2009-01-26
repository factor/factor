! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: xml xml.state kernel sequences fry assocs xml.data
accessors strings make multiline parser namespaces macros
sequences.deep generalizations locals words combinators
math present arrays ;
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
M: object push-item , ;
M: sequence push-item
    [ dup array? [ % ] [ , ] if ] each ;

GENERIC: interpolate-item ( table item -- )
M: object interpolate-item nip , ;
M: tag interpolate-item interpolate-tag , ;
M: interpolated interpolate-item
    var>> swap at push-item ;

: interpolate-sequence ( table seq -- seq )
    [ [ interpolate-item ] with each ] { } make ;

: interpolate-xml-doc ( table xml -- xml )
    (clone) [ interpolate-tag ] change-body ;

GENERIC# (each-interpolated) 1 ( item quot -- ) inline
M: interpolated (each-interpolated) call ;
M: tag (each-interpolated)
    swap attrs>> values
    [ interpolated? ] filter
    swap each ;
M: xml (each-interpolated)
    [ body>> ] dip (each-interpolated) ;
M: object (each-interpolated) 2drop ;

: each-interpolated ( xml quot -- )
    '[ _ (each-interpolated) ] deep-each ; inline

:: number<-> ( doc -- doc )
    0 :> n! doc [
        dup var>> [ n >>var n 1+ n! ] unless drop
    ] each-interpolated doc ;

MACRO: interpolate-xml ( string -- doc )
    string>doc number<-> '[ _ interpolate-xml-doc ] ;

MACRO: interpolate-chunk ( string -- chunk )
    string>chunk number<-> '[ _ interpolate-sequence ] ;

: >search-hash ( seq -- hash )
    [ dup search ] H{ } map>assoc ;

: extract-variables ( xml -- seq )
    [ [ var>> , ] each-interpolated ] { } make ;

: nenum ( ... n -- assoc )
    narray <enum> ; inline

: collect ( accum seq -- accum )
    {
        { [ dup [ ] all? ] [ >search-hash parsed ] } ! locals
        { [ dup [ not ] all? ] [ ! fry
            length parsed \ nenum parsed
        ] }
        [ drop "XML interpolation contains both fry and locals" throw ] ! mixed
    } cond ;

: parse-def ( accum delimiter word -- accum )
    [
        parse-multiline-string
        [ string>chunk extract-variables collect ] keep
        parsed
    ] dip parsed ;

PRIVATE>

: <XML
    "XML>" \ interpolate-xml parse-def ; parsing

: [XML
    "XML]" \ interpolate-chunk parse-def ; parsing
