---
title: Additional resources
layout: default
author: Guillaume Smet
---

Jakarta Bean Validation is more than a specification, it is also a vivid ecosystem.

We list here some additional resources you might find useful when using
Jakarta Bean Validation.

If you know of others that might be of interest to our users, contact us on the
[Jakarta Bean Validation development mailing list](mailto:bean-validation-dev@eclipse.org)
so that we can add them here.

## Additional constraints

### For Jakarta Bean Validation 2.0

Nothing new. Jakarta Bean Validation 2.0 is based on Bean Validation 2.0.

### For Bean Validation 2.0 (JSR 380)

 * [Hibernate Validator](http://hibernate.org/validator/) includes a set of additional built-in constraints (see [the reference documentation](https://docs.jboss.org/hibernate/stable/validator/reference/en-US/html_single/#validator-defineconstraints-hv-constraints))
 * [Java Bean Validation Extension](https://github.com/nomemory/java-bean-validation-extension) offers a set of useful constraints (`@Alphanumeric`, `@IPv6`, `@StartsWith`...).
 * [The validation project of Markus Malkusch](https://github.com/malkusch/validation) provides another set of constraints (`@BitcoinAddress`, `@ISBN`...).
 * [A nice example of password validator](https://github.com/Baeldung/spring-security-registration/blob/master/src/main/java/org/baeldung/validation/PasswordConstraintValidator.java) based on [Passay](http://www.passay.org/), a password policy enforcement library.
 * The library [Lib-Validation](https://github.com/Naoghuman/lib-validation) from [Peter Rogge](https://github.com/Naoghuman) is developed with the goal to provide validation functionality for JavaFX applications. It also provides custom constraints, e.g. [@NewDuration](https://github.com/Naoghuman/lib-validation/blob/master/src/main/java/com/github/naoghuman/lib/validation/core/annotation/NewDuration.java).

### For Bean Validation 1.0 and 1.1

[Collection Validators](https://github.com/jirutka/validator-collection) allows to define constraints on elements of collections.

In Bean Validation 2.0 and Jakarta Bean Validation 2.0, you can use type use constraints (e.g. `List<@NotBlank String>`) for that.
