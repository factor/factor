
USING: kernel io parser words namespaces quotations arrays assocs sequences
       splitting math shuffle ;

IN: mortar

! class { name slots methods class-methods }

: class-name ( class -- name ) dup symbol? [ get ] when first ;

: class-slots ( class -- slots ) dup symbol? [ get ] when second ;

: class-methods ( class -- methods ) dup symbol? [ get ] when third ;

: class-class-methods ( class -- methods ) dup symbol? [ get ] when fourth ;

: class? ( thing -- ? )
dup array?
[ dup length 4 = [ first symbol? ] [ drop f ] if ]
[ drop f ]
if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: add-method ( class name quot -- )
rot get class-methods peek swapd set-at ;

: add-class-method ( class name quot -- )
rot get class-class-methods peek swapd set-at ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! object { class values }

: object-class ( object -- class ) first ;

: object-values ( object -- values ) second ;

: object? ( thing -- ? )
dup array?
[ dup length 2 = [ first class? ] [ drop f ] if ]
[ drop f ]
if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: is? ( object class -- ? ) swap object-class class-name = ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: inference.transforms

! : narray ( n -- array ) [ drop ] map reverse ;

: [narray] ( n -- quot ) [ [ drop ] map reverse ] curry ;

: narray ( n -- array ) [narray] call ;

\ narray [ [narray] ] 1 define-transform

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: new ( class -- object )
get dup >r class-slots length narray r> swap 2array ;

: new-empty ( class -- object )
get dup >r class-slots length f <array> r> swap 2array ;

! : new* ( class -- object ) new-empty <- init ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: slot-value ( object slot -- value )
over object-class class-slots index swap object-values nth ;

: set-slot-value ( object slot value -- object )
swap pick object-class class-slots index pick object-values set-nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : send-message ( object message -- )
! over object-class class-methods assoc-stack call ;

: send-message ( object message -- )
2dup swap object-class class-methods assoc-stack dup
[ nip call ]
! [ drop nip "message not understood: " write print flush ]
[ drop "message not understood: " write print drop ]
if ;

: <- scan parsed \ send-message parsed ; parsing

! : send-message* ( message n -- )
! 1+ npick object-class class-methods assoc-stack call ;

: send-message* ( message n -- )
1+ npick dupd object-class class-methods assoc-stack dup
[ nip call ]
[ drop "message not understood: " write print flush ]
if ;

: <--   scan parsed 2 parsed \ send-message* parsed ; parsing

: <---  scan parsed 3 parsed \ send-message* parsed ; parsing

: <---- scan parsed 4 parsed \ send-message* parsed ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: send-message-to-class ( class message -- )
over class-class-methods assoc-stack call ;

: <<- scan parsed \ send-message-to-class parsed ; parsing

: send-message-to-class* ( message n -- )
1+ npick class-class-methods assoc-stack call ;

: <<-- scan parsed 2 parsed \ send-message-to-class* parsed ; parsing

: <<--- scan parsed 3 parsed \ send-message-to-class* parsed ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: send-message-next ( object message -- )
over object-class class-methods 1 head* assoc-stack call ;

: <-~ scan parsed \ send-message-next parsed ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: new* ( class -- object ) <<- create ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

IN: slot-accessors

IN: mortar

: generate-slot-getter ( name -- )
"$" over append "slot-accessors" create swap [ slot-value ] curry
define-compound ;

: generate-slot-setter ( name -- )
">>" over append "slot-accessors" create swap [ swap set-slot-value ] curry
define-compound ;

: generate-slot-accessors ( name -- )
dup
generate-slot-getter
generate-slot-setter ;

: accessors ( seq -- seq ) dup peek [ generate-slot-accessors ] each ; parsing

! : slots:
! ";" parse-tokens dup [ generate-slot-accessors ] each parsed ; parsing

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : <symbol> ( string -- symbol ) in get create dup define-symbol ;

: empty-method-table ( -- array ) H{ } clone 1array ;

! : define-simple-class ( name parent slots -- )
! >r >r <symbol>
! r> dup class-slots r> append
! swap dup class-methods empty-method-table append
! swap class-class-methods empty-method-table append
! 4array dup first set-global ;

: define-simple-class ( name parent slots -- )
>r dup class-slots r> append
swap dup class-methods empty-method-table append
swap class-class-methods empty-method-table append
4array dup first set-global ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: define-independent-class ( name slots -- )
empty-method-table empty-method-table 4array dup first set-global ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: add-methods ( class seq -- ) 2 group [ first2 add-method ] curry* each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: !( ")" parse-tokens drop ; parsing