% Missing core words:
% bind
% break
% catch
% catch-error
% echo
% eput
% resetinterpreter
% throw
% tokenformat
% tokensize
% type

"Literals" print

[] [] test
[-10] [-10] test
[10] [+10] test
[10.5] [10.5] test
[10.5] [+10.5] test
[-10.5] [-10.5] test
[1000000.0] [10e5] test
[1000000.0] [+10e5] test
[-1000000.0] [-10e5] test
[1050000.0] [10.5e5] test
[1050000.0] [+10.5e5] test
[-1050000.0] [-10.5e5] test
[(1,2)][(1,2)] test
[(1,2,3)][(1,2,3)] test
["Hello"] ["Hello"] test

[1] [{useregs} length] test

"Stack shuffling" print

[1] [1 2 pop] test
[1 2 ] [1 2 3 8 2 pops] test
[2 1] [1 2 exch] test
["a""b""c""d""d"] ["a""b""c""d" 0 index] test
["a""b""c""d""a"] ["a""b""c""d" 3 index] test
[0 2 3 1][0 1 2 3 3 -1 roll] test
[0 3 1 2][0 1 2 3 3 1 roll] test
[0 1 2 3][0 1 2 3 3 0 roll] test
[3 0 1 2][0 1 2 3 4 1 roll] test
[1 2 3 0][0 1 2 3 4 -1 roll] test
["a" "b" "c" ["g"]] ["a" "b" "c" ["d" "e" "f" cleartomark "g"]] test
["d" "e" "f" "g" 4] ["d" "e" "f" "g" counttomark] test

"Arrays" print

[[1 2 "X"]] [1 2 "X" 3 array] test
[-10] [[1 2 -10] 2 get] test
[-10] [[1 2 -10] -1 get] test
[[1 2 4]] [[1 2 -10] dup 2 4 put] test
[[1 "X" -10]] [[1 2 -10] dup -2 "X" put] test
[["a" "b" "c" "d"]] [["a" "b"] ["c" "d"] arrayappend] test
[["a" "b" 100]] [["a" "b"] 100 append] test
[{"a" "b" 100}] [{"a" "b"} 100 append] test
[["a" "b" "c"]] [["a" "b" "c" "d" "e"] 2 pop-back] test
[{"a" "b" "c"}] [{"a" "b" "c" "d" "e"} 2 pop-back] test
[["a" "b" "c" "d" "e"]] [["a" "b" "c" "d" "e"] 0 pop-back] test
[{"a" "b" "c" "d" "e"}] [{"a" "b" "c" "d" "e"} 0 pop-back] test
[["a" "b" "c" "d"]] [["a" "b" "c" "d" "e"] pop-back] test
[{"a" "b" "c" "d"}] [{"a" "b" "c" "d" "e"} pop-back] test
[["c" "d" "e"]] [["a" "b" "c" "d" "e"] 2 pop-front] test
[{"c" "d" "e"}] [{"a" "b" "c" "d" "e"} 2 pop-front] test
[["a" "b" "c" "d" "e"]] [["a" "b" "c" "d" "e"] 0 pop-front] test
[{"a" "b" "c" "d" "e"}] [{"a" "b" "c" "d" "e"} 0 pop-front] test
[["b" "c" "d" "e"]] [["a" "b" "c" "d" "e"] pop-front] test
[{"b" "c" "d" "e"}] [{"a" "b" "c" "d" "e"} pop-front] test
["Boo" 1 2 3] ["Boo" [1 2 3] aload] test
[4] [["a" "b" "c" "d"] length] test
[[3 2 1 2 2]] [[1 2 3] [5 1 0 1 1] array-get] test
[[1 2 4 5 6]] [[1 2 3 4 5 6] 2 arrayremove] test
[[1 2 3 4 6]] [[1 2 3 4 5 6] -2 arrayremove] test
[[1 "hallo" 2 3 4]] [[1 ["hallo" 2] 3 [4] []] flatten] test
[[1 2 [3]]] [[1 [2 [3]]] flatten] test
[[16.2 33.5 49.0 64.3 80.5]] [[80.5 64.3 49.0 33.5 16.2] reverse] test
[[ 3 4 5 1 2 3 4 5 1 2 ]] [[ 1 2 3 4 5 ] -3 7 slice] test
[[ "c" "d" "e" ]] [[ "a" "b" "c" "d" "e" "f" "g" ] 3 2 subarray] test

