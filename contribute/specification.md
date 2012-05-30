---
title: How to contribute a specification proposal
layout: default
author: Emmanuel Bernard
---

# #{page.title}

The specification proper is written in Docbook, an XML based documentation.

The recommended approach to contribute to the spec is via 
[GitHub pull requests](http://help.github.com/send-pull-requests/). 
This is an extremely useful tool to review and comment proposals.

Many specification changes involve API changes as well. In this case, propose a pull 
request for the [Bean Validation API](https://github.com/beanvalidation/beanvalidation-api) 
repository as well. When doing so, make sure to follow our [coding guidelines](/contribute/coding).

Want to be a very good citizen? Also work on implementing your proposal on the 
[reference implementation](https://github.com/hibernate/hibernate-validator) and the 
[TCK](https://github.com/beanvalidation/beanvalidation-tck) and send a pull request for each. Easy :)

## Pull requests

Some basic info on [pull requests](http://help.github.com/send-pull-requests/).

When doing a pull request, make sure to:

* rebase your work off the latest master
* name your topic branch by the issue number 
  (like [BVAL-42](https://hibernate.onjira.com/browse/BVAL-42))
* rebase your work rather than merge, non linear histories are annoying
* respect the style (coding, number of columns per line etc)

## Recommended tools to edit the Docbook specification

By decreasing order of preference:

1. [XMLMind XML Editor](http://www.xmlmind.com/xmleditor/)
2. Any XML editor

Make sure to not go beyond 80 columns per line.
