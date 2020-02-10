#!/bin/bash

# Make sure the production branch is in sync with its remote
git reset --hard origin/production
git clean -fdx

# Give the container user write access to the code
chmod -R go+w .

# Update the container image if necessary
docker pull quay.io/hibernate/awestruct-build-env:latest

# Build the site using the staging profile
docker run --rm=true --security-opt label:disable \
    -v $(pwd):/home/dev/website \
    quay.io/hibernate/awestruct-build-env:latest \
    "rake setup && rake clean[all] gen[production]"
rc=$?
if [[ $rc != 0 ]] ; then
    echo "ERROR: Site generation failed!"
    exit $rc
fi

# Clone beanvalidation.github.io in _publishing_tmp if not present.
# Using _tmp would mean more headaches related to access rights from the container,
# which usually removes that dir in "rake clean": let's avoid that.
mkdir _publishing_tmp 2>/dev/null
pushd _publishing_tmp
if [ ! -d "beanvalidation.github.io" ];
then
  git clone --depth 1 git@github.com:beanvalidation/beanvalidation.github.io.git
  rc=$?
  if [[ $rc != 0 ]] ; then
    echo "ERROR: beanvalidation/beanvalidation.github.io cannot be cloned!"
    exit $rc
  fi
fi

# Make sure the local clone of beanvalidation.github.io is in sync with its remote
pushd beanvalidation.github.io
git fetch origin
git reset --hard origin/master

# copy site to git repo, commit and push
# we filter cache as in production we shouldn't need that data
rsync -av \
      --delete \
      --filter "- /cache" --exclude ".git" --exclude "latest-draft/spec" \
      ../../_site/ .

rc=$?
if [[ $rc != 0 ]] ; then
    echo "ERROR: Site sync failed!"
    exit $rc
fi

git add -A .
if git commit -m "Publish generated site";
then
 git push origin master;
 rc=$?
fi
popd
popd
if [[ $rc != 0 ]] ; then
  echo "ERROR: Cannot push on site repository!"
  exit $rc
fi

