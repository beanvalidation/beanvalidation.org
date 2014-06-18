---
title: Bean Validation TCKs now with support for Java SE 8
author: Gunnar Morling
layout: news
tags: [tck]
---

We have good news for those of you who want to certify the compatibility of a Bean Validation implementation (and its API JAR) on Java SE 8.

For that purpose we have released updates to the Bean Validation 1.0 and 1.1 TCKs;
The versions are 1.0.7.GA and 1.1.3.Final, respectively.
Both TCK releases come now with a version of the API signature file which works with Java SE 8.
This signature file can be used to assert API compatibility with JSR 303/349 with help of the [SigTest](https://wiki.openjdk.java.net/display/CodeTools/SigTest) tool.
SigTest 3.0 needs to be used from now on.
Note that the actual tests of the TCKs remain unchanged.

You can get distribution bundles with the new signature file from SourceForge ([1.0](http://sourceforge.net/projects/hibernate/files/beanvalidation-tck/1.0.7.GA/), [1.1](http://sourceforge.net/projects/hibernate/files/beanvalidation-tck/1.1.3.Final/)).

More information about the Bean Validation TCK can be found [here](http://beanvalidation.org/1.1/tck/).
Refer to the TCK reference guide ([1.0](https://docs.jboss.org/hibernate/beanvalidation/tck/1.0/reference/html_single/#sigtest), [1.1](https://docs.jboss.org/hibernate/beanvalidation/tck/1.1/reference/html_single/#sigtest))
if you would like to learn more about the process of asserting API compatibility.

Don't hesitate to [contact us](https://lists.jboss.org/mailman/listinfo/beanvalidation-dev) in case you have any questions around the Bean Validation specification in general or the TCK in particular.