[
 [2 1 6] %A(rray)
 [2 0 1] %P(ermutation)
 1
]
[
 [ 2 1 6 ]
 dup
 sort-number-permutation
 dup
 2 %index of the first element in p
 get %get the first element of P
] test

"Dictionaries" print

[3 4] [
 /x 4 def
 dict begin
 /x 3 def
 x
 end
 x
] test

[3 4] [
 /x 4 def
 dict begin
 /x 3 def
 currentdict /x get
 end
 currentdict /x get
] test

dict begin
/squared {dup mul} def
[25] [5 squared] test
[{dup mul}] [/squared load] test
end

[3 4] [
 /x 4 def
 dict begin
 /x 3 def
 x
 /x undef
 x
 end
] test

dict begin

/mydict dict def
mydict /total 0 put
[1] [mydict /total known] test
[0] [mydict /badname known] test

end

dict begin
 /myBlack (0.0,0.0,0.0) def

 [1] [currentdict /myBlack known] test
 [0] [currentdict /myWhite known] test
end

dict begin
 /bing 5 def
 /bong "OH HAI" def

 dict begin
 /bong 10 def

 [1 "OH HAI"] [/bing where exch /bong get] test

 end
end

[3 3] [
 /d dict def
 d /x 3 put
 d /x get
 d copy /x 100 put
 d /x get
] test

[5] [
 dict begin
 /a 1 def
 /b 2 def
 /c 3 def
 /d 4 def
 /e 5 def
 currentdict keys length
 end
] test

[/a 10 /b 20 /c 30] dictfromarray begin
 [10] [a] test
 [20] [b] test
 [30] [c] test
end

dict dup
[/a 10 /b 20 /c 30] exch dictfromarray begin
 [10] [a] test
 [20] [b] test
 [30] [c] test
end

% Ensure original was mutated too!
begin
 [10] [a] test
 [20] [b] test
 [30] [c] test
end

"Pathnames" print
["Barak"] [
 dict dup begin
 dict dup /name exch def
 begin
 /first "Barak" def
 /last "Obama" def
 end
 end
 .name.first
] test

"Control flow" print

["Yes"] [1 {"Yes"} if] test
[] [0 {"Yes"} if] test

["Yes"] [1 {"Yes"} {"No"} ifelse] test
["No"] [0 {"Yes"} {"No"} ifelse] test

[1 2 4 8 16] [1 {dup 2 mul dup 16 ge {exit} if} loop] test

[["A" "A" "A" "A" "A" "A" "A" "A"]] [["A"] 3 {dup arrayappend} repeat] test

[2 6 10 14 18 22 26 30 34 38] [1 2 19 {2 mul} for] test
[2 6 10 14 18 22 26 30 34] [1 2 19 {2 mul} forx] test

[2 6 10 14] [1 2 7 {2 mul} for] test
[3 7 11 15] [[1 2 7 {2 mul} for] {1 add} forall] test
[[3 7 11 15]] [[1 2 7 {2 mul} for] {1 add} map] test

[ 10.1 9 8 7 6 5 4 3 2 ]
[
 [ 1.1 2 3 4 5 6 7 8 9 ]
 [ 9 7 5 3 1 -1 -3 -5 -7 ]
 { add } twoforall
] test

[ -7.9 -5 -2 1 4 7 10 13 16 ]
[
 [ 1.1 2 3 4 5 6 7 8 9 ]
 [ 9 7 5 3 1 -1 -3 -5 -7 ]
 { sub } twoforall
] test

[[10.1 9 8 7 6 5 4 3 2]]
[
 [ 1.1 2 3 4 5 6 7 8 9 ]
 [ 9 7 5 3 1 -1 -3 -5 -7 ]
 { add } twomap
] test

[/x] [/x /y 0 ifpop] test
[/y] [/x /y 1 ifpop] test

"Registers" print
[2 1] [1 2 {usereg !b !a ;b ;a} exec] test

[100] [
 {
 usereg
 {dup mul} !squared
 10 !x

 :x :squared
 } exec
] test

% Ghetto closures
[6] [
    /closure-test {
        usereg

        5 !x

        {:x 1 add !x} exec

        :x
    } def
    closure-test
] test

[8] [
    /closure-test {
        usereg

        5 !x

        {:x 1 add !x}

        7 !x

        exec

        :x
    } def
    closure-test
] test

"Make sure nothing is left on the stack after the test" print
count [exch] [0] test
