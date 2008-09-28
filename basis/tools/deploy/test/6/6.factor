IN: tools.deploy.test.6
USING: values math kernel ;

VALUE: x

VALUE: y

: deploy-test-6 ( -- )
    1 to: x
    2 to: y
    x y + 3 assert= ;

MAIN: deploy-test-6
