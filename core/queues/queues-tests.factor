USING: kernel math namespaces queues sequences tools.test ;
IN: temporary

<queue> "queue" set

[ t ] [ "queue" get queue-empty? ] unit-test

[ ] [ [ 1 2 3 4 5 ] [ "queue" get enque ] each ] unit-test

[ { 1 2 3 4 5 } ] [ 5 [ drop "queue" get deque ] map ] unit-test

[ "queue" get deque ] unit-test-fails
