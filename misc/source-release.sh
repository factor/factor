source misc/version.sh
rm -rf .git
cd ..
tar cfz Factor-$VERSION.tgz factor/

ssh mkdir -p linode:w/downloads/$VERSION/
scp Factor-$VERSION.tgz linode:w/downloads/$VERSION/
