USING: kernel parser words compiler sequences ;

! contrib/x11 depends on contrib/concurrency

{ "rectangle" "x" "draw-string" "concurrent-widgets" "gl" }
[ "/contrib/x11/" swap ".factor" append3 run-resource ] each