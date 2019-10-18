IN: temporary
USING: math kernel sequences tools io test ;

GENERIC: foo

M: integer foo + ;

1 2 foo drop

[ t ] [ { integer foo } \ + smart-usage member? ] unit-test
[ t ] [ \ foo smart-usage [ pathname? ] contains? ] unit-test
