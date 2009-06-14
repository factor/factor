USING: accessors arrays kernel monads models models.product sequences ui.frp.functors
classes ui.tools.inspector tools.continuations ;
FROM: models.product => product ;
IN: ui.frp.signals

GENERIC: (unique) ( gadget -- a )
M: model (unique) ;
: unique ( a -- b ) [ class ] [ (unique) ] bi 2array ;
: unique= ( a b -- ? ) [ unique ] bi@ = ;

GENERIC: null-val ( gadget -- model )
M: model null-val drop f ;

TUPLE: multi-model < model important? ;
GENERIC: (model-changed) ( model observer -- )
: <multi-model> ( models kind -- model ) f swap new-model [ [ add-dependency ] curry each ] keep ;
M: multi-model model-changed over value>> [ (model-changed) ] [ 2drop ] if ;
M: multi-model model-activated dup dependencies>> [ value>> ] find nip
   [ swap model-changed ] [ drop ] if* ;

: #1 ( model -- model' ) t >>important? ;

IN: models
: notify-connections ( model -- )
    dup connections>> dup [ dup multi-model? [ important?>> ] [ drop f ] if ] find-all
    [ second tuck [ remove ] dip prefix ] each
    [ model-changed ] with each ;
IN: ui.frp.signals

TUPLE: basic-model < multi-model ;
M: basic-model (model-changed) [ value>> ] dip set-model ;
: <merge> ( models -- signal ) basic-model <multi-model> ;
: <basic> ( value -- signal ) basic-model new-model ;

TUPLE: filter-model < multi-model quot ;
M: filter-model (model-changed) [ value>> ] dip 2dup quot>> call( a -- ? )
   [ set-model ] [ 2drop ] if ;
: <filter> ( model quot -- filter-signal ) [ 1array filter-model <multi-model> ] dip >>quot ;

TUPLE: fold-model < multi-model quot ;
M: fold-model (model-changed) [ [ value>> ] [ [ value>> ] [ quot>> ] bi ] bi*
   call( val oldval -- newval ) ] keep set-model ;
: <fold> ( model oldval quot -- signal ) rot 1array fold-model <multi-model> swap >>quot
   swap >>value ;

TUPLE: updater-model < multi-model values updates ;
M: updater-model (model-changed) tuck updates>> =
   [ [ values>> value>> ] keep set-model ]
   [ drop ] if ;
: <updates> ( values updates -- signal ) [ 2array updater-model <multi-model> ] 2keep
   [ >>values ] [ >>updates ] bi* ;

SYMBOL: switch
TUPLE: switch-model < multi-model original switcher on ;
M: switch-model (model-changed) 2dup switcher>> =
   [ [ value>> ] dip over switch = [ nip [ original>> ] keep f >>on model-changed ] [ t >>on set-model ] if ]
   [ dup on>> [ 2drop ] [ [ value>> ] dip over [ set-model ] [ 2drop ] if ] if ] if ;
: <switch> ( signal1 signal2 -- signal' ) swap [ 2array switch-model <multi-model> ] 2keep
   [ [ value>> >>value ] [ >>original ] bi ] [ >>switcher ] bi* ;
M: switch-model model-activated [ original>> ] keep model-changed ;
: >behavior ( event -- behavior ) t <model> <switch> ;

TUPLE: mapped-model < multi-model model quot ;
: new-mapped-model ( model quot class -- mapped-model ) [ over 1array ] dip
   <multi-model> swap >>quot swap >>model ;
: <mapped> ( model quot -- signal ) mapped-model new-mapped-model ;
M: mapped-model (model-changed)
    [ [ value>> ] [ quot>> ] bi* call( old -- new ) ] [ nip ] 2bi
    set-model ;

TUPLE: side-effect-model < mapped-model ;
M: side-effect-model (model-changed) [ [ value>> ] [ quot>> ] bi* call( old -- ) ] keep t swap set-model ;
: $> ( model quot -- signal ) side-effect-model new-mapped-model ;

TUPLE: quot-model < mapped-model ;
M: quot-model (model-changed) nip [ quot>> call( -- b ) ] keep set-model ;
: <$ ( model quot -- signal ) quot-model new-mapped-model ;

TUPLE: action-value < basic-model parent ;
: <action-value> ( parent value -- model ) action-value new-model swap >>parent ;
M: action-value model-activated dup parent>> dup activate-model model-changed ; ! a fake dependency of sorts

TUPLE: action < multi-model quot ;
M: action (model-changed) [ [ value>> ] [ quot>> ] bi* call( a -- b ) ] keep value>>
   [ swap add-connection ] 2keep model-changed ;
: <action> ( model quot -- action-signal ) [ 1array action <multi-model> ] dip >>quot dup f <action-value> >>value value>> ;
<PRIVATE

TUPLE: | < multi-model ;
: <|> ( models -- product ) | <multi-model> ;
GENERIC: models-changed ( product -- )
M: | models-changed drop ;
M: | model-changed
    nip
    dup dependencies>> [ value>> ] all?
    [ [ dup [ value>> ] product-value >>value notify-connections ] keep models-changed ]
    [ drop ] if ;
M: | update-model
    dup value>> swap [ set-model ] set-product-value ;
M: | model-activated dup model-changed ;

TUPLE: & < | ;
: <&> ( models -- product ) & <multi-model> ;
M: & models-changed dependencies>> [ [ null-val ] keep (>>value) ] each ;
PRIVATE>

M: model >>= [ swap <action> ] curry ;
M: model fmap <mapped> ;
FMAPS: $> <$ fmap FOR & | product ;