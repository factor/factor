source misc/version.sh

TARGET=$1

if [ "$TARGET" = "x86" ]; then
	CPU="x86.32"
else
	CPU="macosx-ppc"
fi

BOOT_IMAGE=boot.$CPU.image
wget http://factorcode.org/images/$VERSION/$BOOT_IMAGE

make macosx-$TARGET
Factor.app/Contents/MacOS/factor -i=$BOOT_IMAGE -no-user-init

DISK_IMAGE_DIR=Factor-$VERSION
DISK_IMAGE=Factor-$VERSION-$TARGET.dmg

rm -f $DISK_IMAGE
rm -rf $DISK_IMAGE_DIR
mkdir $DISK_IMAGE_DIR
mkdir -p $DISK_IMAGE_DIR/Factor/
cp -R Factor.app $DISK_IMAGE_DIR/Factor/Factor.app
chmod +x cp_dir
cp factor.image license.txt README.txt $DISK_IMAGE_DIR/Factor/
find core extra fonts misc unmaintained -type f \
	-exec ./cp_dir {} $DISK_IMAGE_DIR/Factor/{} \;
hdiutil create -srcfolder "$DISK_IMAGE_DIR" -fs HFS+ \
	-volname "$DISK_IMAGE_DIR" "$DISK_IMAGE"

ssh mkdir -p linode:w/downloads/$VERSION/
scp $DISK_IMAGE linode:w/downloads/$VERSION/
