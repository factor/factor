USING: alien.libraries.finder alien.libraries.finder.linux.private
 assocs compiler.errors debugger environment io io.files io.files.info kernel
 libudev namespaces sequences system tools.test ;
f restartable-tests? set-global
{ t } [ "factor-rebase-probe" find-library "libfactor-rebase-probe.so.10" tail? ] unit-test
{ t } [ "factor-rebase-probe" find-library native-library? ] unit-test
{ f } [ "FACTOR_FINDER_MARKER" os-env file-exists? ] unit-test
{ t } [ "udev_new" udev-function-available? ] unit-test
{ t } [ udev_new dup >boolean swap udev_unref ] unit-test
test-failures get empty? compiler-errors get assoc-empty? and
[ "Native library controls passed" print 0 ]
[ :test-failures compiler-errors get values [ print-error ] each 1 ] if flush exit
