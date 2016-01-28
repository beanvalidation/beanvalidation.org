---
title: Validate a list of changes without applying them to the actual object
layout: default
author: Gunnar Morling
comments: true
---

# #{page.title}

[Link to JIRA ticket][jira]  
[Related JIRA](https://hibernate.atlassian.net/browse/BVAL-214)  

## Problem

When validating user input from a UI which is bound to the data model it is desirable to do the validation *before* propagating the values into the model.
This prevents the model from being tainted with invalid values.
For single properties there is `Validator#validateValue()` for this purpose, but an equivalent solution for class-level constraints is lacking today.

## Proposition

Provide a new method `<T> Set<ConstraintViolation<T>> Validator#validateValues(T bean, Map<String, Object> values, Class<?>... groups)`.
This takes a bean instance and a map of property values.
These values will be applied to a *clone* of the given object which then is validated.

### Pros

* The solution is transparent to class-level constraints, they'd see the validated bean as if it had the given property values
* No need to pass in values through the map which haven't changed in the bean
### Cons

* Requires validated bean types to be clonable; That's a nasty requirement, esp. when it comes to JPA entities with lazy props etc.

The requirement for clonability could possibly be mitigated by introducing a cloning SPI. By default, BV providers would resort to expecting beans to implement `Cloneable`. But alternative implementations could be based on less intrusive cloning approaches such as resorting to copy constructors or libraries such as https://github.com/kostaskougios/cloning

## Alternative proposal

Provide a new method `<T> Set<ConstraintViolation<T>> Validator#validateValues(Class<T> beanType, Map<String, Object> values, Class<?>... groups)`.
This takes a bean type and a map of property values.
A *proxy* is created for the bean type which returns the values from the map when property accessors are invoked. This proxy is validated.

### Pros

* Requirement for proxyability is less intrusive then for clonability
* No bean instance needed, resembles more closely the current `validateValue()` method

### Cons

* Solution is not transparent to class-level constraint validators; If they use field access in `isValid()` we cannot feed in the values given in the map; The same applies for `@AssertTrue isValid()` in-bean validation methods
* Values for all properties (accessed by validators) must be given in the map

IMO only the clone-based solution brings any benefit. The feature request addresses upfront validation of class-level constraints, so if they don't work, it's not much value to it.
