IN: tools.deploy.test.6
USING: namespaces math kernel ;

SYMBOL: x

SYMBOL: y

: deploy-test-6 ( -- )
    1 x set-global
    2 y set-global
    x get-global y get-global + 3 assert= ;

MAIN: deploy-test-6
