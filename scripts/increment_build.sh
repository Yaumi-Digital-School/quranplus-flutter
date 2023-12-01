cider bump build

BUILD_NUMBER=$(echo $(cider version) | cut -d '+' -f 2)
BRANCH_NAME="build$BUILD_NUMBER"
git checkout -b $BRANCH_NAME

git add pubspec.yaml

git commit -m "chore: bump build number to $BUILD_NUMBER"

git push origin $BRANCH_NAME