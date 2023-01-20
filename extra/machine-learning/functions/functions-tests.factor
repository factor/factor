! Copyright (C) 2017 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test machine-learning.functions ;

{ 0 } [ 0 relu ] unit-test
{ .5 .000001 } [ .5 relu ] unit-test~
{ 1 } [ 1 relu ] unit-test
{ 0 } [ -.5 relu ] unit-test
{ 0 } [ -1 relu ] unit-test

{ 0 } [ -1 relu6 ] unit-test
{ 6 } [ 10 relu6 ] unit-test

{ -.01 .00001 } [ -1 .01 leaky-relu ] unit-test~
{ 0 } [ 0 .01 leaky-relu ] unit-test
{ .5 .000001 } [ .5 .01 leaky-relu ] unit-test~
{ 1 } [ 1 .01 leaky-relu ] unit-test
{ -.005 .1 } [ -.5 .01 leaky-relu ] unit-test~

{ 0 } [ 0 default-leaky-relu ] unit-test
{ 1 } [ 1 default-leaky-relu ] unit-test
{ .5 .000001 } [ .5 default-leaky-relu ] unit-test~
{ -.005 .1 } [ -.5 default-leaky-relu ] unit-test~

{
    {
        0.327201948676532
        0.1203708700293295
        0.04428196839971006
        0.0162904257888568
        0.327201948676532
        0.1203708700293295
        0.04428196839971006
    } .00001
} [ { 1. 2. 3. 4. 1. 2. 3. } softmin ] unit-test-v~

{
    {
        0.02364054302159138
        0.06426165851049616
        0.1746812985957223
        0.4748329997443803
        0.02364054302159138
        0.06426165851049616
        0.1746812985957223
    } .00001
} [ { 1. 2. 3. 4. 1. 2. 3. } softmax ] unit-test-v~

{
    {
        -7.463073944710613
        -12.13384821518222
        -24.83032903943923
        -59.3429421493958
        -7.463073944710613
        -12.13384821518222
        -24.83032903943923
    } .00001
} [ { 1. 2. 3. 4. 1. 2. 3. } log-softmax ] unit-test-v~
