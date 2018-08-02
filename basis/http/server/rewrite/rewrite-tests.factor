USING: accessors arrays http.server http.server.rewrite kernel
namespaces tools.test urls ;
IN: http.server.rewrite.tests

TUPLE: rewrite-test-default ;

M: rewrite-test-default call-responder*
    drop "DEFAULT!" 2array ;

TUPLE: rewrite-test-child ;

M: rewrite-test-child call-responder*
    drop "rewritten-param" param 2array ;

V{ } clone responder-nesting set
H{ } clone params set

<rewrite>
    rewrite-test-child new >>child
    rewrite-test-default new >>default
    "rewritten-param" >>param
"rewrite" set

{ { { } "DEFAULT!" } } [ { } "rewrite" get call-responder ] unit-test
{ { { } "xxx" } } [ { "xxx" } "rewrite" get call-responder ] unit-test
{ { { "blah" } "xxx" } } [ { "xxx" "blah" } "rewrite" get call-responder ] unit-test

<vhost-rewrite>
    rewrite-test-child new >>child
    rewrite-test-default new >>default
    "rewritten-param" >>param
    "blogs.vegan.net" >>suffix
"rewrite" set

{ { { } "DEFAULT!" } } [
    url"http://blogs.vegan.net" url set
    { } "rewrite" get call-responder
] unit-test

{ { { } "DEFAULT!" } } [
    url"http://www.blogs.vegan.net" url set
    { } "rewrite" get call-responder
] unit-test

{ { { } "erg" } } [
    url"http://erg.blogs.vegan.net" url set
    { } "rewrite" get call-responder
] unit-test
