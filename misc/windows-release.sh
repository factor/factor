CPU=$1
VERSION=0.91

if [ "$CPU" = "x86" ]; then
    FLAGS="-no-sse2"
fi

make windows-nt-x86
CMD="./factor-nt -i=boot.x86.32.image -no-user-init $FLAGS"
echo $CMD
$CMD
rm -rf Factor.app/
rm -rf vm/
rm -f Makefile
rm -f cp_dir
rm -f boot.*.image

cd ..
zip -r Factor-$VERSION-win32-$CPU.zip Factor/
