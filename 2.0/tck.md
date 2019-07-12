---
title: Jakarta Bean Validation 2.0 TCK
layout: default
author: Hardy Ferentschik, Guillaume Smet
---

A TCK, or Technology Compatibility Kit, is one of the three required pieces for any Jakarta EE specification
(the other two being the specification document and the reference implementation). The TCK is a set
of tools and tests to verify that an implementation of the technology conforms to the specification.

The Jakarta Bean Validation 2.0 TCK is licensed under the Apache Software License 2.0 and hosted in a GitHub
[repository](https://github.com/eclipse-ee4j/beanvalidation-tck).
The repository consists of multiple artifacts, containing tooling, documentation and most importantly
a set of [Arquillian](http://arquillian.org/) tests. There are also two
[setup examples](https://github.com/eclipse-ee4j/beanvalidation-tck/tree/master/setup-examples),
demonstrating the setup of the test harness using Maven and Ant.

The latest version used to test Jakarta Bean Validation 2.0 is 2.0.5.

Distribution bundles are available on the
[Eclipse download infrastructure](https://download.eclipse.org/jakartaee/bean-validation/2.0/) and come as
[ZIP](http://download.eclipse.org/jakartaee/bean-validation/2.0/beanvalidation-tck-dist-2.0.5.zip)
or [TGZ](http://download.eclipse.org/jakartaee/bean-validation/2.0/beanvalidation-tck-dist-2.0.5.tar.gz)
archive.
They contain JARs, documentation, source code, et al.

You can find the TCK reference manual also online in two different formats -
[HTML](http://docs.jboss.org/hibernate/beanvalidation/tck/2.0/reference/html_single/),
[PDF](http://docs.jboss.org/hibernate/beanvalidation/tck/2.0/reference/pdf/beanvalidation-tck-documentation.pdf).

To report a bug or challenge a test use our [issue tracker](https://github.com/eclipse-ee4j/beanvalidation-tck/issues).
