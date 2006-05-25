USING: kernel parser words compiler sequences ;

"contrib/concurrency/load.factor" run-resource

{ "rectangle" "x" "draw-string" "concurrent-widgets" "gl" }
[ "/contrib/x11/" swap ".factor" append3 run-resource ] each