! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces retries tools.test ;
IN: retries.tests

! try every value in a sequence with no sleeps
[
    [ dup 2 = [ "not 2!" throw ] unless ]
    <immediate> { 1 } retries
] [ retries-failed? ] must-fail-with

{ 2 } [
    [ dup 2 = [ "not 2!" throw ] unless ]
    <immediate> { 1 2 } retries
] unit-test

! try every value in a sequence with a random sleep
[
    [ dup 2 = [ "not 2!" throw ] unless ]
    10 20 <random-wait> { 1 } retries
] [ retries-failed? ] must-fail-with

{ 2 } [
    [ dup 2 = [ "not 2!" throw ] unless ]
    10 20 <random-wait> { 1 2 } retries
] unit-test

! try every value in a sequence with an exponentially increasing sleep
[
    [ dup 2 = [ "not 2!" throw ] unless ]
    1.1 100 <exponential-wait> { 1 } retries
] [ retries-failed? ] must-fail-with

{ 2 } [
    [ dup 2 = [ "not 2!" throw ] unless ]
    1.1 100 <exponential-wait> { 1 2 } retries
] unit-test


! try n times with no sleeps
[
    [ 2 = [ "not 2!" throw ] unless ]
    <immediate> 2 retries
] [ retries-failed? ] must-fail-with

{ } [
    [ 2 = [ "not 2!" throw ] unless ]
    <immediate> 3 retries
] unit-test

! try n times with a random sleep
[
    [ 2 = [ "not 2!" throw ] unless ]
    10 20 <random-wait> 2 retries
] [ retries-failed? ] must-fail-with

{ } [
    [ 2 = [ "not 2!" throw ] unless ]
    10 20 <random-wait> 3 retries
] unit-test

! try n times with an exponentially increasing sleep
[
    [ 2 = [ "not 2!" throw ] unless ]
    1.1 100 <exponential-wait> 2 retries
] [ retries-failed? ] must-fail-with

{ } [
    [ 2 = [ "not 2!" throw ] unless ]
    1.1 100 <exponential-wait> 3 retries
] unit-test

