USING: http-client test ;
[ "localhost" 80 ] [ "localhost" parse-host ] unit-test
[ "localhost" 8888 ] [ "localhost:8888" parse-host ] unit-test
[ "localhost:8888" "/foo" ] [ "http://localhost:8888/foo" parse-url ] unit-test
[ "localhost:8888" "/" ] [ "http://localhost:8888" parse-url ] unit-test
[ 404 ] [ "HTTP/1.1 404 File not found" parse-response ] unit-test
[ 404 ] [ "404 File not found" parse-response ] unit-test
[ 200 ] [ "HTTP/1.0 200" parse-response ] unit-test
[ 200 ] [ "HTTP/1.0 200 Success" parse-response ] unit-test
