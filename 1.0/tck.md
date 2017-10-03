---
title: Bean Validation 1.0 TCK
layout: default
author: Hardy Ferentschik
---

A TCK, or Technology Compatibility Kit, is one of the three required pieces for any JSR
(the other two being the specification document and the reference implementation). The TCK is a set
of tools and tests to verify that an implementation of the technology conforms to the specification.

The Bean Validation 1.0 TCK is licensed under the Apache Software License 2.0 and hosted in a GitHub
[repository](https://github.com/beanvalidation/beanvalidation-tck).
The repository consists of multiple artifacts, containing tooling, documentation and most importantly
a set of [Arquillian](http://arquillian.org/) tests. There are also two
[setup examples](https://github.com/beanvalidation/beanvalidation-tck/tree/master/setup-examples),
demonstrating the setup of the test harness using Maven and Ant.

The Bean Validation 1.0 TCK is built using Maven.

The latest version used to test Bean Validation 1.0 (JSR 303) is 1.0.7.GA.

A distribution bundle is available on the SourceForge
[File Release System](http://sourceforge.net/projects/hibernate/files/beanvalidation-tck) and come as a
[ZIP](https://sourceforge.net/projects/hibernate/files/beanvalidation-tck/1.0.7.GA/jsr303-tck-1.0.7.GA-dist.zip/download)
archive.

You can find the TCK reference manual also online in two different formats -
[html](http://docs.jboss.org/hibernate/beanvalidation/tck/1.0/reference/html),
[html (single-page)](http://docs.jboss.org/hibernate/beanvalidation/tck/1.0/reference/html_single/).

To report a bug or challenge a test use our [issue tracker](https://hibernate.atlassian.net/browse/BVTCK).
