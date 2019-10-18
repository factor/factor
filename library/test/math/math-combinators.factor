IN: scratchpad
USE: kernel
USE: math
USE: test

[ 0 1 2 3 4 ] [ 5 [ ] times* ] unit-test
[ ] [ 0 [ ] times* ] unit-test

[ #{ 1 1 } ] [ #{ 2 3 } #{ 1 0 } 2times-succ ] unit-test
[ #{ 1 2 } ] [ #{ 2 3 } #{ 1 1 } 2times-succ ] unit-test
[ #{ 2 0 } ] [ #{ 3 3 } #{ 1 2 } 2times-succ ] unit-test
[ #{ 2 1 } ] [ #{ 3 3 } #{ 2 0 } 2times-succ ] unit-test
[ #{ 2 0 } ] [ #{ 2 2 } #{ 1 1 } 2times-succ ] unit-test

[ #{ 0 0 } #{ 0 1 } #{ 1 0 } #{ 1 1 } ]
[ #{ 2 2 } [ ] 2times* ] unit-test

[ #{ 0 0 } #{ 0 1 } #{ 0 2 } #{ 1 0 } #{ 1 1 } #{ 1 2 } 
  #{ 2 0 } #{ 2 1 } #{ 2 2 } ]
[ #{ 3 3 } [ ] 2times* ] unit-test
