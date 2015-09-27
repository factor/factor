USING: accessors kernel fry math models ui.gadgets ui.gadgets.books ui.gadgets.buttons ;
FROM: models => change-model ;
IN: ui.gadgets.book-extras
: <book*> ( pages -- book ) 0 <model> <book> ;
: |<< ( book -- ) 0 swap set-control-value ;
: next ( book -- ) model>> [ 1 + ] change-model ;
: prev ( book -- ) model>> [ 1 - ] change-model ;
: owner ( gadget -- book ) parent>> dup book? [ owner ] unless ;
: (book-t) ( quot -- quot ) '[ owner @ ] ;
: <book-btn> ( label quot -- button ) (book-t) <button> ;
: <book-border-btn> ( label quot -- button ) (book-t) <border-button> ;
: >>> ( gadget -- ) owner next ;
: <<< ( gadget -- ) owner prev ;
: go-to ( gadget number -- ) swap owner set-control-value ;

: <forward-btn> ( label -- button ) [ >>> ] <button> ;
: <backward-btn> ( label -- button ) [ <<< ] <button> ;
