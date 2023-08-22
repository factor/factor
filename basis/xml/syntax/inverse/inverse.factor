! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit inverse kernel namespaces sequences
sequences.generalizations sorting strings unicode xml.data ;
USE: xml.syntax.private ! required but does not reference words
IN: xml.syntax.inverse

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
    [ assure-length ] [ firstn ] 2bi ; inline

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
    sort-keys values <enumerated> ;

: undo-xml ( xml -- quot )
    [undo-xml] '[ H{ } clone [ _ with-variables ] keep >enum ] ;

\ interpolate-xml 1 [ undo-xml ] define-pop-inverse
