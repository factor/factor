! Copyright (C) 2008 Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors boxes kernel namespaces ;
IN: hats

! Bullwinkle: Hey Rocky, watch me pull a rabbit out of my hat!
! Rocky: But that trick never works!
! Bullwinkle: This time for sure!

! hat protocol
MIXIN: hat

GENERIC: out ( hat -- object )
GENERIC: (in) ( object hat -- )

: in ( hat object -- hat ) over (in) ; inline
: empty-hat? ( hat -- ? ) out not ; inline
: empty-hat ( hat -- hat ) f in ; inline
: take ( hat -- object ) dup out f rot (in) ; inline
: change-hat ( hat quot -- hat )
    over >r >r out r> call r> swap in ; inline

! caps (the simplest of hats)
TUPLE: cap object ;
C: <cap> cap
M: cap out ( cap -- object ) object>> ;
M: cap (in) ( object cap -- ) (>>object) ;
INSTANCE: cap hat

! bowlers (dynamic variable hats)
TUPLE: bowler variable ;
C: <bowler> bowler
M: bowler out ( bowler -- object ) variable>> get ;
M: bowler (in) ( object bowler -- ) variable>> set ;
INSTANCE: bowler hat

! Top Hats (global variable hats)
TUPLE: top-hat variable ;
C: <top-hat> top-hat
M: top-hat out ( top-hat -- object ) variable>> get-global ;
M: top-hat (in) ( object top-hat -- ) variable>> set-global ;
INSTANCE: top-hat hat

USE: slots.private
! Slot hats
TUPLE: slot-hat tuple slot ;
C: <slot-hat> slot-hat
: >slot-hat< ( slot-hat -- tuple slot ) [ tuple>> ] [ slot>> ] bi ; inline
M: slot-hat out ( slot-hat -- object ) >slot-hat< slot ;
M: slot-hat (in) ( object slot-hat -- ) >slot-hat< set-slot ;
INSTANCE: slot-hat hat

! Put a box on your head
M: box out ( box -- object ) box> ;
M: box (in) ( object box -- ) >box ;
INSTANCE: box hat

