USING: accessors assocs arrays kernel models monads sequences
models.combinators ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.buttons.private ui.gadgets.editors ui.gadgets.editors.private
words images.loader ui.gadgets.scrollers ui.images vocabs.parser lexer
models.range ui.gadgets.sliders ;
QUALIFIED-WITH: ui.gadgets.sliders slider
QUALIFIED-WITH: ui.gadgets.tables tbl
EXCLUDE: ui.gadgets.editors => model-field ;
IN: ui.gadgets.controls

TUPLE: model-btn < button hook value ;
: <model-btn> ( gadget -- button ) [
      [ dup hook>> [ call( button -- ) ] [ drop ] if* ]
      [ [ [ value>> ] [ ] bi or ] keep set-control-value ]
      [ model>> f swap value<< ] tri
   ] model-btn new-button f <basic> >>model ;
: <model-border-btn> ( text -- button ) <model-btn> border-button-theme ;

TUPLE: table < tbl:table { quot initial: [ ] } { val-quot initial: [ ] } color-quot column-titles column-alignment actions ;
M: table tbl:column-titles column-titles>> ;
M: table tbl:column-alignment column-alignment>> ;
M: table tbl:row-columns quot>> [ call( a -- b ) ] [ drop f ] if* ;
M: table tbl:row-value val-quot>> [ call( a -- b ) ]  [ drop f ] if* ;
M: table tbl:row-color color-quot>> [ call( a -- b ) ]  [ drop f ] if* ;

: new-table ( model class -- table ) f swap tbl:new-table dup >>renderer
   f <basic> >>actions dup actions>> [ set-model ] curry >>action ;
: <table> ( model -- table ) table new-table ;
: <table*> ( -- table ) V{ } clone <model> <table> ;
: <list> ( column-model -- table ) <table> [ 1array ] >>quot ;
: <list*> ( -- table ) V{ } clone <model> <list> ;
: indexed ( table -- table ) f >>val-quot ;

TUPLE: model-field < field model* ;
: init-field ( model -- model' ) [ [ ] [ "" ] if* ] change-value ;
: <model-field> ( model -- gadget ) model-field new-field swap init-field >>model* ;
M: model-field graft*
    [ [ model*>> value>> ] [ editor>> ] bi set-editor-string ]
    [ dup editor>> model>> add-connection ]
    [ dup model*>> add-connection ] tri ;
M: model-field ungraft*
   [ dup editor>> model>> remove-connection ]
   [ dup model*>> remove-connection ] bi ;
M: model-field model-changed 2dup model*>> =
    [ [ value>> ] [ editor>> ] bi* set-editor-string ]
    [ nip [ editor>> editor-string ] [ model*>> ] bi set-model ] if ;
 
: (new-field) ( editor field -- gadget ) [ new-editor ] dip new-border dup gadget-child >>editor
    field-theme { 1 0 } >>align ; inline
: <model-field*> ( -- field ) "" <model> <model-field> ;
: <empty-field> ( model -- field ) "" <model> switch-models <model-field> ;
: <model-editor> ( model -- gadget ) multiline-editor model-field (new-field) swap init-field >>model* ;
: <model-editor*> ( -- editor ) "" <model> <model-editor> ;
: <empty-editor> ( model -- editor ) "" <model> switch-models <model-editor> ;

: <model-action-field> ( -- field ) f <action-field> dup [ set-control-value ] curry >>quot
    f <model> >>model ;

: <slider> ( init page min max step -- slider ) <range> horizontal slider:<slider> ;

: image-prep ( -- image ) scan current-vocab name>> "vocab:" "/icons/" surround ".tiff" surround <image-name> dup cached-image drop ;
SYNTAX: IMG-MODEL-BTN: image-prep [ <model-btn> ] curry append! ;

SYNTAX: IMG-BTN: image-prep [ swap <button> ] curry append! ;

GENERIC: output-model ( gadget -- model )
M: gadget output-model model>> ;
M: table output-model dup val-quot>> [ selection>> ] [ selection-index>> ] if ;
M: model-field output-model model*>> ;
M: scroller output-model viewport>> children>> first output-model ;
M: slider output-model model>> range-model ;

IN: accessors
M: model-btn text>> children>> first text>> ;

IN: ui.gadgets.controls

SINGLETON: gadget-monad
INSTANCE: gadget-monad monad
INSTANCE: gadget monad
M: gadget monad-of drop gadget-monad ;
M: gadget-monad return drop <gadget> swap >>model ;
M: gadget >>= output-model [ swap call( x -- y ) ] curry ; 
