USING: accessors fry kernel lexer math.parser models sequences
ui.frp.signals ui.gadgets ui.gadgets.editors ui.gadgets.scrollers
ui.gadgets.tables ui.gadgets.tracks ;
QUALIFIED: make
IN: ui.frp.layout
TUPLE: layout gadget width ; C: <layout> layout

GENERIC: output-model ( gadget -- model )
M: gadget output-model model>> ;
M: table output-model dup multiple-selection?>>
   [ dup val-quot>> [ selected-values>> ] [ selected-indices*>> ] if ]
   [ dup val-quot>> [ selected-value>> ] [ selected-index*>> ] if ] if ;
M: model-field output-model field-model>> ;
M: scroller output-model viewport>> children>> first output-model ;

GENERIC: , ( uiitem -- )
M: gadget , f <layout> make:, ;
M: model , activate-model ;

SYNTAX: ,% scan string>number [ <layout> make:, ] curry over push-all ;
SYNTAX: ->% scan string>number '[ [ _ <layout> make:, ] [ output-model ] bi ] over push-all ;

GENERIC: -> ( uiitem -- model )
M: gadget -> dup , output-model ;
M: model -> dup , ;

: <spacer> ( -- ) <gadget> 1 <layout> make:, ;
: <box> ( gadgets type -- track )
   [ { } make:make ] dip <track> swap [ [ gadget>> ] [ width>> ] bi track-add ] each ; inline
: <box*> ( gadgets type -- track ) [ <box> ] [ [ model>> ] map <|> ] bi >>model ; inline
: <hbox> ( gadgets -- track ) horizontal <box> ; inline
: <hbox*> ( gadgets -- track ) horizontal <box*> ; inline
: <vbox> ( gadgets -- track ) vertical <box> ; inline
: <vbox*> ( gadgets -- track ) vertical <box*> ; inline