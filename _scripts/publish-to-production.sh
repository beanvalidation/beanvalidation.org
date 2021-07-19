#!/bin/bash
# This script should be invoked from the root of the repo,
# after the website has been generated,
# with a clone of git@github.com:beanvalidation/beanvalidation.github.io.git
# available in directory _publish_tmp/beanvalidation.github.io

pushd _publish_tmp/beanvalidation.github.io

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
 git push origin HEAD:master
 rc=$?
fi
if [[ $rc != 0 ]] ; then
  echo "ERROR: Cannot push on site repository!"
  exit $rc
fi

popd

