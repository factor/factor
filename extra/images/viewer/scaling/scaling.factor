USING: accessors arrays images images.viewer
images.viewer.private kernel math math.functions math.order
math.vectors models opengl.textures opengl.textures.private
sequences ui.gadgets ui.gadgets.private ui.gestures ui.render ;
IN: images.viewer.scaling

TUPLE: scaling-image-gadget < image-gadget { scale initial: 1 } saved-scale ;
TUPLE: autoscaling-image-gadget < image-gadget fill ;

<PRIVATE

M: scaling-image-gadget pref-dim* dup pref-dim>>
  [ nip ]
  [ [ image>> dim>> ] [ scale>> ] bi v*n v>integer ] if* ;

M: scaling-image-gadget draw-gadget*
  dup image>> [
    [ pref-dim ] [ image-gadget-texture draw-scaled-texture ] bi
  ] [ drop ] if ;

: root-gadget-dim ( gadget -- dim )
  parent>> [ root?>> ] find-parent dim>> ;

: fill-x-axis-by-aspect-ratio ( ratio f y -- x' y' ) 
  nip [ * round ] keep ;
: fill-y-axis-by-aspect-ratio ( ratio x -- x' y' )
  [ swap /f round ] keep swap ;
: image-aspect-ratio ( image-gadget -- ratio )
  image>> dim>> first2 / ;
: fill-axis-by-aspect-ratio ( image-gadget fill -- fill' )
  [ image-aspect-ratio ] [ first2 ] bi*
  [ fill-x-axis-by-aspect-ratio ] [ fill-y-axis-by-aspect-ratio ] if* 2array ;
: fill-in-by-aspect-ratio ( image-gadget fill -- fill' )
  dup first2 xor 
  [ fill-axis-by-aspect-ratio ] [ nip ] if ;
:: fit-aspect-ratio ( dim ratio fill -- fill' )
  { fill f } dim first2 ratio * < [ <reversed> ] unless ;
: fill-aspect-ratio ( image-gadget -- fill )
  [ root-gadget-dim ] [ image-aspect-ratio ] bi 1 fit-aspect-ratio <reversed> ;
: scale-fill-by-root-dims ( image-gadget fill -- dim )
  [ root-gadget-dim ] [ [ [ * ] [ drop f ] if* ] 2map ] bi* ;
: cover-image ( image-gadget fill -- fill' )
  dup first2 or not
  [ drop dup fill-aspect-ratio cover-image ]
  [ dupd scale-fill-by-root-dims fill-in-by-aspect-ratio ] if ;
: fill-by-minimum-dim ( dim1 dim2 fill -- fill' )
  [ v- first2 < ] dip f 2array swap [ <reversed> ] unless ;
: contain-image ( image-gadget fill -- fill' )
  [ dup [ root-gadget-dim ] [ image-aspect-ratio ] bi ]
  [ fit-aspect-ratio ] bi*
  cover-image ;
: parent-fill-dims ( image-gadget -- dim )
  dup fill>>
  [ dup number? [ contain-image ] [ cover-image ] if ]
  [ image>> dim>> ] if* ;

M: autoscaling-image-gadget layout* pref-dim drop ;
M: autoscaling-image-gadget pref-dim* dup pref-dim>>
  [ nip ]
  [
    [ parent-fill-dims v>integer dup ]
    [ model>> ?set-model ] bi
  ] if* ;

: trigger-root-relayout ( image-gadget -- )
  [ dup root?>> [ drop f ] [ forget-pref-dim t ] if ] each-parent drop ;

M: autoscaling-image-gadget draw-gadget*
  dup image>> [
    [ pref-dim ]
    [ image-gadget-texture draw-scaled-texture ]
    [ trigger-root-relayout ]
    tri
  ] [ drop ] if ;
M: autoscaling-image-gadget model-changed nip relayout ;

PRIVATE>

: <scaling-image-gadget> ( object -- gadget )
  \ scaling-image-gadget new-image-gadget* ;
: <autoscaling-image-gadget> ( object -- gadget )
  \ autoscaling-image-gadget new-image-gadget* dup image>> dim>> <model> >>model
  ;

: store-reference-scale ( image -- )
  dup scale>> >>saved-scale drop ;

! increase for a slower scaling change
CONSTANT: scaling-inverse-proportional-factor 100
: scale-image ( image -- )
  drag-loc first2 + scaling-inverse-proportional-factor /f over saved-scale>> +
  0 max >>scale relayout ;

scaling-image-gadget {
    { T{ button-down { # 3 } } [ store-reference-scale ] }
    { T{ drag { # 3 } } [ scale-image ] }
} set-gestures
