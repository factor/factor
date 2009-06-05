USING: accessors assocs arrays fry kernel lexer make math math.parser
models models.product namespaces parser sequences
ui.frp.gadgets ui.gadgets ui.gadgets.books ui.gadgets.tracks
words tools.continuations ;
IN: ui.frp.layout

: <layout> ( gadget width -- gadget ) over set ;

SYNTAX: ,% scan string>number [ <layout> , ] curry over push-all ;
SYNTAX: ->% scan string>number '[ [ _ <layout> , ] [ output-model ] bi ] over push-all ;

GENERIC: -> ( uiitem -- model )
M: gadget -> dup , output-model ;
M: model -> dup , ;

: <spacer> ( -- ) <gadget> 1 <layout> , ;

SYMBOL: wordnames

: <box> ( gadgets type -- track )
   [ { } make [ [ model? ] filter ] [ [ word? ] filter ] [ [ gadget? ] filter ] tri ] dip <track>
   swap [ dup get track-add ] each
   tuck [ [ swap 2array ] curry wordnames get swap change-at ] curry each
   swap [ <product> >>model ] unless-empty ; inline
: <hbox> ( gadgets -- track ) horizontal <box> ; inline
: <vbox> ( gadgets -- track ) vertical <box> ; inline

: <frp-book> ( gadgets -- book ) { } make [ gadget>> ] map f <book> ; inline

SYNTAX: $ CREATE-WORD dup [ , ] curry (( -- )) define-declared "$" expect
   word [ [ building get length swap wordnames get set-at ] [ , ] bi ] curry over push-all ;

GENERIC# insert-item 1 ( item location -- )
M: gadget insert-item first2 spin [ dup get track-add ] keep
   -rot [ but-last insert-nth ] change-children drop ;
M: model insert-item first model>> swap add-connection ;

: insert-items ( makelist -- ) f swap [ dup word?
      [ wordnames get at nip ] [ over insert-item ] if
   ] each drop ;

: with-interface ( quot: ( -- gadget ) -- gadget ) H{ } clone wordnames
   [ { } make insert-items ] with-variable ; inline