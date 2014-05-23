---
title: Bean Validation 1.1 TCK
layout: default
author: Hardy Ferentschik
---

# #{page.title}

A TCK, or Technology Compatibility Kit, is one of the three required pieces for any JSR 
(the other two being the specification document and the reference implementation). The TCK is a set 
of tools and tests to verify that an implementation of the technology conforms to the specification. 

The Bean Validation 1.1 TCK is licensed under the Apache Software License 2.0 and hosted in a GitHub 
[repository](https://github.com/beanvalidation/beanvalidation-tck).
The repository consists of multiple artifacts, containing tooling, documentation and most importantly 
a set of [Arquillian](http://arquillian.org/) tests. There are also two 
[setup examples](https://github.com/beanvalidation/beanvalidation-tck/tree/master/setup-examples), 
demonstrating the setup of the test harness using Maven and Ant. 

The Bean Validation 1.1 TCK is built using Maven and publishes project artifacts to the JBoss Maven Repository.
You can browse the available TCK releases 
[here](http://repository.jboss.org/nexus/content/groups/public-jboss/org/hibernate/hibernate-validator/).

The latest version used to test Bean Validation 1.1 (JSR 349) is:

    <dependency>
        <groupId>org.hibernate.beanvalidation.tck</groupId>
        <artifactId>beanvalidation-tck-tests</artifactId>
        <version>1.1.2.Final</version>
    </dependency>

Distribution bundles are available on the SourceForge [File Release System](http://sourceforge.net/projects/hibernate/files/beanvalidation-tck) and come as 
[ZIP](http://sourceforge.net/projects/hibernate/files/beanvalidation-tck/1.1.2.Final/beanvalidation-tck-dist-1.1.2.Final.zip/download) 
or [TGZ](http://sourceforge.net/projects/hibernate/files/beanvalidation-tck/1.1.2.Final/beanvalidation-tck-dist-1.1.2.Final.tar.gz/download) 
archive.
They contain jars, documentation, source code, et al.

You can find the TCK reference manual also online in three different formats - 
[html](http://docs.jboss.org/hibernate/beanvalidation/tck/1.1/reference/html), 
[html (single-page)](http://docs.jboss.org/hibernate/beanvalidation/tck/1.1/reference/html_single/), 
[PDF](http://docs.jboss.org/hibernate/beanvalidation/tck/1.1/reference/pdf/beanvalidation-tck-documentation.pdf).

To report a bug or challenge a test use our [issue tracker](https://hibernate.atlassian.net/browse/BVTCK).