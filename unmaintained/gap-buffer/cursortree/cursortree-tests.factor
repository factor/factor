USING: kernel gap-buffer.cursortree tools.test sequences trees arrays strings ;

[ t ] [ "this is a test string" <cursortree> 0 <left-cursor> at-beginning? ] unit-test
[ t ] [ "this is a test string" <cursortree> dup length  <left-cursor> at-end? ] unit-test
[ 3 ] [ "this is a test string" <cursortree> 3 <left-cursor> cursor-pos ] unit-test
[ CHAR: i ] [ "this is a test string" <cursortree> 3 <left-cursor> element< ] unit-test
[ CHAR: s ] [ "this is a test string" <cursortree> 3 <left-cursor> element> ] unit-test
[ t ] [ "this is a test string" <cursortree> 3 <left-cursor> CHAR: a over set-element< CHAR: t over set-element> cursor-tree "that is a test string" sequence= ] unit-test
[ t ] [ "this is a test string" <cursortree> 3 <left-cursor> 8 over set-cursor-pos dup 1array swap cursor-tree cursortree-cursors tree-values sequence= ] unit-test
[ "this is no longer a test string" ] [ "this is a test string" <cursortree> 8 <left-cursor> "no longer " over insert cursor-tree >string ] unit-test
[ "refactor" ] [ "factor" <cursortree> 0 <left-cursor> CHAR: e over insert CHAR: r over insert cursor-tree >string ] unit-test
[ "refactor" ] [ "factor" <cursortree> 0 <right-cursor> CHAR: r over insert CHAR: e over insert cursor-tree >string ] unit-test
[ "this a test string" 5 ] [ "this is a test string" <cursortree> 5 <right-cursor> dup delete> dup delete> dup delete> dup cursor-tree >string swap cursor-pos ] unit-test
[ "this a test string" 5 ] [ "this is a test string" <cursortree> 8 <right-cursor> dup delete< dup delete< dup delete< dup cursor-tree >string swap cursor-pos ] unit-test
