USING: crypto.timing kernel tools.test system math ;
IN: temporary

[ t ] [ millis [ ] 1000 with-timing millis swap - 1000 >= ] unit-test
