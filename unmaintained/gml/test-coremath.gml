% Missing math words:
% aNormal

"Arithmetic" print
[17] [9 8 add] test
[(10,20)] [(5,14) (5,6) add] test
[(10,20,30)] [(5,14,23) (5,6,7) add] test

[-34] [30 64 sub] test
[(0,8,16)] [(5,14,23) (5,6,7) sub] test

[1170] [117 10 mul] test
[(15,42)] [(5,14) 3 mul] test
[(10,28)] [2 (5,14) mul] test
[(15,42,69)] [(5,14,23) 3 mul] test
[(10,28,46)] [2 (5,14,23) mul] test
[2.0] [(1,0) (2,3) mul] test
[6.0] [(1,0,1) (2,3,4) mul] test

% Stupid bug with vec3 dot product
[20.0] [(1,0,1) 1 add (2,4,6) mul] test

[0.125] [2 16 div] test
[(1,4,10)] [(2,8,20) 2 div] test

[3] [7 4 mod] test

[-1.0] [1.0 neg] test

[(-1,-2)] [(1,2) neg] test
[(-1,-2,-3)] [(1,2,3) neg] test

"Comparisons" print
[1] [1 1 eq] test
[0] [1 2 eq] test
[0] [1 1 ne] test
[1] [1 2 ne] test
[1] [1 0 ge] test
[1] [1 1 ge] test
[0] [1 2 ge] test
[1] [1 0 gt] test
[0] [1 1 gt] test
[0] [1 2 gt] test
[0] [1 0 le] test
[1] [1 1 le] test
[1] [1 2 le] test
[0] [1 0 lt] test
[0] [1 1 lt] test
[1] [1 2 lt] test

[-1.0] [-2.0 (-1.0,10.0) clamp] test
[0.5] [0.5 (-1.0,10.0) clamp] test
[10.0] [22.0 (-1.0,10.0) clamp] test

"Logical operators" print
[0] [0 0 and] test
[0] [0 1 and] test
[0] [0.0 0 and] test
[0] [0.0 0.0 and] test
[1] [1.0 1 and] test
[1] [1.0 "hi" and] test

[0] [0 0 or] test
[1] [0 1 or] test
[0] [0.0 0 or] test
[0] [0.0 0.0 or] test
[1] [1.0 1 or] test
[1] [1.0 "hi" or] test

[1] [0 not] test
[1] [0.0 not] test
[0] [1 not] test
[0] ["Hi" not] test

"Functions" print
[126.42] [-126.42 abs] test
[5.0] [(3,4) abs] test
[129.0] [128.15 ceiling] test
[128.0] [128.95 floor] test
[-13.0] [-12.35 floor] test
[12.0] [12.34 trunc] test
[12] [12 trunc] test
[-12.0] [-12.35 trunc] test
[12.0] [12.34 round] test
[13.0] [12.64 round] test
[-12.0] [-12.35 round] test
[-13.0] [-12.65 round] test
[2.0] [4 sqrt] test

[0.25] [4 inv] test
[3.0] [1000 log] test
[1000.0] [10 3 pow] test

[180.0] [-1 acos] test
[0.0] [1 acos] test
[-90.0] [-1 asin] test
[90.0] [1 asin] test
[-45.0] [-1 atan] test
[45.0] [1 atan] test
[45.0] [1 1 atan2] test
[135.0] [1 -1 atan2] test
[-45.0] [-1 1 atan2] test

"Vector operations" print
[5.0] [(5.0,1.3) getX] test
[1.3] [(5.0,1.3) getY] test
[5.0] [(5.0,1.3,2.7) getX] test
[1.3] [(5.0,1.3,2.7) getY] test
[2.7] [(5.0,1.3,2.7) getZ] test

[(1.7,1.3)] [(5.0,1.3) 1.7 putX] test
[(5.0,1.7)] [(5.0,1.3) 1.7 putY] test
[(1.7,1.3,2.7)] [(5.0,1.3,2.7) 1.7 putX] test
[(5.0,1.7,2.7)] [(5.0,1.3,2.7) 1.7 putY] test
[(5.0,1.3,1.7)] [(5.0,1.3,2.7) 1.7 putZ] test

[(5.0,1.3)] [5.0 1.3 vector2] test
[(5.0,1.3,2.7)] [5.0 1.3 2.7 vector3] test

[(3.5,4.1,0.0)] [(1.0,0.0,0.0) (0.0,1.0,0.0) (3.5,4.1) planemul] test

[(0.0,0.0,1.0)] [(1.0,0.0,0.0) (0.0,1.0,0.0) cross] test
[(0.0,-1.0,0.0)] [(1.0,0.0,0.0) (0.0,0.0,1.0) cross] test

[(-0.0,1)] [(1,0) aNormal] test
[(-0.0,-1)] [(-1,0) aNormal] test
[(-1,0)] [(0,1) aNormal] test
[(1,0)] [(0,-1) aNormal] test
% [(0.0,1,0)] [(1,0,0) aNormal] test
% [(-0.0,-1,0)] [(-1,0,0) aNormal] test
% [(-1,0,0)] [(0,1,0) aNormal] test
% [(1,0,0)] [(0,-1,0) aNormal] test
% [(-1,0,0)] [(0,0,1) aNormal] test
% [(1,0,0)] [(0,0,-1) aNormal] test

[-2.0] [(1,2) (3,4) determinant] test
[0.0] [(1,2,3) (4,5,6) (7,8,9) determinant] test
[6.0] [(1,2,3) (4,5,6) (7,8,7) determinant] test

"Fibonacci" print

dict begin

    /fib {
     dup 1 le {pop 1} {dup 1 sub fib exch 2 sub fib add} ifelse
    } def

    [121393] [25 fib] test

    /fibreg {
     dup 1 le
     {pop 1}
     {
     usereg !n
     ;n 1 sub fib !x
     ;n 2 sub fib !y
     ;x ;y add
     } ifelse
    } def

    [121393] [25 fibreg] test

end

"Make sure nothing is left on the stack after the test" print
count [exch] [0] test
