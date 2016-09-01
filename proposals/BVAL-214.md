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

## Proposition 1

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

## Proposition 2

This proposition is based on **Proposition 1** but changes some parts of the API.

Since we depend on java 8 I think it would make sense to use `Supplier` to create the bean mocks for validation. This can look like this:

    BeanValidator<ContactDataModel> contactValidator = BeanValidator.build(ContactDataModel.class);
    contactValidator.withProperty("city", () -> cityField.getText()).
        withProperty("zipCode", () -> zipCodeField.getText());

In this example the `contactValidator` can use several times to validate the input in the UI since the values are not definied at creation of the `BeanValidator` instance but a `Supplier` is used to provide the value at runtime. By doing so the `BeanValidator` can be defined as:

    public interface BeanValidator<T> {
    
        <V> BeanValidator<T> withProperty(String propertyName, Supplier<V> valueSupplier);
    
        Set<ConstraintViolation<T>> validate(Class<?>... groups);
    
        Set<ConstraintViolation<T>> validate(T baseBean, Class<?>... groups);
    
        static <U> BeanValidator<U> build(Class<U> beanClass) {
            return ...;
        }
    }

As you can see the interface provides 2 methods to validate a bean. In the second method a predefined bean can be passed. This bean will be mutated / cloned based on the configuration of the `BeanValidator`.

If you want to define a hierarchy of beans and validate them you need at least one additional method:

    <U> BeanValidator<T> withBeanValidator(String propertyName, BeanValidator<U> propertyValidator);

By using this methods it will be quite easy to provide a structured mock for a bean type:

    BeanValidator<ContactDataModel> contactValidator = BeanValidator.build(ContactDataModel.class);
        contactValidator.withProperty("city", () -> cityField.getText()).
                withProperty("zipCode", () -> zipCodeField.getText());

    BeanValidator<SampleDataModel> validator = BeanValidator.build(SampleDataModel.class);
        validator.withProperty("name", () -> nameField.getText());
        validator.withBeanValidator("contact", contactValidator);

In addition I think that it will be important to have a better feedback for the violations that are based on a UI field. If you have a violation based on the text of the `cityField` you normally want to mark that field in the UI. I think a `Consumer` can really help here:

    contactValidator.withProperty("city", () -> cityField.getText(), v -> markCityField(v));
    
By doing so you will always get the set of violations that is based on the value in the city field. The 3 param of the method is defined as a `Consumer<Set<ConstraintViolation<String>>>` that will automatically called after each validation. If no violation was created based on the constraints of the `city` property an empty set will be passed to the `Consumer`. Otherwise the set will contain all the `ConstraintViolation` instances that were created based on the constraints of the `city` property.

It's quite easy to create helper methods for the consumer and the supplier in application code:
 
    private Supplier<String> provideText(final TextField textField) {
         return () -> textField.getText();
     }
 
     private Consumer<Set<ConstraintViolation<String>>> markTextField(final TextField field) {
         return v -> {
             if (v.isEmpty()) {
                 field.getStyleClass().remove("error-class");
             } else {
                 //TODO: show error at textfield based on violations
                 field.getStyleClass().add("error-class");
             }
         };
     }
     
     //Create BeanValidator:
     BeanValidator<ContactDataModel> contactValidator = BeanValidator.build(ContactDataModel.class);
             contactValidator.withProperty("city", provideText(cityField), markTextField(cityField)).
                     withProperty("zipCode", provideText(zipCodeField), markTextField(zipCodeField));
     
     BeanValidator<SampleDataModel> validator = BeanValidator.build(SampleDataModel.class);
             validator.withProperty("name", provideText(nameField), markTextField(nameField));
             validator.withBeanValidator("contact", contactValidator);
     
After all this changes the `BeanValidator` interface might look like this:

    public interface BeanValidator<T> {
    
        <V> BeanValidator<T> withProperty(String propertyName, Supplier<V> valueSupplier);
    
        <V> BeanValidator<T> withProperty(String propertyName, Supplier<V> valueSupplier, Consumer<Set<ConstraintViolation<V>>> propertyViolationConsumer);
    
        <U> BeanValidator<T> withBeanValidator(String propertyName, BeanValidator<U> propertyValidator);
    
        Set<ConstraintViolation<T>> validate(Class<?>... groups);
    
        Set<ConstraintViolation<T>> validate(T baseBean, Class<?>... groups);
    
        static <U> BeanValidator<U> build(Class<U> beanClass) {
            return null;
        }
    }


You can find a first idea of such an interface and 2 view controller examples here: https://github.com/guigarage/validation-playground/tree/master/src/main/java/com/guigarage/dynamicvalidation
