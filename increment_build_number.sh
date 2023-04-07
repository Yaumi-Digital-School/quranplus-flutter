# Increment build number
perl -i -pe 's/^(version:\s+\d+\.\d+\.\d+\+)(\d+)$/$1.($2+1)/e' ./pubspec.yaml

# Get build number
version=`grep 'version: ' ./pubspec.yaml | sed 's/version: //'`

# Prepare & push build number changes
git checkout -b chore-bump-to-$version
git add ./pubspec.yaml
git commit -m "chore: bump to $version"
git push origin chore-bump-to-$version
git checkout master