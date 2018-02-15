USING: accessors kernel math math.order poker poker.private
tools.test ;

{ 134236965 } [ "KD" >ckf ] unit-test
{ 529159 } [ "5s" >ckf ] unit-test
{ 33589533 } [ "jc" >ckf ] unit-test

{ 7462 } [ "7C 5D 4H 3S 2C" string>value ] unit-test
{ 1601 } [ "KD QS JC TH 9S" string>value ] unit-test
{ 11 } [ "AC AD AH AS KC" string>value ] unit-test
{ 9 } [ "6C 5C 4C 3C 2C" string>value ] unit-test
{ 1 } [ "AC KC QC JC TC" string>value ] unit-test

{ "High Card" } [ "7C 5D 4H 3S 2C" string>hand-name ] unit-test
{ "Straight" } [ "KD QS JC TH 9S" string>hand-name ] unit-test
{ "Four of a Kind" } [ "AC AD AH AS KC" string>hand-name ] unit-test
{ "Straight Flush" } [ "6C 5C 4C 3C 2C" string>hand-name ] unit-test

{ t } [ "7C 5D 4H 3S 2C" "KD QS JC TH 9S" [ string>value ] bi@ > ] unit-test
{ t } [ "AC AD AH AS KC" "KD QS JC TH 9S" [ string>value ] bi@ < ] unit-test
{ t } [ "7C 5D 4H 3S 2C" "7D 5D 4D 3C 2S" [ string>value ] bi@ = ] unit-test

{ t } [ "7C 5D 4H 3S 2C" "2C 3S 4H 5D 7C" [ string>value ] bi@ = ] unit-test

{ t } [ "7C 5D 4H 3S 2C" "7D 5D 4D 3C 2S" [ string>value ] bi@ = ] unit-test

{ 190 } [ "AS KD JC KH 2D 2S KC" string>value ] unit-test
