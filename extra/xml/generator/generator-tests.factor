USING: tools.test io.streams.string xml.generator xml.writer ;
[ "<html><body><a href=\"blah\"/></body></html>" ]
[ "html" [ "body" [ "a" { { "href" "blah" } } contained*, ] tag, ] make-xml [ write-item ] string-out ] unit-test
