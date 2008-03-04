USING: crypto.timing kernel tools.test system math ;
IN: crypto.timing.tests

[ t ] [ millis [ ] 1000 with-timing millis swap - 1000 >= ] unit-test
