source misc/version.sh
rm -rf .git
cd ..
tar cfz Factor-$VERSION.tgz factor/
