---
title: Additional resources
layout: default
author: Guillaume Smet
---

Bean Validation is more than a specification, it is also a vivid ecosystem.

We list here some additional resources you might find useful when using
Bean Validation.

If you know of others that might be of interest to our users, contact us on the
[Bean Validation development mailing list](mailto:beanvalidation-dev@lists.jboss.org)
so that we can add them here.

## Additional constraints

### For Bean Validation 2.0 (JSR 380)

 * [Hibernate Validator](http://hibernate.org/validator/) includes a set of additional built-in constraints (see [the reference documentation](https://docs.jboss.org/hibernate/stable/validator/reference/en-US/html_single/#validator-defineconstraints-hv-constraints))
 * [Java Bean Validation Extension](https://github.com/nomemory/java-bean-validation-extension) offers a set of useful constraints (`@Alphanumeric`, `@IPv6`, `@StartsWith`...).
 * [The validation project of Markus Malkusch](https://github.com/malkusch/validation) provides another set of constraints (`@BitcoinAddress`, `@ISBN`...).
 * [A nice example of password validator](https://github.com/Baeldung/spring-security-registration/blob/master/src/main/java/org/baeldung/validation/PasswordConstraintValidator.java) based on [Passay](http://www.passay.org/), a password policy enforcement library.

### For Bean Validation 1.0 and 1.1

[Collection Validators](https://github.com/jirutka/validator-collection) allows to define constraints on elements of collections.

In Bean Validation 2.0, you can use type use constraints (e.g. `List<@NotBlank String>`) for that.
