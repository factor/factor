USING: math kernel sequences io.files io.pathnames
tools.crossref tools.test parser namespaces source-files generic
definitions ;
IN: tools.crossref.tests

GENERIC: foo ( a b -- c )

M: integer foo + ;

"vocab:tools/crossref/test/foo.factor" run-file

[ t ] [ integer \ foo method \ + usage member? ] unit-test
[ t ] [ \ foo usage [ pathname? ] any? ] unit-test
