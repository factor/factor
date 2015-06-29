IN: tools.deploy.test.2
USING: calendar calendar.format ;

: deploy-test-2 ( -- ) now (timestamp>string) ;

MAIN: deploy-test-2
