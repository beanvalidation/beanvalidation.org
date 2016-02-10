#!/bin/bash
# Make sure the staging branch is in sync with its remote
git reset --hard origin/staging
git clean -fdx

# Remove all generated files and directories
rake clean[all]

# Make sure there was no update to the used dependencies (if not, this is just a quick version check for Bundler)
rake setup
rc=$?
if [[ $rc != 0 ]] ; then
    echo "ERROR: Rake setup failed!"
    exit $rc
fi

# Build the site using the staging profile and sync
rake --trace gen[staging]
rc=$?
if [[ $rc != 0 ]] ; then
    echo "ERROR: Site generation failed!"
    exit $rc
fi

rsync --delete --exclude "latest-draft/spec" -avh _site/ ci.hibernate.org:/var/www/staging-beanvalidation.org
rc=$?
if [[ $rc != 0 ]] ; then
    echo "ERROR: Site sync failed!"
    exit $rc
fi
