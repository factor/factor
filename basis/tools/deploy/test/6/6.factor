IN: tools.deploy.test.6
USING: values math kernel ;

VALUE: x

VALUE: y

: deploy-test-6 ( -- )
    1 \ x set-value
    2 \ y set-value
    x y + 3 assert= ;

MAIN: deploy-test-6
