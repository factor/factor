USING: accessors arrays images images.viewer
images.viewer.private kernel math math.order math.vectors
opengl.textures opengl.textures.private sequences ui.gadgets
ui.gestures ui.render ;
IN: images.viewer.scaling

TUPLE: scaling-image-gadget < image-gadget { scale initial: 1 } saved-scale ;
TUPLE: autoscaling-image-gadget < image-gadget fill ;

<PRIVATE

M: scaling-image-gadget pref-dim* dup pref-dim>> [ nip ] [ [ image>> dim>> ] [ scale>> ] bi v*n [ >integer 1 max ] map ] if* ;

M: scaling-image-gadget draw-gadget*
  dup image>> [
    [ pref-dim ] [ image-gadget-texture draw-scaled-texture ] bi
  ] [ drop ] if ;

: fill-in-by-aspect-ratio ( image-gadget dim -- dim )
  dup first2 xor 
  [ [ image>> dim>> first2 / ] dip first2 [ nip [ * round ] keep ] [ [ swap /f round ] keep swap ] if* 2array ] [ nip ] if ;
: cover-image ( image-gadget fill -- dim )
  [ over
  parent>>
  [ root?>> ] find-parent
  dim>> swap [ [ * ] [ drop f ] if* ] 2map fill-in-by-aspect-ratio ] [ image>> dim>> ] if* ;
:: contain-image ( image-gadget fill -- dim )
  image-gadget dup [
  parent>> 
  [ root?>> ] find-parent
  dim>> ] [ image>> dim>> ] bi v- first2 < { fill f } { f fill } ? cover-image ;
: parent-fill-dims ( image-gadget -- dim )
  dup fill>> dup number? [ contain-image ] [ cover-image ] if ;

: trigger-viewport-relayout ( image-gadget -- )
  [ dup root?>> [ drop f ] [ forget-pref-dim t ] if ] each-parent drop
  ;

M: autoscaling-image-gadget layout* pref-dim drop ;
M: autoscaling-image-gadget pref-dim* dup pref-dim>> [ nip ] [ [ parent-fill-dims [ >integer 1 max ] map dup ] [ model>> ?set-model ] bi ] if* ;

M: autoscaling-image-gadget draw-gadget*
  dup image>> [
    [ pref-dim ]
    [ image-gadget-texture draw-scaled-texture ]
    [ trigger-viewport-relayout ]
    tri
  ] [ drop ] if ;
M: autoscaling-image-gadget model-changed nip relayout ;



PRIVATE>

: <scaling-image-gadget> ( object -- gadget )
  \ scaling-image-gadget new-image-gadget* ;
: <autoscaling-image-gadget> ( object -- gadget )
  \ autoscaling-image-gadget new-image-gadget* dup image>> dim>> <model> >>model ;

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
