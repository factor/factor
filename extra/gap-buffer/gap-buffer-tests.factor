USING: kernel sequences tools.test gap-buffer strings math ;

! test copy-elements
{ { 0 3 4 3 4 5 } }
[ { 0 1 2 3 4 5 } dup [ -2 3 5 ] dip copy-elements ] unit-test

{ { 0 1 2 1 2 5 } }
[ { 0 1 2 3 4 5 } dup [ 2 2 0 ] dip copy-elements ] unit-test

{ "01234567856" }
[ "01234567890" dup [ 4 6 4 ] dip copy-elements ] unit-test

! test sequence protocol (like, length, nth, set-nth)
{ "gap buffers are cool" }
[ "gap buffers are cool" <gb> "" like ] unit-test

! test move-gap-back-inside
{ t f }
[ 5 "0123456" <gb> move-gap-forward? [ move-gap-back-inside? 2nip ] dip ] unit-test

{ "0123456" }
[ "0123456" <gb> 5 over move-gap >string ] unit-test

! test move-gap-forward-inside
{ t }
[ "I once ate a spaniel" <gb> 15 over move-gap 17 swap move-gap-forward-inside? 2nip ] unit-test

{ "I once ate a spaniel" }
[ "I once ate a spaniel" <gb> 15 over move-gap 17 over move-gap >string ] unit-test

! test move-gap-back-around
{ f f }
[ 2 "terriers are ok too" <gb> move-gap-forward? [ move-gap-back-inside? 2nip ] dip ] unit-test

{ "terriers are ok too" }
[ "terriers are ok too" <gb> 2 over move-gap >string ] unit-test

! test move-gap-forward-around
{ f t }
[
    "god is nam's best friend" <gb>
    2 over move-gap 22 over position>index swap move-gap-forward?
    [ move-gap-forward-inside? 2nip ] dip
] unit-test

{ "god is nam's best friend" }
[ "god is nam's best friend" <gb> 2 over move-gap 22 over move-gap >string ] unit-test

! test changing buffer contents
{ "factory" }
[ "factor" <gb> CHAR: y 6 pick insert* >string ] unit-test

! test inserting multiple elements in different places. buffer should grow
{ "refractory" }
[ "factor" <gb> CHAR: y 6 pick insert* "re" 0 pick insert* CHAR: r 3 pick insert* >string ] unit-test

! test deleting elements. buffer should shrink
{ "for" }
[ "factor" <gb> 3 [ 1 over delete* ] times >string ] unit-test

! more testing of nth and set-nth
{ "raptor" }
[ "factor" <gb> CHAR: p 2 pick set-nth 5 over nth 0 pick set-nth >string ] unit-test

! test stack/queue operations
{ "slaughter" }
[ "laughter" <gb> CHAR: s over push-start >string ] unit-test

{ "pantonio" }
[ "pant" <gb> "onio" over push-end >string ] unit-test

{ CHAR: f "actor" }
[ "factor" <gb> dup pop-start swap >string ] unit-test

{ CHAR: s "pant" }
[ "pants" <gb> dup pop-end swap >string ] unit-test

{ "end this is the " }
[ "this is the end " <gb> 4 over rotate >string ] unit-test

{ "your jedi training is finished " }
[ "finished your jedi training is " <gb> -9 over rotate >string ] unit-test
