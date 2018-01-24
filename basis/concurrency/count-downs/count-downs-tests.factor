USING: concurrency.count-downs threads kernel tools.test ;
IN: concurrency.count-downs.tests

{ } [ 0 <count-down> await ] unit-test

[ 1 <count-down> dup count-down count-down ] must-fail

{ } [
    1 <count-down>
    3 <count-down>
    2dup [ await count-down ] 2curry "Master" spawn drop
    dup [ count-down ] curry "Slave" spawn drop
    dup [ count-down ] curry "Slave" spawn drop
    dup [ count-down ] curry "Slave" spawn drop
    drop await
] unit-test
