---
title: Bean Validation TCK 1.1.4.Final released
author: Gunnar Morling
layout: news
tags: [tck]
---

Exactly one year after the last maintenance release we've published version 1.1.4.Final of the Bean Validation TCK today.
It contains exactly one issue, [BVTCK-68](https://hibernate.atlassian.net/browse/BVTCK-68),
which is about the removal of two tests from the TCK which could not be tested in a portable manner across containers.
Check out the issue itself for the complete story.

As always, the new TCK version is available for download as TAR.GZ and ZIP on [SourceForge](http://sourceforge.net/projects/hibernate/files/beanvalidation-tck/1.1.4.Final/).
Alternatively you can obtain the test suite via Maven, Gradle etc. using the coordinates _org.hibernate.beanvalidation.tck:beanvalidation-tck-tests:1.1.4.Final_.

More information about the Bean Validation TCK can be found [here](http://beanvalidation.org/1.1/tck/) and the [TCK reference guide](https://docs.jboss.org/hibernate/beanvalidation/tck/1.1/reference/html_single/).
In case you have any questions or ideas around the Bean Validation specification in general or the TCK 
in particular, don't hesitate to contact us through [our mailing list](https://lists.jboss.org/mailman/listinfo/beanvalidation-dev).
