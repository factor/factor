! Copyright (C) 2016 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors.constants google.charts
google.charts.private kernel present sequences tools.test ;
IN: google.charts.tests

[ f ] [
    { 0 0 } <line> COLOR: red >>background chart>url present length
    { 0 0 } <line> chart>url present length =
] unit-test

[ f ] [
    { 0 0 } <line> COLOR: red >>foreground chart>url present length
    { 0 0 } <line> chart>url present length =
] unit-test

[ f ] [
    "" <formula> t >>data-scale chart>url present length
    "" <formula> chart>url present length =
] unit-test

[ f ] [
    { 0 0 } <line> f >>width f >>height chart>url present length
    { 0 0 } <line> chart>url present length =
] unit-test

[ f ] [
    { 0 0 } <line> { 0 0 } >>margin chart>url present length
    { 0 0 } <line> chart>url present length =
] unit-test

[ f ] [
    { 0 0 } <line> 5 >>bar-width chart>url present length
    { 0 0 } <line> chart>url present length =
] unit-test
