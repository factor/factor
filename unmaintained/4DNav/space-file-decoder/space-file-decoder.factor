! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: adsoda xml xml.traversal xml.syntax accessors 
combinators sequences math.parser kernel splitting values 
continuations ;
IN: 4DNav.space-file-decoder

: decode-number-array ( x -- y )  
    "," split [ string>number ] map ;

TAGS: adsoda-read-model ( tag -- model )

TAG: dimension adsoda-read-model 
    children>> first string>number ;
TAG: direction adsoda-read-model 
    children>> first decode-number-array ;
TAG: color     adsoda-read-model 
    children>> first decode-number-array ;
TAG: name      adsoda-read-model 
    children>> first ;
TAG: face      adsoda-read-model 
    children>> first decode-number-array ;

TAG: solid adsoda-read-model 
    <solid> swap  
    { 
        [ "dimension" tag-named adsoda-read-model >>dimension ]
        [ "name"      tag-named adsoda-read-model >>name ] 
        [ "color"     tag-named adsoda-read-model >>color ] 
        [ "face"      
            tags-named [ adsoda-read-model cut-solid ] each ] 
    } cleave
    ensure-adjacencies
;

TAG: light adsoda-read-model 
   <light> swap  
    { 
        [ "direction" tag-named adsoda-read-model >>direction ]
        [ "color"     tag-named adsoda-read-model >>color ] 
    } cleave
;

TAG: space adsoda-read-model 
    <space> swap  
    { 
        [ "dimension" tag-named adsoda-read-model >>dimension ]
        [ "name"      tag-named adsoda-read-model >>name ] 
        [ "color"     tag-named 
            adsoda-read-model >>ambient-color ] 
        [ "solid"     tags-named 
            [ adsoda-read-model suffix-solids ] each ] 
        [ "light"     tags-named 
            [ adsoda-read-model suffix-lights ] each ]
    } cleave
;

: read-model-file ( path -- x )
    [
        [ file>xml "space" tag-named adsoda-read-model ] 
        [ 2drop <space> ] recover 
    ] [ <space> ] if*
;

