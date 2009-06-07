USING: accessors assocs arrays fry kernel lexer make math math.parser
models models.product namespaces parser sequences
ui.frp.gadgets ui.gadgets ui.gadgets.books ui.gadgets.tracks
words tools.continuations ;
IN: ui.frp.layout

TUPLE: layout gadget size ; C: <layout> layout
ERROR: no-models models ;

SYNTAX: ,% scan string>number [ <layout> , ] curry over push-all ;
SYNTAX: ->% scan string>number '[ [ _ <layout> , ] [ output-model ] bi ] over push-all ;

GENERIC: -> ( uiitem -- model )
M: gadget -> dup , output-model ;
M: model -> dup , ;

: <spacer> ( -- ) <gadget> 1 <layout> , ;

SYMBOL: wordnames
: insert-layout ( track layout -- track ) [ gadget>> ] [ size>> ] bi track-add ; inline
: layouts ( sized? gadgets -- layouts ) [ [ gadget? ] [ layout? ] bi or ] filter swap
   [ [ dup layout? [ f <layout> ] unless ] map ] when ;
: make-layout ( building sized? -- models words layouts ) [ swap layouts ] curry
   [ { } make [ [ model? ] filter ] [ [ word? ] filter ] ] dip tri ; inline
: handle-words ( words gadget -- gadget ) tuck
   [ [ swap 2array ] curry wordnames get swap change-at ] curry each ;
: <box> ( gadgets type -- track )
   [ t make-layout ] dip <track>
   swap [ insert-layout ] each
   handle-words
   swap [ <product> >>model ] unless-empty ; inline
: <hbox> ( gadgets -- track ) horizontal <box> ; inline
: <vbox> ( gadgets -- track ) vertical <box> ; inline

: <frp-book> ( quot: ( -- model ) -- book ) f make-layout roll dup activate-model <book> handle-words
   swap [ no-models ] unless-empty ; inline

SYNTAX: $ CREATE-WORD dup [ , ] curry (( -- )) define-declared "$" expect
   word [ [ building get length swap wordnames get set-at ] [ , ] bi ] curry over push-all ;

: insert-gadget ( number parent gadget -- ) -rot [ but-last insert-nth ] change-children drop ;

GENERIC# insert-item 1 ( item location -- )
M: gadget insert-item dup first book? [ first2 spin [ add-gadget ] keep insert-gadget ]
   [ [ f <layout> ] dip insert-item ] if ;
M: layout insert-item first2 spin [ insert-layout ] keep gadget>> insert-gadget ;
M: model insert-item dup first book? [ no-models ]
   [ first model>> swap add-connection ] if ;

: insert-items ( makelist -- ) f swap [ dup word?
   [ nip ] [
      over [ wordnames get at insert-item ] [ wordnames get [ first2 1 + 2array ] change-at ] bi
   ] if ] each drop ;

: with-interface ( quot: ( -- gadget ) -- gadget ) H{ } clone wordnames
   [ { } make insert-items ] with-variable ; inline
