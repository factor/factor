USING: accessors arrays fry kernel models models.product
monads sequences ui.gadgets ui.gadgets.buttons ui.gadgets.tracks
ui.gadgets.tables ;
QUALIFIED: make
IN: ui.frp

! Layout utilities

GENERIC: , ( object -- )
M: gadget , make:, ;
M: model , activate-model ;

GENERIC: -> ( object -- model )
M: gadget -> dup make:, model>> ;
M: model -> dup , ;

: <box> ( models type -- track )
   [ { } make:make ] dip <track> swap dup [ model>> ] map <product>
   [ [ f track-add ] each ] dip >>model ; inline
: <hbox> ( models -- track ) horizontal <box> ; inline
: <vbox> ( models -- track ) vertical <box> ; inline

! Gadgets
: <frp-button> ( text -- button ) [ t swap set-control-value ] <bevel-button> f <model> >>model ;
TUPLE: frp-table < table quot ;
M: frp-table row-columns quot>> call( a -- b ) ;
: <frp-table> ( model quot -- table )
    frp-table new-line-gadget dup >>renderer swap >>quot swap >>model
    f <model> >>selected-value sans-serif-font >>font
    focus-border-color >>focus-border-color
    transparent >>column-line-color ;

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
 
! ! list (model = Columns), listContent (model = contents)

