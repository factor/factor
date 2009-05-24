USING: accessors arrays kernel models models.product sequences ;
IN: ui.frp.signals

TUPLE: multi-model < model ;
GENERIC: (model-changed) ( model observer -- )
: <multi-model> ( models kind -- model ) f swap new-model [ [ add-dependency ] curry each ] keep ;
M: multi-model model-changed over value>> [ (model-changed) ] [ 2drop ] if ;
M: multi-model model-activated dup dependencies>> dup length 1 =
   [ first swap model-changed ] [ 2drop ] if ;

TUPLE: basic-model < multi-model ;
M: basic-model (model-changed) [ value>> ] dip set-model ;
: <merge> ( models -- model ) basic-model <multi-model> ;
: <basic> ( value -- model ) basic-model new-model ;

TUPLE: filter-model < multi-model quot ;
M: filter-model (model-changed) [ value>> ] dip 2dup quot>> call( a -- ? )
   [ set-model ] [ 2drop ] if ;
: <filter> ( model quot -- filter-model ) [ 1array filter-model <multi-model> ] dip >>quot ;

TUPLE: fold-model < multi-model oldval quot ;
M: fold-model (model-changed) [ [ value>> ] [ [ oldval>> ] [ quot>> ] bi ] bi*
   call( val oldval -- newval ) ] keep set-model ;
: <fold> ( oldval quot model -- model' ) 1array fold-model <multi-model> swap >>quot
   swap [ >>oldval ] [ >>value ] bi ;

TUPLE: updater-model < multi-model values updates ;
M: updater-model (model-changed) tuck updates>> =
   [ [ values>> value>> ] keep set-model ]
   [ drop ] if ;
: <updates> ( values updates -- updater ) [ 2array updater-model <multi-model> ] 2keep
   [ >>values ] [ >>updates ] bi* ;

TUPLE: switch-model < multi-model original switcher on ;
M: switch-model (model-changed) 2dup switcher>> =
   [ [ value>> ] [ t >>on ] bi* set-model ]
   [ dup on>> [ 2drop ] [ [ value>> ] dip set-model ] if ] if ;
: <switch> ( signal1 signal2 -- signal' ) [ 2array switch-model <multi-model> ] 2keep
   [ >>original ] [ >>switcher ] bi* ;
M: switch-model model-activated [ original>> ] keep model-changed ;

TUPLE: mapped-model < multi-model model quot ;
: new-mapped-model ( model quot class -- const-model ) [ over 1array ] dip
   <multi-model> swap >>quot swap >>model ;
: <mapped> ( model quot -- mapped ) mapped-model new-mapped-model ;
M: mapped-model (model-changed)
    [ [ value>> ] [ quot>> ] bi* call( old -- new ) ] [ nip ] 2bi
    set-model ;

TUPLE: side-effect-model < mapped-model ;
M: side-effect-model (model-changed) [ [ value>> ] [ quot>> ] bi* call( old -- ) ] keep t swap set-model ;
: $> ( model quot -- side-effect-model ) side-effect-model new-mapped-model ;

TUPLE: quot-model < mapped-model ;
M: quot-model (model-changed) nip [ quot>> call( -- b ) ] keep set-model ;
: <$ ( model quot -- quot-model ) quot-model new-mapped-model ;

TUPLE: action-value < basic-model parent ;
: <action-value> ( parent value -- model ) action-value new-model swap >>parent ;
M: action-value model-activated dup parent>> dup activate-model model-changed ; ! a fake dependency of sorts

TUPLE: action < multi-model quot ;
M: action (model-changed) [ [ value>> ] [ quot>> ] bi* call( a -- b ) ] keep value>>
   [ swap add-connection ] 2keep model-changed ;
: <action> ( model quot -- action ) [ 1array action <multi-model> ] dip >>quot dup f <action-value> >>value value>> ;

TUPLE: | < multi-model ;
: <|> ( models -- product ) | <multi-model> ;
M: | model-changed
    nip
    dup dependencies>> [ value>> ] all?
    [ dup [ value>> ] product-value >>value notify-connections
    ] [ drop ] if ;
M: | update-model
    dup value>> swap [ set-model ] set-product-value ;
M: | model-activated dup model-changed ;

TUPLE: & < | ;
: <&> ( models -- product ) & <multi-model> ;
M: & model-changed [ call-next-method ] keep
   [ dependencies>> [ f swap set-model ] each ] with-locked-model ;