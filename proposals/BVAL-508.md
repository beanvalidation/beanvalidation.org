---
title: Validating elements contained in a container (like collections)
layout: default
author: Emmanuel Bernard
comments: true
---

# #{page.title}

[Link to JIRA ticket][jira]  
[Related JIRA](https://hibernate.atlassian.net/browse/BVAL-499)  

## Problem

It is useful to be able to apply constrains on elements contained in a so called _container_.
Examples of containers are:

* `Collection`
* `Optional`
* JavaFX's `Property`

But today the constraints are applied on the container value itself and not its content.

## Proposition

### Containers

Bean Validation will offer the notion of container of values to validate.
Containers can contain one value, or several values.
Extractors for specific containers can be implemented.

TODO: should we differentiate single and plural?

    // Draft proposal for the contract
    public interface SingleContainerValueExtractor<CONTAINER,CONTAINED> {
        CONTAINED extractValue(CONTAINER container);
    }
    
    public interface ManyContainerValuesExtractor<CONTAINER,CONTAINED> {
        Iterable<CONTAINED> extractValue(CONTAINER container);
    }
    
    // Examples
    
    //TODO can T remain unspecified? or should it be ? or Object?
    public class OptionalContainerExtractor<T> implements SingleContainerValueExtractor<Optional<T>,T> {
        T extractValue(Optional<T> optional) { ... };
    }

Bean Validation will have out of the box support for containers for `Iterable` and `Map`.

TODO: any other Java SE type to consider?
TODO: should we support JavaFX Property<T>?

Custom container extractors can be provided via:

* property
* factory
* service locator

TODO: refine how the container implementations are discovered.
See [Hibernate Validator's feature](http://docs.jboss.org/hibernate/validator/5.2/reference/en-US/html_single/#section-value-handling) 

#### When are containers used?

When a property is of a known container, constraints declarations are explored.
A typical example is a property using constraints on type parameters of `TYPE_USE` (`Collection<@Size String>`).

If constraints are discovered, the unwrapping mechanism is used
to read contained value(s) and potentially apply constraints on them (see below).

By constraints, we also mean property traversal `@Valid`.

Containers of containers are applied recursively if necessary.
TODO: infinite loops?

#### Which container unwrapper to use?

The container used is the one corresponding to the most specific super type
as defined in the BV resolution of constraint validators.

### Constraints applied and containers

Constraints declared on the type parameter of a type use will be applied to the contained value
as extracted by the container logic.

    // each String of the collection is validated for the regexp
    Set<@Pattern(...) String> emails;

By default, constraints declared on the container will apply to the container.
This ensures backward compatibility.

    // @Size is applied on the collection
    @Size(min=5) List<Integer> ages;

Extractors can specify that constraints declared on the container apply to the contained value(s);

    @ConstraintsApplyTo(CONTAINED_VALUES)
    public class JavaFXPropertyContainerExtractor<T> implements SingleContainerValueExtractor<Property<T>,T> { ... }
    
    // test that the age is at least 5
    @Min(5) IntegerProperty<Integer> age;

This is useful for JavaFX to force the validation of the contained properties.

One can also force the constraints to apply to the container or the container value per site

    // the list must have 5 elements at least
    @ConstraintsApplyTo(CONTAINED_VALUES)
    @Size(min=5)
    Optional<List<Integer>> ages;
    
    class IntegerList extends ArrayList<Integer> {};
    
    // the list must have 5 elements at least
    @ConstraintsApplyTo(CONTAINED_VALUES)
    @Min(2)
    IntegerList ages;
    

Note that the preferred form is `List<@Min(2) Integer> ages;`.

`@ConstraintApplyTo` offers a way to define at which level nested container resolution stops (if necessary).
Not by an explicit depth level but rather by its placement.

TODO: should we offer a per annotation override:
`@NotNull(validAppliedTo=CONTAINED_VALUE)`.
The drawback is that old annotations will have to add the new attribute to offer the option.

#### `@ConstraintsApplyTo` Value for built-in containers

`Optional` defaults to `CONTAINER`.
`Iterable` and `Map` default to `CONTAINER`.
JavaFX `Property<T>` defaults to `CONTAINED_VALUES`.

The default for JavaFX property differs
because in this community the idiom `IntegerProperty` prevails over `Property<Integer>`.

#### Alternative model (not preferred)

If a constraint is valid for specific types (say `@Size` for `Collection`, and `String`),
it is possible to disambiguate the application of the constraint on the container vs the contained value.
In particular for JavaFX.


    // test that the age is at least 5
    // since IntegerProperty extends Property which are not supported by Size
    // but that String is supported for Size
    @Size(5) StringProperty<String> name;

In case the container and the contained values are both supported by a give constraint,
`@ConstraintsApplyTo` becomes mandatory.

This model is fully deterministic but:

* is hard to grasp and requires advanced knowledge of the constraint validators + conrtainers / contained values to decypher
* breaks for common constraints like `@NotNull`, `@Size`, `@Min` especially when containers are collections

I propose not to apply it and use the extractor level `@ConstraintsApplyTo(CONTAINED_VALUES)` as a solution.


### Type parameter and constraint propagation

    // @NoNull is applied on a type parameter
    class CustList extends List<@NotNull Customer> {
    }

When and where to apply the not null ? Getters, setters, return types, parameter types?

    class Foo<T> {
        T getSome();
        void setFoo(T t);
        T retrieveOther();
        void processSome(T t);
    }
    
    class Bar extends Foo<@NotNull String> {
    }

Concern what that does, not obvious?
Second concern is where is it useful?

Proposal: not including this templating feature in the first version of the spec.

### "Crazy" Type use

Java 8 annotations can be placed on all type use

    // type use
    @NotNull String name = "Emmanuel";
    new @NonEmpty @Readonly List<String>(myNonEmptyStringSet)
    myString = (@NonNull String) myObject;
    @Vernal Date::getDay
    
Type use outside parameterized containers won't be used in Bean Validation - at least for now.
Implementing constraint validation in these general areas would require a very instrumented code
using a powerful bytecode manipulation engine.
The implications of the locations annotations is unknown.

### Remaining TODOs

Should `@NotNull` be applied on both the container and contained for a single container?

Should we have a BV 1.1 based logic that forces to use a global `@ConstraintsApplyTo(CONTAINER)`
to enforce strict backward compatibility.
And a BV 2.0 based logic (driven by the XML version?) would have the right ergonomics as described above?

## Alternative proposal: Consider type-constraints as instance-specific amendment of constraint set (Gunnar)

Currently, constraint meta-data is fixed for a given type by annotating the type's class definition or configuring it in XML.
This proposal allows to amend that statically defined constraint meta-data with instance-specific meta-data applied to generic parameters declared by the type.

Example:

    public class Tuple<V1, V2> {

        @NotNull
        private V1 v1;

        @NotNull
        private V2 v2;

        public V1 getV1() { return v1; }
        public V2 getV2() { return v2; }
    }

    public class User {

        @Valid
        private Tuple<String, @Min(1) Integer> nameAndAge = ...;
    }

Calling `Validator#validate( new Tuple(...) )` will validate the `@NotNull` constraints statically declared in the `Tuple` class.
Calling `Validator#validate( new User(...) )` will validate the `@NotNull` constraints *and* the instance-specific `@Min` constraint given for the `V2` type parameter.

**Question:** How to obtain the property value, getter vs. field access?

**Proposal:** Iterate all getters and apply the constraint to all those matching the annotated type (V2); Then iterate all fields and apply to all those matching the annotated type and where no getter for that property has been validated in the first step. I.e. prefer getter over field access.

### Constraints of collection elements

This proposal makes the case of constraints on collection elements (list etc.) very regular.

Example:

    @ValidAddress
    public class Address {}

    public class User {

        @Valid
        private List<@Exists Address> addresses;
    }

This adds the `@Exists` constraint to constraint metadata for `<T>` of the `emails` list (i.e. in addition to the statically defined `@ValidAddress` )
When validating a `User`, the engine will access `<T>` during cascaded validation (by invoking `List#getIterator()` or similar).
Then both constraints, `@Exists` and `@ValidAddress` will be applied.

This avoids any assumptions about the type parameter of the collection instance.
Specifically, it's not guaranteed that the type parameter of the instance actually represents the one we might think (e.g. `<T>` of `List`):

    public interface IdentifiedStringList<I> extends List<String> {
        I getIdentifier();
    }

    @Valid
    private IdentifiedStringList<@Min(1) Long> myLongIdentifiedStringList = ...;

Here the `@Min` constraint must not be applied to the collection elements as it doesn't relate to `<T>` of `List` but `<I>` of `IdentifiedStringList`.

### Obtaining values from containers

Currently cascaded validation applies to bean references and collections (`Collection`, `Map`, arrays).
This proposal suggests to open that up, allowing to provide support for other cascadable types, e.g. `Optional`:

    @Valid
    private Optional<@Size(max=20) String> name;

When encountering `@Valid`, we'll look for matching extractor implentations:

    public interface ValueExtractor {}

    public interface SingleValueExtractor<O, I> extends ValueExtractor {
        I extractValue(O outer);
    }

    public interface CollectionValueExtractor<O extends Iterable<I>, I> extends ValueExtractor {
        Iterator<I> extractValues(O outer);
    }

    public class OptionalValueExtractor<T> implements SingleValueExtractor<Optional<T>, T> {
        T extractValue(Optional<T> optional) {
            return optional.get();
        }
    }

A conforming implementation provides out-of-the-box extractor implementions for bean references (used by default) and collections.

Representing the `Optional` case in this generic fashion is nice, but two shortcomings need to be addressed:

* There should be no element in the constraint violation path for the wrapped element, only the container itself
* The explicitly required `@Valid` makes it more verbose

This could be mitigated by letting value extractors make this configurable:

    public interface ValueExtractor {
        boolean addPathNodeForExtractedValue();
        boolean autoApply();
    }

    public class OptionalValueExtractor<T> implements SingleValueExtractor<Optional<T>, T> {
        T extractValue(Optional<T> optional) {
            return optional.get();
        }

        boolean addPathNodeForExtractedValue() {
            return false;
        }

        boolean autoApply() {
            return true;
        }
    }

That way, previous example could look like so, i.e. without `@Valid`:

    private Optional<@Size(max=20) String> name;

**Explicitly not supported:** Applying constraints to container types with the intention of targetting the wrapped value.
I.e. the following would not work:

    // No validator for @Size+String
    @Size(max=20)
    private Optional<String> name;

Maybe that's ok, as in most cases there will be a type parameter. For JavaFX with its types such as `IntegerProperty` we could require compatible implementations to provide the required validator implementions e.g. for `@Min` + `IntegerProperty`. Or we ignore that, I've never heard of demand.

## Attic

### Type use annotations vs enlisting unwrapping logic

Type use located annotations open opportunity to express the constraints elegantly.

    // Collection of non null Strings
    Collection<@NotNull String> names;

Note however that this does not work if the constraint is applied on a subtype of the parameterized type.

    // this works
    Collection<@NotNull String> names;
    
    public StringCollection extends Collection<String> {
    }
    
    // Where to put the @NotNull?
    StringCollection names;

For the latter, one option is to enlist an explicit unwrapper (see [Hibernate Validator's feature](http://docs.jboss.org/hibernate/validator/5.2/reference/en-US/html_single/#section-value-handling) ).
An unwrapper will apply some unwrapping logic for well known types.
It needs to be registered globally (`ValidatorFactory` or service locator based).
For unwrapped properties would consider the annotations hosted on the wrapper

    class StringCollectionUnwrapper implements ValidatedValueUnwrapper<StringCollection> { ... }

    @NotNull //applied on the elements of the collection
    StringCollection names;

TODO: What to do about nested unwrappers?
Go to the deepest?
What to validate for: `@Min(23)` `List<IntegerProperty> bar`? `List` vs. `IntegerProperty` vs. wrapped `Integer`?
What about `Optional<Optional<String>>`? Should we unwrap recursively?


## Generic mechanism vs special cases

Should collections, optional, javafx properties be all handled by a unified model
or should they be specific?

## Generic container notion

Offer an service provider offering a way to consider and navigate the element(s) of a container.
Container, Optional and Property will be provided as is but other container can be generalized.

BTW: Container can be anything Iterable.

[jira]: https://hibernate.onjira.com/browse/BVAL-508
