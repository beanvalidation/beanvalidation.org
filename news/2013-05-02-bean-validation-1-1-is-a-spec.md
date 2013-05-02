---
title: Bean Validation 1.1 is a spec
author: Emmanuel Bernard
layout: news
tags: [release]
---
It's now official, these couple of years of work have made it into [an
official JCP specification](http://jcp.org/en/jsr/results?id=5488).
Bean Validation is also part of Java EE 7 which has 
[been approved too](https://blogs.oracle.com/theaquarium/entry/java_ee_7_platform_completes)
a few of days ago.

We have already discussed the features at great length here but to do a short
summary:

- support for method and constructor validation (via CDI, JAX-RS etc)
- integration with CDI (`Validator` and `ValidatorFactory` injectable,
  `ConstraintValidator` instances being CDI beans and thus accept `@Inject`,
  etc)
- EL expressions based error messages
- group conversion in object graphs

I would like to thank the **expert group** and the **community** at large (without your
input there would be no 1.1), **Hardy** and **Gunnar** that worked round to clock on the
spec, the RI and the TCK and deliver everything on time, **Pete** for being my
springboard when all hell broke lose and the **folks at Oracle** who worked with us
to integrate Bean Validation with the rest of the Java EE ecosystem whether it
be spec, implementation or TCK.

Go grab [Hibernate Validator](http://validator.hibernate.org), the RI. The team
has even spent an extra couple of weeks to deliver a nice documentation. And if you
can't sleep, go read the [specification itself](/1.1/).
