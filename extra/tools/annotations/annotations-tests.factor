USING: tools.test tools.annotations ;
IN: temporary

: foo ;
\ foo watch

[ ] [ foo ] unit-test
