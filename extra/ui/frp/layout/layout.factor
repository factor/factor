USING: accessors assocs arrays fry kernel lexer make math math.parser
models models.product namespaces parser sequences
ui.frp.gadgets ui.gadgets ui.gadgets.books ui.gadgets.tracks
words tools.continuations ;
IN: ui.frp.layout

TUPLE: layout gadget size ; C: <layout> layout

SYNTAX: ,% scan string>number [ <layout> , ] curry over push-all ;
SYNTAX: ->% scan string>number '[ [ _ <layout> , ] [ output-model ] bi ] over push-all ;

GENERIC: -> ( uiitem -- model )
M: gadget -> dup , output-model ;
M: model -> dup , ;

: <spacer> ( -- ) <gadget> 1 <layout> , ;

SYMBOL: wordnames
: layouts ( gadgets -- layouts ) [ [ gadget? ] [ layout? ] bi or ] filter
   [ dup layout? [ f <layout> ] unless ] map ;
: <box> ( gadgets type -- track )
   [ { } make [ [ model? ] filter ] [ [ word? ] filter ] [ layouts ] tri ] dip <track>
   swap [ [ gadget>> ] [ size>> ] bi track-add ] each
   tuck [ [ swap 2array ] curry wordnames get swap change-at ] curry each
   swap [ <product> >>model ] unless-empty ; inline
: <hbox> ( gadgets -- track ) horizontal <box> ; inline
: <vbox> ( gadgets -- track ) vertical <box> ; inline

: <frp-book> ( gadgets -- book ) { } make [ gadget>> ] map f <book> ; inline

SYNTAX: $ CREATE-WORD dup [ , ] curry (( -- )) define-declared "$" expect
   word [ [ building get length swap wordnames get set-at ] [ , ] bi ] curry over push-all ;

GENERIC# insert-item 1 ( item location -- )
M: gadget insert-item [ f <layout> ] dip insert-item ;
M: layout insert-item first2 spin [ [ gadget>> ] [ size>> ] bi track-add ] keep gadget>> 
   -rot [ but-last insert-nth ] change-children drop ;
M: model insert-item first model>> swap add-connection ;

: insert-items ( makelist -- ) f swap [ dup word?
      [ nip ] [ over [ wordnames get at insert-item ] [ wordnames get [ first2 1 + 2array ] change-at ] bi ] if
   ] each drop ;

: with-interface ( quot: ( -- gadget ) -- gadget ) H{ } clone wordnames
   [ { } make insert-items ] with-variable ; inline
