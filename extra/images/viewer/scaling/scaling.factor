USING: accessors arrays images images.viewer
images.viewer.private kernel math math.order math.vectors
opengl.textures opengl.textures.private sequences ui.gadgets
ui.gestures ui.render ;
IN: images.viewer.scaling

TUPLE: scaling-image-gadget < image-gadget { scale initial: 1 } saved-scale ;

<PRIVATE

M: scaling-image-gadget pref-dim* dup pref-dim>> [ nip ] [ [ image>> dim>> ] [ scale>> ] bi v*n [ >integer 1 max ] map ] if* ;

M: scaling-image-gadget draw-gadget*
  dup image>> [
    [ pref-dim ] [ image-gadget-texture draw-scaled-texture ] bi
  ] [ drop ] if ;
    
PRIVATE>

: <scaling-image-gadget> ( object -- gadget )
  \ scaling-image-gadget new-image-gadget* ;

: store-reference-scale ( image -- )
  dup scale>> >>saved-scale drop ;

! increase for a slower scaling change
CONSTANT: scaling-proportional-factor 100
: scale-image ( image -- )
  drag-loc first2 + scaling-proportional-factor /f over saved-scale>> + 0 max >>scale relayout ;

scaling-image-gadget {
    { T{ button-down { # 2 } } [ store-reference-scale ] }
    { T{ drag { # 2 } } [ scale-image ] }
} set-gestures
