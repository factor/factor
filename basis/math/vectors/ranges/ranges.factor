! Copyright (C) 2023 Keldan Chapman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.order math.vectors ranges
ranges.private ;
IN: math.vectors.ranges

M: range vneg >range< [ neg ] tri@ <range> ;

M: range v+n [ >range< ] dip '[ [ _ + ] bi@ ] dip <range> ;
M: range n+v swap v+n ;

M: range v-n neg v+n ;
M: range n-v >range< roll '[ [ _ swap - ] bi@ ] dip neg <range> ;

M: range v*n [ >range< ] dip '[ _ * ] tri@ <range> ;
M: range n*v swap v*n ;

M: range v/n recip v*n ;

M: range v+ over range? [
        [ [ from>> ] bi@ + ]
        [ [ length>> ] bi@ min ]
        [ [ step>> ] bi@ + ] 2tri \ range boa
    ] [ call-next-method ] if ;

M: range v- >range< [ neg ] tri@ <range> v+ ;

M: range vavg over range?
    [ v+ 2 v/n ]
    [ call-next-method ] if ;
