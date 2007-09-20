USING: crypto.timing kernel tools.test ;
IN: temporary

[ t ] [ millis [ ] 1000 with-timing millis swap - 1000 >= ] unit-test
