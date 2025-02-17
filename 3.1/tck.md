---
title: Jakarta Validation 3.1 TCK
layout: default
author: Hardy Ferentschik, Guillaume Smet
---

A TCK, or Technology Compatibility Kit, is one of the three required pieces for any Jakarta EE specification
(the other two being the specification document and the reference implementation). The TCK is a set
of tools and tests to verify that an implementation of the technology conforms to the specification.

The Jakarta Validation 3.1 TCK is licensed under the Apache Software License 2.0 and hosted in a GitHub
[repository](https://github.com/jakartaee/validation-tck).
The repository consists of multiple artifacts, containing tooling, documentation and most importantly
a set of [Arquillian](http://arquillian.org/) tests. There are also two
[setup examples](https://github.com/jakartaee/validation-tck/tree/main/setup-examples),
demonstrating the setup of the test harness using Maven and Ant.

The latest version used to test Jakarta Validation 3.1 is 3.1.1.

Distribution bundles are available on the
[Eclipse download infrastructure](https://download.eclipse.org/jakartaee/bean-validation/3.1/) and come as
[ZIP](https://download.eclipse.org/ee4j/bean-validation/3.1/validation-tck-dist-3.1.1.zip)
or [TGZ](https://download.eclipse.org/ee4j/bean-validation/3.1/validation-tck-dist-3.1.1.tar.gz)
archive.
They contain JARs, documentation, source code, et al.

To report a bug or challenge a test use our [issue tracker](https://github.com/jakartaee/validation-tck/issues).
