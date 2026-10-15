USING: compiler.constants cpu.architecture namespaces system tools.test ;
IN: compiler.constants.tests
{ t } [ 14 "ppc.64" rc-native-absolute? ] unit-test
{ f } [ 15 "ppc.64le" rc-native-absolute? ] unit-test
{ t } [ 14 "mips.64" rc-native-absolute? ] unit-test
{ t } [ 15 "mipsel.32" rc-native-absolute? ] unit-test
{ f } [ 14 "s390x" rc-native-absolute? ] unit-test
{ t } [ 15 "s390x" rc-native-absolute? ] unit-test
{ f } [ 14 "sparc.32" rc-native-absolute? ] unit-test
{ t } [ 15 "sparc.64" rc-native-absolute? ] unit-test
[ 14 "x86.64" rc-native-absolute? ] [ unsupported-native-relocation? ] must-fail-with

! Cross-generation binds the target without changing the host VM CPU.
{ f t } [ sparc.32 \ cpu [ 14 rc-absolute? big-endian-cpu? ] with-variable ] unit-test
{ t t } [ sparc.64 \ cpu [ 15 rc-absolute? big-endian-cpu? ] with-variable ] unit-test
{ t t } [ mips.64 \ cpu [ 14 rc-absolute? big-endian-cpu? ] with-variable ] unit-test
{ t f } [ mipsel.64 \ cpu [ 15 rc-absolute? big-endian-cpu? ] with-variable ] unit-test
{ f t } [ s390x \ cpu [ 14 rc-absolute? big-endian-cpu? ] with-variable ] unit-test
{ t f } [ ppc.64le \ cpu [ 14 rc-absolute? big-endian-cpu? ] with-variable ] unit-test
