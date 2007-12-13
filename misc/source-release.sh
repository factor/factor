source misc/version.sh
rm -rf .git
cd ..
tar cfz Factor-$VERSION.tar.gz factor/

ssh linode mkdir -p w/downloads/$VERSION/
scp Factor-$VERSION.tar.gz linode:w/downloads/$VERSION/
