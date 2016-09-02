---
title: Validate a list of changes without applying them to the actual object
layout: default
author: Gunnar Morling
comments: true
---

[Related JIRA](https://hibernate.atlassian.net/browse/BVAL-214)  

## Problem

When validating user input from a UI which is bound to the data model it is desirable to do the validation *before* propagating the values into the model.
This prevents the model from being tainted with invalid values.
For single properties there is `Validator#validateValue()` for this purpose, but an equivalent solution for class-level constraints is lacking today.

## Proposition

Provide a new method `Validator#validateValues()` similar to the existing `validateValue()` which takes several property values and validates them as if they were the actual values of the given bean types.

**TL;DR:** My preference is `validateValues(Class<T> bean, ValidatedValues values, Class<?>... groups)` and exposing values through the generic property retrieval API. I like that it doesn't require cloning and enables nice cross-field validation. I think the compatability issue with existing class-level validators is acceptable, people using that feature are very likely in control of that validator implementation and can adapt it.

The problem comprises two orthogonal challenges: How to pass in the values to be validated and how to expose these to constraint validators. Solutions for both are discussed below.

### How to pass in the values?

#### Using a map

Simply a `Map<String, Object> values`.

**Pro:**

* Similar to `validateValue()`
* Conceptually simple

**Cons:**

* Requires complete values for nested properties/collections
* Cannot distinguish between field/property level constraints

#### Using a builder API

E.g. some like this:

    ValidatedValues = new ValidatedValues.Builder()
        .property( "name" ).set( "Bob ")
        .list( "emails" ).add( "bob@example.com" )
        .set( "nickNames" ).remove ("Bobster" )
        .map( "addresses" ).key( "home" ).put( new Addres(...) )
        .property( "phone" ).property( "areaCode" ).set( 040 )
        .build();

`validateValues()` would take the built container.

**Pro:**

* Need only to pass changed values
* Can address single properties of nested elements
* Could use `ElementType` to express something is field vs. property value

**Cons:**

* API tough to get right?
* How much will "automated" / generic callers such as JSF benefit from it?

For identifying properties, method literals (for getters) could be used. Or the JPA metamodel? Or a new bean metamodel?

### How to represent the given values to constraint validators?

Orthogonal to the question how values are passed in we need to decide how to expose these to constraint validators.

#### By cloning a bean

`validateValue()` would take a bean *instance* and the values (assuming the builder approach for the sake of discussion for now):

    <T> Set<ConstraintViolation<T>> Validator#validateValues(T bean, ValidatedValues values, Class<?>... groups)

The values will be applied to a *clone* of the given object which then is validated.

**Pro:**

* The solution is transparent to existing class-level constraints, they'd see the validated bean as if it had the given property values

**Con:**

* Requires validated bean types to be clonable; That's a nasty requirement, esp. when it comes to JPA entities with lazy props etc.
* Need a bean *instance* which might not be present, esp. given the use case is up-front validation, so you might want to delay instantation until validation passed

The requirement for clonability could possibly be mitigated by introducing a cloning SPI. By default, BV providers would resort to expecting beans to implement `Cloneable`. But alternative implementations could be based on less intrusive cloning approaches such as resorting to copy constructors or libraries such as https://github.com/kostaskougios/cloning

####  Through a generic API from constraint validator context

`validateValue()` would take a bean *type* and the values:

    <T> Set<ConstraintViolation<T>> Validator#validateValues(Class<T> bean, ValidatedValues values, Class<?>... groups)

The values will be exposed through a generic property retrieval API:

    @PasswordsMatch
    public class UserDataBean {
        String name;
        String password;
        String passwordRepeat;
    }

    public class PasswordMatchValidator implements ConstraintValidator<PasswordsMatch, UserDataBean> {

        void initialize(PasswordsMatch annotation) {
        }

        boolean isValid(UserDataBean value, ConstraintValidatorContext ctx) {
            String password = null;
            String passwordRepeat = null;

            // value null can have two reasons here:
            // a) a null reference / collection entry during cascaded validation
            // b) validateValues(); In this case we can get the property values from the context
            if ( value == null ) {
                password = (String) ctx.property( "password" ).get();
                passwordRepeat = (String) ctx.property( "passwordRepeat" ).get();
            }
            else {
                password = value.password;
                passwordRepeat = value.passwordRepeat;
            }

            // TODO Make null-safe
            return password.equals( passwordRepeat );
        }
    }

The values would be exposed through the constraint validator context. The API would mirror the one using for passing values:

    ctx.property( "name" ).get();
    ctx.list( "emails" ).index( 1 ).get();
    ctx.map( "addresses" ).key( "home" ).get();
    ctx.property( "phone" ).property( "areaCode" ).get();
    ctx.map( "addresses" ).key( "home" ).property( "street" ).get();

**Pro:**

* No requirement for clonability towards validated bean types
* No bean instance needed, resembles more closely the current `validateValue()` method
* Enables much simpler cross-field constraints (see below)

**Cons:**

* Solution is not transparent to class-level constraint validators, they must account for the fact that values are to be obtained through the context; I think it's ok, but existing validators need updating.

This proposal enables cross-field constraints nicely:

    public class UserDataBean {
        String name;
        String password;

        @Equals("password")
        String passwordRepeat;
    }

    public class EqualsValidator implements ConstraintValidator<Equals, String> {

        private String compareTo;

        void initialize(Equals annotation) {
            this.compareTo = annotation.value();
        }

        boolean isValid(String value, ConstraintValidatorContext ctx) {
            if  ( value == null ) {
                return true;
            }

            String comparedValue = (String) ctx.property( compareTo ).get();
            return value.equals( comparedValue );
        }
    }

That's nicer than the traditional class-level constraint. The good thing is that it'd work automatically in both cases:

* `validate()` (provided we expose all the properties of the bean instance)
* `validateValues()` - here we'd take the values passed by the user

#### Through a proxy

Values passed to `validateValues()` could also be exposed through a proxy, but its disadvantages make it unattractive:

**Pros:**

* Requirement for proxyability is less intrusive then for clonability
* No bean instance needed

**Cons:**

* Not all beans can be proxied
* Solution is not transparent to class-level constraint validators, they must not access fields directly, so we'd still need a vehicle for field constraints
