#!/bin/bash
# Make sure the staging branch is in sync with its remote
git reset --hard origin/staging
git clean -fdx

# Give the container user write access to the code
chmod -R go+w .

# Update the container image if necessary
docker pull quay.io/hibernate/awestruct-build-env:latest

# Build the site using the staging profile
docker run --rm=true --security-opt label:disable \
    -v $(pwd):/home/dev/website \
    quay.io/hibernate/awestruct-build-env:latest \
    "rake setup && rake clean[all] gen[staging]"
rc=$?
if [[ $rc != 0 ]] ; then
    echo "ERROR: Site generation failed!"
    exit $rc
fi

# Publish
rsync --delete --exclude "latest-draft/spec" -avh _site/ ci.hibernate.org:/var/www/staging-beanvalidation.org
rc=$?
if [[ $rc != 0 ]] ; then
    echo "ERROR: Site sync failed!"
    exit $rc
fi
