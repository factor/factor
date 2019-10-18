IN: temporary
USING: gadgets-scrolling gadgets test generic kernel timers ;

timers [ init-timers ] unless

[ t ]
[ <y-slider> slider-elevator [ timer-gadget? ] is? ]
unit-test

[ ] [
    <y-slider> slider-elevator
    dup elevator-click stop-timer-gadget
] unit-test
