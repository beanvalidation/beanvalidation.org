---
title: Bean Validation 1.1 CR3 - Final Approval Ballot
author: Emmanuel Bernard
layout: news
tags: [release]
---
Bean Validation, Hibernate Validator (its Reference Implementation) and the
Test Compatibility Kit have been handed over to the JCP for what is called the
Final Approval Ballot. That's when the expert committee votes for the go /
no-go of the specification going final as it is.

We have found a few glitches when working on both the RI and the TCK in the
last month but everything is in order now. The biggest visible change for you
is that we renamed `@ValidateExecutable` into `@ValidateOnExecution` and we added a
way to disable method validation entirely via the XML deployment descriptor.

We worked hard to make a stellar TCK. Let's speak numbers: the specification
has **549 assertions** including **492 testable**. We cover **98,8%** of them
with **1500 tests**. Good luck to all future Bean Validation 1.1 implementors
:)

Everything is already available for you to use:

- [the specification](http://beanvalidation.org/1.1/spec/1.1.0.cr3/)
- [Hibernate Validator (the
  RI)](http://www.hibernate.org/subprojects/validator/download)
- [the TCK](http://www.hibernate.org/subprojects/validator/download)

Enjoy!
