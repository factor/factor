! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors colors.private literals tools.test ;

{ t } [ COLOR: light-green value>> rgba? ] unit-test

{ T{ rgba f 0.0 0.0 0.0 1.0 } } [ COLOR: #000000 value>> ] unit-test
{ T{ rgba f 1.0 1.0 1.0 1.0 } } [ COLOR: #FFFFFF value>> ] unit-test
${ "abcdef" hex>rgba } [ COLOR: #abcdef value>> ] unit-test
${ "ABCDEF" hex>rgba } [ COLOR: #abcdef value>> ] unit-test

{ T{ rgba f 0.0 0.0 0.0 0.0 } } [ COLOR: #00000000 value>> ] unit-test
{ T{ rgba f 1.0 0.0 0.0 0.0 } } [ COLOR: #FF000000 value>> ] unit-test
{ T{ rgba f 1.0 1.0 0.0 0.0 } } [ COLOR: #FFFF0000 value>> ] unit-test
{ T{ rgba f 1.0 1.0 1.0 0.0 } } [ COLOR: #FFFFFF00 value>> ] unit-test
{ T{ rgba f 1.0 1.0 1.0 1.0 } } [ COLOR: #FFFFFFFF value>> ] unit-test

${ "cafebabe" hex>rgba } [ COLOR: #cafebabe value>> ] unit-test
${ "112233" hex>rgba } [ COLOR: #112233 value>> ] unit-test
${ "11223344" hex>rgba } [ COLOR: #11223344 value>> ] unit-test

{ "#00000000" } [ transparent color>hex ] unit-test
{ "#cafebabe" } [ COLOR: #cafebabe color>hex ] unit-test
{ "#112233" } [ COLOR: #112233 color>hex ] unit-test
{ "#11223344" } [ COLOR: #11223344 color>hex ] unit-test
