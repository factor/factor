USING: accessors kernel fry math models ui.gadgets ui.gadgets.books ui.gadgets.buttons ;
FROM: models => change-model ;
IN: ui.gadgets.book-extras
: <book*> ( pages -- book ) 0 <model> <book> ;
: |<< ( book -- ) 0 swap set-control-value ;
: next ( book -- ) model>> [ 1 + ] change-model ;
: prev ( book -- ) model>> [ 1 - ] change-model ;
: (book-t) ( quot -- quot ) '[ : owner ( gadget -- book ) parent>> dup book? [ owner ] unless ; owner @ ] ;
: <book-btn> ( label quot -- button ) (book-t) <button> ;
: <book-bevel-btn> ( label quot -- button ) (book-t) <border-button> ;
: >>> ( label -- button ) [ next ] <book-btn> ;
: <<< ( label -- button ) [ prev ] <book-btn> ;