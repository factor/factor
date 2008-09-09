USING: tools.test io.streams.string xml.generator xml.writer accessors ;
[ "<html><body><a href=\"blah\"/></body></html>" ]
[ "html" [ "body" [ "a" { { "href" "blah" } } contained*, ] tag, ] make-xml [ body>> write-item ] with-string-writer ] unit-test
