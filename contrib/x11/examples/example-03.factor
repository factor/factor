
USING: kernel namespaces sequences io x concurrency concurrent-widgets ;

SYMBOL: win-a
SYMBOL: button-a
SYMBOL: button-b
SYMBOL: button-c

f initialize-x

create-window-object win-a set

win-a get [ "black" lookup-color set-window-background ] with-window-object

"Hey Hey Hey" [ "button pressed" print ] create-button button-a set
"Yo Yo Yo"    [ "button pressed" print ] create-button button-b set
"Foo"         [ "button pressed" print ] create-button button-c set

[ button-a button-b button-c ] [ "red" "green" "blue" ]
[ lookup-color swap get [ set-window-background ] with-window-object ]
2each

[ button-a button-b button-c ]
[ get [ { 100 20 } resize-window ] with-window-object ]
each

[ button-a button-b button-c ]
[ get [ win-a get window-id reparent-window ] with-window-object ]
each

win-a get [ map-window ] with-window-object

[ button-a button-b button-c ] [ get [ map-window ] with-window-object ]
each

win-a get [ arrange-children-vertically ] with-window-object

[ concurrent-event-loop ] spawn