! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: xml xml.state kernel sequences fry assocs xml.data
accessors strings make multiline parser namespaces macros
sequences.deep ;
IN: xml.interpolate

<PRIVATE

: interpolated-chunk ( string -- chunk )
    t interpolating? [ string>xml-chunk ] with-variable ;

: interpolated-doc ( string -- xml )
    t interpolating? [ string>xml ] with-variable ;

DEFER: interpolate-sequence

: interpolate-attrs ( table attrs -- attrs )
    swap '[ dup interpolated? [ var>> _ at ] when ] assoc-map ;

: interpolate-tag ( table tag -- tag )
    [ nip name>> ]
    [ attrs>> interpolate-attrs ]
    [ children>> [ interpolate-sequence ] [ drop f ] if* ] 2tri
    <tag> ;

GENERIC: push-item ( item -- )
M: string push-item , ;
M: object push-item , ;
M: sequence push-item % ;

GENERIC: interpolate-item ( table item -- )
M: object interpolate-item nip , ;
M: tag interpolate-item interpolate-tag , ;
M: interpolated interpolate-item
    var>> swap at push-item ;

: interpolate-sequence ( table seq -- seq )
    [ [ interpolate-item ] with each ] { } make ;

: interpolate-xml-doc ( table xml -- xml )
    (clone) [ interpolate-tag ] change-body ;

MACRO: interpolate-xml ( string -- doc )
    interpolated-doc '[ _ interpolate-xml-doc ] ;

MACRO: interpolate-chunk ( string -- chunk )
    interpolated-chunk '[ _ interpolate-sequence ] ;

: >search-hash ( seq -- hash )
    [ dup search ] H{ } map>assoc ;

GENERIC: extract-item ( item -- )
M: interpolated extract-item var>> , ;
M: tag extract-item
    attrs>> values
    [ interpolated? ] filter
    [ var>> , ] each ;
M: object extract-item drop ;

: extract-variables ( xml -- seq )
    [ [ extract-item ] deep-each ] { } make ;

: parse-def ( accum delimiter word -- accum )
    [
        parse-multiline-string [
            interpolated-chunk extract-variables
            >search-hash parsed
        ] keep parsed
    ] dip parsed ;

PRIVATE>

: <XML
    "XML>" \ interpolate-xml parse-def ; parsing

: [XML
    "XML]" \ interpolate-chunk parse-def ; parsing
