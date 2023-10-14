USING: accessors assocs arrays fry kernel lexer make math.parser
models monads namespaces parser sequences
sequences.extras models.combinators ui.gadgets
ui.gadgets.tracks words ui.gadgets.controls ;
QUALIFIED: make
QUALIFIED-WITH: ui.gadgets.books book
IN: ui.gadgets.layout

SYMBOL: templates
TUPLE: layout gadget size ; C: <layout> layout
TUPLE: placeholder < gadget members ;
: <placeholder> ( -- placeholder ) placeholder new V{ } clone >>members ;

: (remove-members) ( placeholder members -- ) [ [ model? ] filter swap parent>> model>> [ remove-connection ] curry each ]
    [ nip [ gadget? ] filter [ unparent ] each ] 2bi ;

: remove-members ( placeholder -- ) dup members>> [ drop ] [ [ (remove-members) ] keep delete-all ] if-empty ;
: add-member ( obj placeholder -- ) over layout? [ [ gadget>> ] dip ] when members>> push ;

: , ( item -- ) make:, ;
: make* ( quot -- list ) { } make ; inline

! Just take the previous mentioned placeholder and use it
! If there is no previously mentioned placeholder, we're probably making a box, and will create the placeholder ourselves
DEFER: with-interface
: insertion-quot ( quot -- quot' )
    make:building get [ [ placeholder? ] find-last nip [ <placeholder> dup , ] unless*
    [ templates get ] 2dip swap '[ [ _ templates set _ , @ ] with-interface ] ] when* ;

SYNTAX: ,% scan-token string>number [ <layout> , ] curry append! ;
SYNTAX: ->% scan-token string>number '[ [ _ <layout> , ] [ output-model ] bi ] append! ;

GENERIC: -> ( uiitem -- model )
M: gadget -> dup , output-model ;
M: model -> dup , ;

: <spacer> ( -- ) <gadget> 1 <layout> , ;

: add-layout ( track layout -- track ) [ gadget>> ] [ size>> ] bi track-add ;
: layouts ( sized? gadgets -- layouts ) [ [ gadget? ] [ layout? ] bi or ] filter swap
   [ [ dup layout? [ f <layout> ] unless ] map ]
   [ [ dup gadget? [ gadget>> ] unless ] map ] if ;
: make-layout ( building sized? -- models layouts ) [ swap layouts ] curry
   [ make* [ [ model? ] filter ] ] dip bi ; inline
: <box> ( gadgets type -- track )
   [ t make-layout ] dip <track>
   swap [ add-layout ] each
   swap [ <collection> >>model ] unless-empty ; inline
: <hbox> ( gadgets -- track ) horizontal <box> ; inline
: <vbox> ( gadgets -- track ) vertical <box> ; inline

: make-book ( models gadgets model -- book ) book:<book> swap [ "No models in books" throw ] unless-empty ;
: <book> ( quot: ( -- model ) -- book ) f make-layout rot 0 >>value make-book ; inline
: <book*> ( quot -- book ) f make-layout f make-book ; inline

ERROR: not-in-template word ;
SYNTAX: $ scan-new-word dup
    [ [ dup templates get at [ nip , ] [ not-in-template ] if* ] curry ( -- ) define-declared "$" expect ]
    [ [ <placeholder> [ swap templates get set-at ] keep , ] curry ] bi append! ;

: insert-gadget ( number parent gadget -- ) -rot [ but-last insert-nth ] change-children drop ;
: insert-size ( number parent size -- ) -rot [ but-last insert-nth ] change-sizes drop ;
: insertion-point ( placeholder -- number parent ) dup parent>> [ children>> index ] keep ;

GENERIC: >layout ( gadget -- layout )
M: gadget >layout f <layout> ;
M: layout >layout ;

GENERIC#: (add-gadget-at) 2 ( parent item n -- )
M: gadget (add-gadget-at) -rot [ add-gadget ] keep insert-gadget ;
M: track (add-gadget-at) -rot >layout [ add-layout ] keep [ gadget>> insert-gadget ] [ size>> insert-size ] 3bi ;

GENERIC#: add-gadget-at 1 ( item location -- )
M: object add-gadget-at insertion-point -rot (add-gadget-at) ;
M: model add-gadget-at parent>> dup book:book? [ "No models in books" throw ]
   [ dup model>> dup collection? [ nip swap add-connection ] [ drop [ 1array <collection> ] dip model<< ] if ] if ;
: track-add-at ( item location size -- ) swap [ <layout> ] dip add-gadget-at ;
: (track-add-at) ( parent item n size -- ) swap [ <layout> ] dip (add-gadget-at) ;

: insert-item ( item location -- ) [ dup get [ drop ] [ remove-members ] if ] [ on ] [ ] tri
    [ add-member ] 2keep add-gadget-at ;

: insert-items ( makelist -- ) t swap [ dup placeholder? [ nip ] [ over insert-item ] if ] each drop ;

: with-interface ( quot -- ) [ make* ] curry H{ } clone templates rot with-variable [ insert-items ] with-scope ; inline

M: model >>= [ swap insertion-quot <action> ] curry ;
M: model fmap insertion-quot <mapped> ;
M: model $> insertion-quot side-effect-model new-mapped-model ;
M: model <$ insertion-quot quot-model new-mapped-model ;
