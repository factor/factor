! Copyright (C) 2021 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces retries tools.test ;
IN: retries.tests

! try every value in a sequence with no sleeps
[
    [ dup 2 = [ "not 2!" throw ] unless ]
    { 1 } <immediate> retries
] [ retries-failed? ] must-fail-with

{ 2 } [
    [ dup 2 = [ "not 2!" throw ] unless ]
    { 1 2 } <immediate> retries
] unit-test

! try every value in a sequence with a random sleep
[
    [ dup 2 = [ "not 2!" throw ] unless ]
    { 1 } 10 20 <random-wait> retries
] [ retries-failed? ] must-fail-with

{ 2 } [
    [ dup 2 = [ "not 2!" throw ] unless ]
    { 1 2 } 10 20 <random-wait> retries
] unit-test

! try every value in a sequence with an exponentially increasing sleep
[
    [ dup 2 = [ "not 2!" throw ] unless ]
    { 1 } 1.1 100 <exponential-wait> retries
] [ retries-failed? ] must-fail-with

{ 2 } [
    [ dup 2 = [ "not 2!" throw ] unless ]
    { 1 2 } 1.1 100 <exponential-wait> retries
] unit-test


! try n times with no sleeps
[
    [ 2 = [ "not 2!" throw ] unless ]
    2 <immediate> retries
] [ retries-failed? ] must-fail-with

{ } [
    [ 2 = [ "not 2!" throw ] unless ]
    3 <immediate> retries
] unit-test

! try n times with a random sleep
[
    [ 2 = [ "not 2!" throw ] unless ]
    2 10 20 <random-wait> retries
] [ retries-failed? ] must-fail-with

{ } [
    [ 2 = [ "not 2!" throw ] unless ]
    3 10 20 <random-wait> retries
] unit-test

! try n times with an exponentially increasing sleep
[
    [ 2 = [ "not 2!" throw ] unless ]
    2 1.1 100 <exponential-wait> retries
] [ retries-failed? ] must-fail-with

{ } [
    [ 2 = [ "not 2!" throw ] unless ]
    3 1.1 100 <exponential-wait> retries
] unit-test