source misc/version.sh
rm -rf .git
cd ..
tar cfz Factor-$VERSION.tgz factor/

ssh linode mkdir -p w/downloads/$VERSION/
scp Factor-$VERSION.tgz linode:w/downloads/$VERSION/
