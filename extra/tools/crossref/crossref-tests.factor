USING: math kernel sequences io.files tools.crossref tools.test
parser namespaces source-files ;
IN: temporary

GENERIC: foo

M: integer foo + ;

"resource:extra/tools/test/foo.factor" run-file

[ t ] [ { integer foo } \ + smart-usage member? ] unit-test
[ t ] [ \ foo smart-usage [ pathname? ] contains? ] unit-test
