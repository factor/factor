IN: scratchpad
USE: graphics
USE: test
USE: namespaces
USE: lists
USE: kernel

<rectangle> [
    #{ 0 0 } from set
    #{ 20 20 } to set
] extend "rect" set

[ t ] [ #{ 5 5 } "rect" get inside? ] unit-test
[ f ] [ #{ 5 50 } "rect" get inside? ] unit-test
[ f ] [ #{ 30 5 } "rect" get inside? ] unit-test

<rectangle> [
    #{ 10 15 } from set
    #{ 20 35 } to set
] extend "another-rect" set

"rect" get "another-rect" get 2list "scene" set

[ t ] [ #{ 5 5 } "scene" get grab "rect" get eq? ] unit-test
[ t ] [ #{ 19 30 } "scene" get grab "another-rect" get eq? ] unit-test
[ f ] [ #{ 50 50 } "scene" get grab ] unit-test
