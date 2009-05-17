USING: accessors arrays colors fonts fry kernel math models
models.product monads sequences ui.gadgets ui.gadgets.buttons
ui.gadgets.editors ui.gadgets.line-support ui.gadgets.tables
ui.gadgets.tracks ui.render ui.gadgets.scrollers
math.parser lexer ;
QUALIFIED: make
IN: ui.frp

! !!! Model utilities
TUPLE: multi-model < model ;
GENERIC: (model-changed) ( model observer -- )
: <multi-model> ( models kind -- model ) f swap new-model [ [ add-dependency ] curry each ] keep ;
M: multi-model model-changed over value>> [ (model-changed) ] [ 2drop ] if ;

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
 
: <mapped> ( model quot -- mapped )
    f mapped-model new-model
        swap >>quot
        over >>model
        [ add-dependency ] keep ;
M: mapped-model (model-changed)
    [ [ value>> ] [ quot>> ] bi* call( old -- new ) ] [ nip ] 2bi
    set-model ;
M: mapped-model model-activated [ model>> ] keep model-changed ;

TUPLE: frp-product < multi-model ;
: <frp-product> ( models -- product ) frp-product <multi-model> ;
M: frp-product model-changed
    nip
    dup dependencies>> [ value>> ] all?
    [ dup [ value>> ] product-value >>value notify-connections
    ] [ drop ] if ;
M: frp-product update-model
    dup value>> swap [ set-model ] set-product-value ;
M: frp-product model-activated dup model-changed ;

! Gadgets
: <frp-button> ( text -- button ) [ t swap set-control-value ] <border-button> f <basic> >>model ;
TUPLE: frp-table < table { quot initial: [ ] } { val-quot initial: [ ] } color-quot column-titles column-alignment ;
M: frp-table column-titles column-titles>> ;
M: frp-table column-alignment column-alignment>> ;
M: frp-table row-columns quot>> [ call( a -- b ) ] [ drop f ] if* ;
M: frp-table row-value val-quot>> [ call( a -- b ) ]  [ drop f ] if* ;
M: frp-table row-color color-quot>> [ call( a -- b ) ]  [ drop f ] if* ;

: <frp-table> ( model -- table ) f frp-table new-table dup >>renderer
   V{ } clone <basic> >>selected-values V{ } clone <basic> >>selected-indices* ;
: <frp-table*> ( -- table ) V{ } clone <model> <frp-table> ;
: <frp-list> ( model -- table ) <frp-table> [ 1array ] >>quot ;
: <frp-list*> ( -- table ) V{ } clone <model> <frp-list> ;
: indexed ( table -- table ) f >>val-quot ;

: <frp-field> ( -- field ) "" <model> <model-field> ;

! Layout utilities
TUPLE: layout gadget width ; C: <layout> layout

GENERIC: output-model ( gadget -- model )
M: gadget output-model model>> ;
M: table output-model dup multiple-selection?>>
   [ dup val-quot>> [ selected-values>> ] [ selected-indices*>> ] if ]
   [ dup val-quot>> [ selected-value>> ] [ selected-index*>> ] if ] if ;
M: model-field output-model field-model>> ;
M: scroller output-model viewport>> children>> first output-model ;

GENERIC: , ( uiitem -- )
M: gadget , f <layout> make:, ;
M: model , activate-model ;

SYNTAX: ,% scan string>number [ <layout> make:, ] curry over push-all ;
SYNTAX: ->% scan string>number '[ [ _ <layout> make:, ] [ output-model ] bi ] over push-all ;

GENERIC: -> ( uiitem -- model )
M: gadget -> dup , output-model ;
M: model -> dup , ;

: <spacer> ( -- ) <gadget> 1 <layout> make:, ;
: <box> ( gadgets type -- track )
   [ { } make:make ] dip <track> swap [ [ gadget>> ] [ width>> ] bi track-add ] each ; inline
: <box*> ( gadgets type -- track ) [ <box> ] [ [ model>> ] map <product> ] bi >>model ; inline
: <hbox> ( gadgets -- track ) horizontal <box> ; inline
: <hbox*> ( gadgets -- track ) horizontal <box*> ; inline
: <vbox> ( gadgets -- track ) vertical <box> ; inline
: <vbox*> ( gadgets -- track ) vertical <box*> ; inline

! Instances
M: model fmap <mapped> ;

SINGLETON: gadget-monad
INSTANCE: gadget-monad monad
INSTANCE: gadget monad
M: gadget monad-of drop gadget-monad ;
M: gadget-monad return drop <gadget> swap >>model ;
M: gadget >>= output-model [ swap call( x -- y ) ] curry ; 