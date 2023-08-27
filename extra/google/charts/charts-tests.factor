! Copyright (C) 2016 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors google.charts google.charts.private
kernel math present sequences tools.test ;

! The order of the constructors below is important, because we
! are testing side-effects. If you remove the clone word from
! chart>url implementation, the second object in each test
! will incorrectly result in the same URL as the first one
! (although the order of parameters in the URL may vary).
! The order of tests is important for the same reason.

{ t } [
    "" <formula> t >>data-scale
    "" <formula>
    [ chart>url present length ] bi@ >
] unit-test

{ t } [
    { 0 0 } <line>
    { 0 0 } <line> f >>width f >>height
    [ chart>url present length ] bi@ >
] unit-test

{ t } [
    { 0 0 } <line> COLOR: red >>background
    { 0 0 } <line>
    [ chart>url present length ] bi@ >
] unit-test

{ t } [
    { 0 0 } <line> COLOR: red >>foreground
    { 0 0 } <line>
    [ chart>url present length ] bi@ >
] unit-test

{ t } [
    { 0 0 } <line> { 0 0 } >>margin
    { 0 0 } <line>
    [ chart>url present length ] bi@ >
] unit-test

{ t } [
    { 0 0 } <line> 5 >>bar-width
    { 0 0 } <line>
    [ chart>url present length ] bi@ >
] unit-test
