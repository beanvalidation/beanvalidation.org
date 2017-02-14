# How to build beanvalidation.org

A bit of Git, a bit of Ruby and you will get your local beanvalidation.org served.

## Prerequisites

* Get [Git](http://git-scm.com)
* Get a [Ruby](https://www.ruby-lang.org/en/) > 1.9
* Get [RVM](https://rvm.io/) to manage separate Ruby environments (optional - you should know what and why you do it)

## Installation

### Get the source

    > git clone https://github.com/beanvalidation/beanvalidation.org.git
    > cd beanvalidation.org

### Rake

Make sure [Rake](https://github.com/jimweirich/rake) is available. It is often installed per default.

    > rake --version
    rake, version 0.9.6

If you get *command not found*:

    gem install rake

### Bundler

Make sure [Bundler](http://bundler.io/) is available. It manages your Ruby gems locally to the project
and prevents version conflicts between different Ruby projects. To quote from the website:

> Bundler provides a consistent environment for Ruby projects by tracking and installing the exact
> gems and versions that are needed.

    > bundle -v
    Bundler version 1.6.2

If you get *command not found*:

    gem install bundler

### Install  dependencies

    rake setup[local]
    rake check

### Serve the site locally

    rake preview

Point your browser to [http://localhost:4242](http://localhost:4242)

## Tips & Tricks

### Which other tasks exist in the Rake build file?

    > rake --tasks

This will list the available tasks with a short description

### I am getting errors when trying to execute *awestruct* directly

You need to use `bundle exec <command>` to make sure you get all required Gems. Check the *Rakefile*
to see how the different awestruct calls are wrapped.

### If your changes are not visible...

Panic! Then completely regenerate the site via:

    rake clean preview

## License

The content of this repository is released under the [ASL 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt).

By submitting a [pull request](https://help.github.com/articles/using-pull-requests) or otherwise
contributing to this repository, you agree to license your contribution under the respective
licenses mentioned above.
