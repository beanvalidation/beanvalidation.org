---
title: Bean Validation roadmap
layout: default
author: Emmanuel Bernard
---

# #{page.title}

Bean Validation standardizes constraint definition, declaration and validation for the Java platform. Its first incarnation has been widely popular amongst the Java community in both SE and EE environments.

Being a version 1.0, Bean Validation stayed on the conservative side feature wise. The community has expressed interest in additional features to enhance the work done in the first version of the specification.

The work of the Expert Group will be around the following main topics:

### Integration with other JSRs

While not part of the Bean Validation specification per se, we want to pursue further collaborative work with some other JSR leads on how to integrate Bean Validation into the various lifecycles of the SE/EE platforms. The work we did with JPA 2 and JSF 2 showed that it is possible and beneficial for the platform and developers.

* JAX-RS: call Bean Validation upon HTTP method calls on parameters and return values.
* JAXB: some people have asked for integration between Bean Validation and JAXB. Basically, the Bean Validation constraints (at least the fundamental ones) could be converted into the XML schema descriptor (and vice versa) to guarantee a unified propagation between the Java land and the XML land.
* JPA: improve the integration by letting Bean Validation constraints influence the DDL generated with the constraints declared on the entity model.
* CDI: offer a way for Bean Validation pluggable components to allow CDI style injection (in particular constraint validator implementations).
* CDI: integrate method-level validation (see below).
* EJB: integrate method-level validation (see below) - eg. validation of parameters and results of EJB business method calls.
* JSF: In addition to property-level constraints class-level constraints should be supported, offer support for client side validation based on Java side constraints (offered today by some JSF libraries).

These are propositions and starting points that will be run by the various expert groups. Based on these discussions, the Bean Validation expert group will adjust or add new features to the core of the Bean Validation specification as deemed necessary to achieve a successful integration. The Bean Validation expert group will also try and achieve consistent validation declaration and usage across the various specifications it integrates with to ensure Java SE/EE coherence.

### Method level validation

Offer APIs to validate parameters and return values of method calls. These APIs would be used by any injection or AOP framework around method invocations. If a constraint violation is detected, an exception (eg. ConstraintViolationException) would be raised.

### @Valid and group propagation

Ability to translate a group into another group while cascading the validation. This can help reduce the number of groups and increase reuse.

### Constraint composition
Extend the model to support both AND and OR style composition

### Clarification of ambiguities found in Bean Validation 1.0

### Better alignment with modular environments

### Exclusion flag on @BigDecimal / @BigInteger

In Bean Validation 1.0, boundaries are included by default and it is not possible to declare a boundary as excluded from the valid values

### ConstraintViolationException builder

Today Bean Validation clients need to assemble `ConstraintViolationException`s by hand.

### Conversion from persistence storage exception to Bean Validation exception

### Validate an object graph assuming a list of changes to be applied

### Separate the notion of MessageResolver and MessageInterpolator

### Consider interpolating the invalid value in error messages

### Offer stereotypes to skip validation on empty or null

### Apply constraints on the elements of an iterator

### Add formatter syntax for interpolated messages

### Provide a way for accessing default implementations for XML configured bootstrap artifacts

### Programmatic API to declare constraints (as opposed to annotations today)

Note that this list is not exhaustive but gives a good representation. Additional feature requests are available in Bean Validation's [issue tracker](/issues).

The goal of the Expert Group will be to assess these issues, prioritize them as well as identify and pursue directions for enhancement of the overall programming model and facilities of Bean Validation.