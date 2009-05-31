USING: accessors fry kernel lexer math.parser models
sequences ui.gadgets.tracks ui.gadgets models.product
ui.frp.gadgets ui.gadgets.books ;
QUALIFIED: make
IN: ui.frp.layout
TUPLE: layout gadget width ; C: <layout> layout

GENERIC: , ( uiitem -- )
M: gadget , f <layout> make:, ;
M: model , make:, ;

SYNTAX: ,% scan string>number [ <layout> make:, ] curry over push-all ;
SYNTAX: ->% scan string>number '[ [ _ <layout> make:, ] [ output-model ] bi ] over push-all ;

GENERIC: -> ( uiitem -- model )
M: gadget -> dup , output-model ;
M: model -> dup , ;

: <spacer> ( -- ) <gadget> 1 <layout> make:, ;
: <box> ( gadgets type -- track )
   [ { } make:make dup [ layout? ] filter ] dip <track> swap [ [ gadget>> ] [ width>> ] bi track-add ] each
   swap [ model? ] filter [ <product> >>model ] unless-empty ; inline
: <hbox> ( gadgets -- track ) horizontal <box> ; inline
: <vbox> ( gadgets -- track ) vertical <box> ; inline

: <frp-book> ( gadgets -- book ) { } make:make [ gadget>> ] map f <book> ; inline