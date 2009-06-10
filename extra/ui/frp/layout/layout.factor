USING: accessors fry kernel lexer make math.parser models
models.product namespaces parser sequences ui.frp.gadgets
ui.gadgets ui.gadgets.books ui.gadgets.tracks vectors words ;
QUALIFIED: make
IN: ui.frp.layout

TUPLE: layout gadget size ; C: <layout> layout
TUPLE: placeholder < gadget ;
ERROR: no-models-in-books models ;

DEFER: insert-item
HOOK: , building ( uiitem -- )
M: vector , make:, ;
M: f , dup placeholder? [ building set ] [ "No location to add UI item" throw ] if ;
M: placeholder , [ building get insert-item ] keep relayout ;

SYNTAX: ,% scan string>number [ <layout> , ] curry over push-all ;
SYNTAX: ->% scan string>number '[ [ _ <layout> , ] [ output-model ] bi ] over push-all ;

GENERIC: -> ( uiitem -- model )
M: gadget -> dup , output-model ;
M: model -> dup , ;

: <spacer> ( -- ) <gadget> 1 <layout> , ;

: add-layout ( track layout -- track ) [ gadget>> ] [ size>> ] bi track-add ; inline
: layouts ( sized? gadgets -- layouts ) [ [ gadget? ] [ layout? ] bi or ] filter swap
   [ [ dup layout? [ f <layout> ] unless ] map ] when ;
: make-layout ( building sized? -- models layouts ) [ swap layouts ] curry
   [ { } make [ [ model? ] filter ] ] dip bi ; inline
: <box> ( gadgets type -- track )
   [ t make-layout ] dip <track>
   swap [ add-layout ] each
   swap [ <product> >>model ] unless-empty ; inline
: <hbox> ( gadgets -- track ) horizontal <box> ; inline
: <vbox> ( gadgets -- track ) vertical <box> ; inline

: make-book ( models gadgets model -- book ) <book> swap [ no-models-in-books ] unless-empty ;
: <frp-book> ( quot: ( -- model ) -- book ) f make-layout rot 0 >>value make-book ; inline
: <frp-book*> ( quot -- book ) f make-layout f make-book ; inline

SYNTAX: $ CREATE-WORD placeholder new
    [ [ , ] curry (( -- )) define-declared "$" expect ]
    [ [ , ] curry ] bi over push-all ;

: insert-gadget ( number parent gadget -- ) -rot [ but-last insert-nth ] change-children drop ;
: insert-size ( number parent size -- ) -rot [ but-last insert-nth ] change-sizes drop ;
: insertion-point ( gadget placeholder -- number parent gadget ) dup parent>> [ children>> index ] keep rot ;

GENERIC# insert-item 1 ( item location -- )
M: gadget insert-item dup parent>> track? [ [ f <layout> ] dip insert-item ]
    [ insertion-point [ add-gadget ] keep insert-gadget ] if ;
M: layout insert-item insertion-point [ add-layout ] keep [ gadget>> insert-gadget ] [ size>> insert-size ] 3bi ;
M: model insert-item dup first book? [ no-models-in-books ]
   [ first model>> swap add-connection ] if ;

: insert-items ( makelist -- ) f swap [ dup placeholder? [ nip ] [ over insert-item ] if ] each drop ;

: with-interface ( quot: ( -- gadget ) -- gadget ) { } make insert-items ; inline