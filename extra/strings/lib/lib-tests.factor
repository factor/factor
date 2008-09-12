USING: kernel sequences strings.lib tools.test ;
IN: temporary

[ "abcdefghijklmnopqrstuvwxyz" ] [ lower-alpha-chars "" like ] unit-test
[ "ABCDEFGHIJKLMNOPQRSTUVWXYZ" ] [ upper-alpha-chars "" like ] unit-test
[ "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" ] [ alpha-chars "" like ] unit-test
[ "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" ] [ alphanumeric-chars "" like ] unit-test
[ t ] [ 100 [ random-alphanumeric-char ] replicate alphanumeric-chars [ member? ] curry all? ] unit-test
