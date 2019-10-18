
USING: io concurrency x concurrent-widgets ;

f initialize-x

"Hey Hey" create-label
[ map-window ] with-window-object

"Yo Yo Yo" [ "button pressed" print ] create-button
[ map-window ] with-window-object

[ concurrent-event-loop ] spawn