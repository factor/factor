source misc/version.sh

CPU=$1

if [ "$CPU" = "x86" ]; then
    FLAGS="-no-sse2"
fi

make windows-nt-x86

wget http://factorcode.org/dlls/freetype6.dll
wget http://factorcode.org/dlls/zlib1.dll
wget http://factorcode.org/images/$VERSION/boot.x86.32.image

CMD="./factor-nt -i=boot.x86.32.image -no-user-init $FLAGS"
echo $CMD
$CMD
rm -rf .git/
rm -rf Factor.app/
rm -rf vm/
rm -f Makefile
rm -f cp_dir
rm -f boot.*.image

cd ..
zip -r Factor-$VERSION-win32-$CPU.zip Factor/
