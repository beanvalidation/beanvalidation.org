---
title: Working with the API and TCK sources
layout: default
author: Gunnar Morling
---

# #{page.title}

## API

### Pull requests

Changes to the Bean Validation API are realized using [pull requests](http://help.github.com/send-pull-requests/) 
against the [API repository](https://github.com/beanvalidation/beanvalidation-api) on GitHub.

When doing a pull request, make sure to:

* rebase your work off the current HEAD on master
* name your topic branch by the issue number 
  (like [BVAL-42](https://hibernate.onjira.com/browse/BVAL-42))
* rebase your work rather than merge in order to keep the history linear

### Coding guidelines

Obey to the following rules when working on the API sources:

* JavaDoc
  * Make sure each member is completely documented
  * Provide package-level documentation when adding new packages
  * Use `{@code}` instead of `<code>`, because it is more readable and `{@code}` also escapes meta characters
  * `@param`, `@return` and `@throw` don't end with a '.'
  * If referring to other classes and methods use `{@link}`
  * Use `<ul/>` instead of '-' for enumerations
  * Use `@since` to document in which spec revision a type/member was added to the API

* Use the IntelliJ [code style template](https://community.jboss.org/wiki/ContributingToHibernateValidator#Coding_Guidelines) 
   from the reference implementation to format API sources

## TCK

Information on how to work with the TCK, running it against a given implementation etc. can be found in

* the TCK [reference guide](http://docs.jboss.org/hibernate/stable/beanvalidation/tck/reference/html_single/)
* the [wiki](https://community.jboss.org/wiki/BeanValidationTCK) of the reference implementation