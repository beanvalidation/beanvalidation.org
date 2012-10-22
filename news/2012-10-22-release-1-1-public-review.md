---
title: Public Review Draft for Bean Validation 1.1
author: Emmanuel Bernard
layout: news
tags: [release]
---
Last Friday I have handed over the Public Review Draft to the JCP.

Beyond the new features and polishing of existing ones (see below),
the Public Review Draft marks the point where:

- the community at large is invited to comment on the specification before the last
  leg of work towards the final release starts
- the JCP executive commitee votes on the current work at the end of the review
  period

We have been doing our work in the open but if you have not yet paid much attention
now is the time to fix that :)

You can [access the draft on this website][draft].
All changes are marked with a different
color. <span style="background-color:#DDFFDD;">Green for additions</span>, 
<span style="background-color:#FFFFDD;">yellow for changes</span> and 
<span style="text-decoration: line-through;background-color: #FFDDDD;">struck through red for removals</span>
. This will help you see what has changed precisely.

Please send us your remarks and comments:

- on our [mailing list][mailing list]
- in our [issue tracker][issues]
- or on the Bean Validation [forum][forum]

If you want to go to the next step and contribute, send us an email to
the mailing list and read [how to contribute][contribute].

## What's new in this draft

A lot of work has been done to polish or rework the features introduced
in the first draft. We have also added a few additional improvements:

- improved integration with CDI: dependency injection, component
  lifecycle management and interception for method validation
- add rules describing method validation in particular how an interception
  technology ought to integrate: this will offer better portability
- add support for cross parameter validators on method validation
- add metadata APIs to identify constrained methods
- add support for group conversion (i.e., change the targeted group when
  cascading validation)
- clarify that composed constraints should fail fast when `@RepostAsSingleViolation`
  is present
- support `CharSequence` (used to be `String`) for built-in constraints

## Contributions

As usual, many thanks to the community for its feedback, the expert group for its
work. Special thanks to Gunnar and Hardy who worked round the clock this past two
weeks to integrate all planned improvements in the specification document.

[contribute]: /contribute/
[draft]: /1.1/spec/1.1.0.beta1/?utm_source=blog&utm_medium=web&utm_content=spec&utm_campaign=1_1_pr1
[issues]: /issues
[forum]: https://forum.hibernate.org/viewforum.php?f=26
[mailing list]: https://lists.jboss.org/mailman/listinfo/beanvalidation-dev
