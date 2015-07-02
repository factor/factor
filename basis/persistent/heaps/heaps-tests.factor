USING: persistent.heaps tools.test ;
IN: persistent.heaps.tests

CONSTANT: test-input
    { { "hello" 3 } { "goodbye" 2 } { "whatever" 5 }
      { "foo" 1 } { "bar" -1 } { "baz" -7 } { "bing" 0 } }

[
    { { "baz" -7 } { "bar" -1 } { "bing" 0 } { "foo" 1 }
      { "goodbye" 2 } { "hello" 3 } { "whatever" 5 } }
] [ test-input assoc>pheap pheap>alist ] unit-test
