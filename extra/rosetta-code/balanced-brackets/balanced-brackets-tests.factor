USING: tools.test ;
IN: rosetta-code.balanced-brackets

{ t } [ "" balanced? ] unit-test
{ t } [ "[]" balanced? ] unit-test
{ t } [ "[][]" balanced? ] unit-test
{ t } [ "[[][]]" balanced? ] unit-test

{ f } [ "][" balanced? ] unit-test
{ f } [ "][][" balanced? ] unit-test
{ f } [ "[]][[]" balanced? ] unit-test

{ t } [ "abc[]def" balanced? ] unit-test
{ f } [ "abc][def" balanced? ] unit-test
