[(1,0,0)] [(1,0,0) (0,1,0) 0 rot_vec] test

[1] [(1,0,0) (0,1,0) 90 rot_vec (0,0,-1) approx-eq] test
[1] [(1,2,3) (0,1,0) 90 rot_vec (3,2,-1) approx-eq] test

[1]
[
    (1,2,3) (4,5,6) normalize 45 rot_vec
    (1.43574109907107,1.539329069804002,3.093398375782619) approx-eq
] test

"Make sure nothing is left on the stack after the test" print
count [exch] [0] test
