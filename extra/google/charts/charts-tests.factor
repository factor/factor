! Copyright (C) 2016 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors.constants google.charts
google.charts.private kernel math present sequences tools.test ;
IN: google.charts.tests

{ t } [

    { 0 0 } <line>
    { 0 0 } <line> COLOR: red >>background
    [ chart>url present length ] bi@ <
] unit-test

{ t } [
    { 0 0 } <line>
    { 0 0 } <line> COLOR: red >>foreground
    [ chart>url present length ] bi@ <
] unit-test

{ t } [
    "" <formula>
    "" <formula> t >>data-scale
    [ chart>url present length ] bi@ <
] unit-test

{ t } [
    { 0 0 } <line>
    { 0 0 } <line> f >>width f >>height
    [ chart>url present length ] bi@ >
] unit-test

{ t } [
    { 0 0 } <line>
    { 0 0 } <line> { 0 0 } >>margin
    [ chart>url present length ] bi@ <
] unit-test

{ t } [
    { 0 0 } <line>
    { 0 0 } <line> 5 >>bar-width
    [ chart>url present length ] bi@ <
] unit-test
