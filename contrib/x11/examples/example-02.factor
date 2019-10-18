
USING: kernel namespaces sequences x concurrency concurrent-widgets ;

SYMBOL: win-a   SYMBOL: win-b   SYMBOL: win-c   SYMBOL: win-d

f initialize-x

[ win-a win-b win-c win-d ] [ create-window swap set ] each
[ win-a win-b win-c win-d ] [ "black" "red" "green" "blue" ]
[ lookup-color swap get win set set-window-background ] 2each

[ win-b win-c win-d ] [ get win set win-a get reparent-window ] each

[ win-a win-b win-c win-d ] [ get win set map-window ] each

win-a get [ { 300 300 } resize-window ] with-win

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: button-horizontal

"Horizontal"
[ win-a get
  [ stack-children arrange-children-horizontally ] with-win
] create-button
button-horizontal set
button-horizontal get
[ { 100 20 } resize-window
  map-window
] with-window-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: button-vertical

"Vertical"
[ win-a get
  [ stack-children arrange-children-vertically ] with-win
] create-button
button-vertical set
button-vertical get
[ { 100 20 } resize-window
  map-window
] with-window-object

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

[ concurrent-event-loop ] spawn