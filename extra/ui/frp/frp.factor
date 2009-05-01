USING: accessors arrays colors fonts fry kernel models
models.product monads sequences ui.gadgets ui.gadgets.buttons
ui.gadgets.editors ui.gadgets.line-support ui.gadgets.tables
ui.gadgets.tracks ui.render ;
QUALIFIED: make
IN: ui.frp

! Gadgets
: <frp-button> ( text -- button ) [ t swap set-control-value ] <border-button> f <model> >>model ;
TUPLE: frp-table < table quot val-quot color-quot column-titles column-alignment ;
M: frp-table column-titles column-titles>> ;
M: frp-table column-alignment column-alignment>> ;
M: frp-table row-columns quot>> [ call( a -- b ) ] [ drop f ] if* ;
M: frp-table row-value val-quot>> [ call( a -- b ) ]  [ drop f ] if* ;
M: frp-table row-color color-quot>> [ call( a -- b ) ]  [ drop f ] if* ;

: <frp-table> ( model -- table )
    frp-table new-line-gadget dup >>renderer [ ] >>quot swap >>model
    f <model> >>selected-value sans-serif-font >>font
    focus-border-color >>focus-border-color
    transparent >>column-line-color ;
: <frp-list> ( model -- table ) <frp-table> [ 1array ] >>quot ;
: <frp-field> ( -- field ) f <model> <model-field> ;

! Layout utilities

GENERIC: output-model ( gadget -- model )
M: gadget output-model model>> ;
M: frp-table output-model selected-value>> ;

GENERIC: , ( uiitem -- )
M: gadget , make:, ;
M: model , activate-model ;

GENERIC: -> ( uiitem -- model )
M: gadget -> dup make:, output-model ;
M: model -> dup , ;
M: table -> dup , selected-value>> ;

: <box> ( gadgets type -- track )
   [ { } make:make ] dip <track> swap [ f track-add ] each ; inline
: <box*> ( gadgets type -- track ) [ <box> ] [ [ model>> ] map <product> ] bi >>model ; inline
: <hbox> ( gadgets -- track ) horizontal <box> ; inline
: <vbox> ( gadgets -- track ) vertical <box> ; inline

! Model utilities
TUPLE: multi-model < model ;
! M: multi-model model-activated dup model-changed ;
: <multi-model> ( models kind -- model ) f swap new-model [ [ add-dependency ] curry each ] keep ;

TUPLE: merge-model < multi-model ;
M: merge-model model-changed [ value>> ] dip set-model ;
: <merge> ( models -- model ) merge-model <multi-model> ;

TUPLE: filter-model < multi-model quot ;
M: filter-model model-changed [ value>> ] dip [ quot>> call( val -- bool ) ] 2keep
   [ set-model ] [ 2drop ] if ;
: <filter> ( model quot -- filter-model ) [ 1array filter-model <multi-model> ] dip >>quot ;

TUPLE: fold-model < multi-model oldval quot ;
M: fold-model model-changed [ [ value>> ] [ [ oldval>> ] [ quot>> ] bi ] bi*
   call( val oldval -- newval ) ] keep set-model ;
: <fold> ( oldval quot model -- model' ) 1array fold-model <multi-model> swap >>quot swap >>oldval ;

TUPLE: switch-model < multi-model switcher on ;
M: switch-model model-changed tuck [ switcher>> = ] 2keep
   '[ on>> [ _ value>> _ set-model ] when ] [ t swap (>>on) ] if ;
: switch ( signal1 signal2 -- signal' ) [ 2array switch-model <multi-model> ] keep >>switcher ;

TUPLE: mapped < model model quot ;

: <mapped> ( model quot -- arrow )
    f mapped new-model
        swap >>quot
        over >>model
        [ add-dependency ] keep ;

M: mapped model-changed
    [ [ value>> ] [ quot>> ] bi* call( old -- new ) ] [ nip ] 2bi
    set-model ;

! Instances
M: model fmap <mapped> ;

SINGLETON: gadget-monad
INSTANCE: gadget-monad monad
INSTANCE: gadget monad
M: gadget monad-of drop gadget-monad ;
M: gadget-monad return drop <gadget> swap >>model ;
M: gadget >>= model>> '[ _ swap call( x -- y ) ] ; 