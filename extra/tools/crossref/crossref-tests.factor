USING: math kernel sequences io.files tools.crossref tools.test
parser namespaces source-files generic definitions ;
IN: tools.crossref.tests

GENERIC: foo

M: integer foo + ;

"resource:extra/tools/test/foo.factor" run-file

[ t ] [ integer \ foo method method-word \ + usage member? ] unit-test
[ t ] [ \ foo usage [ pathname? ] contains? ] unit-test
