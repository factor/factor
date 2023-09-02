USING: accessors arrays kernel models models.product monads
sequences sequences.extras shuffle ;
FROM: syntax => >> ;
IN: models.combinators

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
IN: models.combinators

TUPLE: basic-model < multi-model ;
M: basic-model (model-changed) [ value>> ] dip set-model ;
: merge ( models -- model ) basic-model <multi-model> ;
: 2merge ( model1 model2 -- model ) 2array merge ;
: <basic> ( value -- model ) basic-model new-model ;

TUPLE: filter-model < multi-model quot ;
M: filter-model (model-changed) [ value>> ] dip 2dup quot>> call( a -- ? )
   [ set-model ] [ 2drop ] if ;
: filter-model ( model quot -- filter-model ) [ 1array \ filter-model <multi-model> ] dip >>quot ;

<PRIVATE
! Quot must have static stack effect, unlike "reduce"
:: reduce* ( seq identity quot: ( prev elt -- next ) -- result )
    seq [ identity ] [
        unclip identity swap quot call( prev elt -- next )
        quot reduce*
    ] if-empty ; inline recursive
PRIVATE>

TUPLE: fold-model < multi-model quot base values ;
M: fold-model (model-changed) 2dup base>> =
    [ [ [ value>> ] [ [ values>> ] [ quot>> ] bi ] bi* swapd reduce* ] keep set-model ]
    [ [ [ value>> ] [ values>> ] bi* push ]
      [ [ [ value>> ] [ [ value>> ] [ quot>> ] bi ] bi* call( val oldval -- newval ) ] keep set-model ] 2bi
    ] if ;
M: fold-model model-activated drop ;
: new-fold-model ( deps -- model ) fold-model <multi-model> V{ } clone >>values ;
: fold ( model oldval quot -- model ) rot 1array new-fold-model swap >>quot
   swap >>value ;
: fold* ( model oldmodel quot -- model ) over [ [ 2array new-fold-model ] dip >>quot ]
    dip [ >>base ] [ value>> >>value ] bi ;

TUPLE: updater-model < multi-model values updates ;
M: updater-model (model-changed) [ tuck updates>> =
   [ [ values>> value>> ] keep set-model ]
   [ drop ] if ] keep f swap value<< ;
: updates ( values updates -- model ) [ 2array updater-model <multi-model> ] 2keep
   [ >>values ] [ >>updates ] bi* ;

SYMBOL: switch
TUPLE: switch-model < multi-model original switcher on ;
M: switch-model (model-changed) 2dup switcher>> =
   [ [ value>> ] dip over switch = [ nip [ original>> ] keep f >>on model-changed ] [ t >>on set-model ] if ]
   [ dup on>> [ 2drop ] [ [ value>> ] dip over [ set-model ] [ 2drop ] if ] if ] if ;
: switch-models ( model1 model2 -- model' ) swap [ 2array switch-model <multi-model> ] 2keep
   [ [ value>> >>value ] [ >>original ] bi ] [ >>switcher ] bi* ;
M: switch-model model-activated [ original>> ] keep model-changed ;
: >behavior ( event -- behavior ) t >>value ;

TUPLE: mapped-model < multi-model model quot ;
: new-mapped-model ( model quot class -- mapped-model ) [ over 1array ] dip
   <multi-model> swap >>quot swap >>model ;
: <mapped> ( model quot -- model ) mapped-model new-mapped-model ;
M: mapped-model (model-changed)
    [ [ value>> ] [ quot>> ] bi* call( old -- new ) ] [ nip ] 2bi
    set-model ;

TUPLE: side-effect-model < mapped-model ;
M: side-effect-model (model-changed) [ value>> ] dip [ quot>> call( old -- ) ] 2keep set-model ;

TUPLE: quot-model < mapped-model ;
M: quot-model (model-changed) nip [ quot>> call( -- b ) ] keep set-model ;

TUPLE: action-value < basic-model parent ;
: <action-value> ( parent value -- model ) action-value new-model swap >>parent ;
M: action-value model-activated dup parent>> dup activate-model model-changed ; ! a fake dependency of sorts

TUPLE: action < multi-model quot ;
M: action (model-changed) [ [ value>> ] [ quot>> ] bi* call( a -- b ) ] keep value>>
   [ swap add-connection ] 2keep model-changed ;
: <action> ( model quot -- action-model ) [ 1array action <multi-model> ] dip >>quot dup f <action-value> >>value value>> ;

TUPLE: collection < multi-model ;
: <collection> ( models -- product ) collection <multi-model> ;
M: collection (model-changed)
    nip
    dup dependencies>> [ value>> ] all?
    [ dup [ value>> ] product-value swap set-model ]
    [ drop ] if ;
M: collection model-activated dup (model-changed) ;

! for side effects
TUPLE: (when-model) < multi-model quot cond ;
: when-model ( model quot cond -- model ) rot 1array (when-model) <multi-model> swap >>cond swap >>quot ;
M: (when-model) (model-changed) [ quot>> ] 2keep
    [ value>> ] [ cond>> ] bi* call( a -- ? ) [ call( model -- ) ] [ 2drop ] if ;

! only used in construction
: with-self ( quot -- model ) [ f <basic> dup ] dip call swap [ add-dependency ] keep ; inline

USE: models.combinators.templates
<< { "$>" "<$" "fmap" } [ fmaps ] each >>
