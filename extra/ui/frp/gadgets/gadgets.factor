USING: accessors assocs arrays kernel models monads sequences
ui.frp.signals ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.buttons.private ui.gadgets.editors words images.loader
ui.gadgets.scrollers ui.gadgets.tables ui.images vocabs.parser lexer
models.range ui.gadgets.sliders ;
IN: ui.frp.gadgets

TUPLE: frp-button < button hook value ;
: <frp-button> ( gadget -- button ) [
      [ dup hook>> [ call( button -- ) ] [ drop ] if* ]
      [ [ [ value>> ] [ ] bi or ] keep set-control-value ]
      [ model>> f swap (>>value) ] tri
   ] frp-button new-button f <basic> >>model ;
: <frp-border-button> ( text -- button ) <frp-button> border-button-theme ;

TUPLE: frp-table < table { quot initial: [ ] } { val-quot initial: [ ] } color-quot column-titles column-alignment actions ;
M: frp-table column-titles column-titles>> ;
M: frp-table column-alignment column-alignment>> ;
M: frp-table row-columns quot>> [ call( a -- b ) ] [ drop f ] if* ;
M: frp-table row-value val-quot>> [ call( a -- b ) ]  [ drop f ] if* ;
M: frp-table row-color color-quot>> [ call( a -- b ) ]  [ drop f ] if* ;

: new-frp-table ( model class -- table ) f swap new-table dup >>renderer
   V{ } clone <basic> >>selected-values V{ } clone <basic> >>selected-indices*
   f <basic> >>actions dup [ actions>> set-model ] curry >>action ;
: <frp-table> ( model -- table ) frp-table new-frp-table ;
: <frp-table*> ( -- table ) V{ } clone <model> <frp-table> ;
: <frp-list> ( column-model -- table ) <frp-table> [ 1array ] >>quot ;
: <frp-list*> ( -- table ) V{ } clone <model> <frp-list> ;
: indexed ( table -- table ) f >>val-quot ;

TUPLE: frp-field < field frp-model ;
: init-field ( field -- field' ) [ [ ] [ "" ] if* ] change-value ;
: <frp-field> ( model -- gadget ) frp-field new-field swap init-field >>frp-model ;
M: frp-field graft*
    [ [ frp-model>> value>> ] [ editor>> ] bi set-editor-string ]
    [ dup editor>> model>> add-connection ]
    [ dup frp-model>> add-connection ] tri ;
M: frp-field ungraft*
   [ dup editor>> model>> remove-connection ]
   [ dup frp-model>> remove-connection ] bi ;
M: frp-field model-changed 2dup frp-model>> =
    [ [ value>> ] [ editor>> ] bi* set-editor-string ]
    [ nip [ editor>> editor-string ] [ frp-model>> ] bi set-model ] if ;

: <frp-field*> ( -- field ) "" <model> <frp-field> ;
: <empty-field> ( model -- field ) "" <model> <switch> <frp-field> ;
: <frp-editor> ( model -- gadget )
    frp-field [ <multiline-editor> ] dip new-border dup gadget-child >>editor
    field-theme swap init-field >>frp-model { 1 0 } >>align ;
: <frp-editor*> ( -- editor ) "" <model> <frp-editor> ;
: <empty-editor> ( model -- editor ) "" <model> <switch> <frp-editor> ;

: <frp-action-field> ( -- field ) f <action-field> dup [ set-control-value ] curry >>quot
    f <model> >>model ;

: <frp-slider> ( init page min max step -- slider ) <range> horizontal <slider> ;

: image-prep ( -- image ) scan current-vocab name>> "vocab:" "/icons/" surround ".tiff" surround <image-name> dup cached-image drop ;
SYNTAX: IMG-FRP-BTN: image-prep [ <frp-button> ] curry over push-all ;

SYNTAX: IMG-BTN: image-prep [ swap <button> ] curry over push-all ;

GENERIC: output-model ( gadget -- model )
M: gadget output-model model>> ;
M: table output-model dup multiple-selection?>>
   [ dup val-quot>> [ selected-values>> ] [ selected-indices*>> ] if ]
   [ dup val-quot>> [ selected-value>> ] [ selected-index*>> ] if ] if ;
M: frp-field output-model frp-model>> ;
M: scroller output-model viewport>> children>> first output-model ;
M: slider output-model model>> range-model ;

IN: accessors
M: frp-button text>> children>> first text>> ;

IN: ui.frp.gadgets

SINGLETON: gadget-monad
INSTANCE: gadget-monad monad
INSTANCE: gadget monad
M: gadget monad-of drop gadget-monad ;
M: gadget-monad return drop <gadget> swap >>model ;
M: gadget >>= output-model [ swap call( x -- y ) ] curry ; 