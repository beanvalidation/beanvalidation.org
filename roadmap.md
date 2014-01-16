---
title: Bean Validation roadmap
layout: default
author: Emmanuel Bernard
---

# #{page.title}

We have seriously reduced our stock of todos with the release of Bean
Validation 1.1 but we still have a few things we would like to put in the
specification eventually.  Most of them require some experimentation in
Hibernate Validator or the other Bean Validation implementations out there.
After feedback they will be ready to be folded back in the specification.

We encourage you to follow the Hibernate Validator [roadmap](http://hibernate.org/validator/roadmap/). We
have also a left over from Bean Validation 1.1 described below.


### Next revision  <a id="next"></a>

| Issue Id (JIRA)                                           | Done | Proposal | Description |
| --------------------------------------------------------- | ---- | -------- | --------------------------- |
| [BVAL-199](https://hibernate.onjira.com/browse/BVAL-199)  |  |  | Offer helper classes to build and potentially raise ConstraintViolationExceptions 
| [BVAL-202](https://hibernate.onjira.com/browse/BVAL-202)  |  |  | Apply constraints on the elements of an iterator
| [BVAL-210](https://hibernate.onjira.com/browse/BVAL-210)  |  |  | Make sure JTA / Java EE plays well with Bean Validation + JPA when exceptions occurs (at least raise the concern upstairs ;) )
| [BVAL-211](https://hibernate.onjira.com/browse/BVAL-211)  |  |  | Consider making javax.validation.ValidatorContext a self-referential generic type
| [BVAL-213](https://hibernate.onjira.com/browse/BVAL-213)  |  |  | Convert persistence storage exception into Bean Validation exceptions
| [BVAL-214](https://hibernate.onjira.com/browse/BVAL-214)  |  |  | Ability to validate an object and a list of changes
| [BVAL-215](https://hibernate.onjira.com/browse/BVAL-215)  |  |  | Make composition more flexible (OR support)
| [BVAL-216](https://hibernate.onjira.com/browse/BVAL-216)  |  |  | Work with the JAXB EG to have a nice Bean Validation integration
| [BVAL-217](https://hibernate.onjira.com/browse/BVAL-217)  |  |  | Separate the notion of message resolver vs message interpolator
| [BVAL-220](https://hibernate.onjira.com/browse/BVAL-220)  |  |  | Offer stereotypes to skip validation on empty or null
| [BVAL-222](https://hibernate.onjira.com/browse/BVAL-222)  |  |  | Add a ALL group to validate all groups instead of DEFAULT or the selected ones
| [BVAL-225](https://hibernate.onjira.com/browse/BVAL-225)  |  |  | Propose ability to provide default resource bundles (for a constraint definition provider)
| [BVAL-229](https://hibernate.onjira.com/browse/BVAL-229)  |  |  | Offer a programmatic API to declare constraints on a domain model
| [BVAL-233](https://hibernate.onjira.com/browse/BVAL-233)  |  |  | Provide access to contextual info during message interpolation
| [BVAL-234](https://hibernate.onjira.com/browse/BVAL-234)  |  | [234](/proposals/BVAL-234) | Ignore @NotNull on JPA's @GeneratedValue properties for pre-persist operations
| [BVAL-235](https://hibernate.onjira.com/browse/BVAL-235)  |  |  | Support parameterized payload attributes (additional string param on @Payload) 
| [BVAL-237](https://hibernate.onjira.com/browse/BVAL-237)  |  |  | Expose validated bean via ConstraintValidatorContext
| [BVAL-240](https://hibernate.onjira.com/browse/BVAL-240)  |  |  | Revisit cross-field validation
| [BVAL-248](https://hibernate.onjira.com/browse/BVAL-248)  |  | [248](/proposals/BVAL-248) | Introduce an evaluation order for constraints on a single property 
| [BVAL-251](https://hibernate.onjira.com/browse/BVAL-251)  |  |  | Improve Bean Validation support for modularized environments
| [BVAL-252](https://hibernate.onjira.com/browse/BVAL-252)  |  |  | Improve support for the creation of constraint libraries
| [BVAL-268](https://hibernate.onjira.com/browse/BVAL-268)  |  |  | Align with the EE platform on where to find validation.xml
