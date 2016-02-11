---
title: Validating elements contained in a container (like collections)
layout: default
author: Emmanuel Bernard
comments: true
---

# #{page.title}

[Link to JIRA ticket][jira]  
[Related JIRA](https://hibernate.atlassian.net/browse/BVAL-499)  
[Java generics glossary](/glossary/)  

## Problem

It is useful to be able to apply constrains on elements contained in a so called _container_.
Examples of containers are:

* `Collection`
* `Optional`
* JavaFX's `Property`

But today the constraints are applied on the container value itself and not its content.

## Proposition 1

### Containers

Bean Validation will offer the notion of container of values to validate.
Containers can contain one value, or several values (`Optional` vs `Collection`).
A container can contain several types of values: a `Map` contains keys and values for example.

Extractors for the specific tuple container and value type can be implemented.

We differentiate single and plural for two reasons:

* we could have different functional rules depending on the case
* it avoids the unnecessary instantiation of an `Iterator` in the singular case


    // Draft proposal for the contract
    public interface SingleContainerValueExtractor<CONTAINER,CONTAINED> {
        CONTAINED extractValue(CONTAINER container);
    }
    
    public interface ManyContainerValuesExtractor<CONTAINER,CONTAINED> {
        Iterable<CONTAINED> extractValue(CONTAINER container);
    }
    
    // Examples
    
    public class OptionalContainerExtractor<T> implements SingleContainerValueExtractor<Optional<@ExtractedValue T>,T> {
        T extractValue(Optional<T> optional) { ... };
    }

Bean Validation will have out of the box support for containers `Iterable` and `Map`.

TODO: any other Java SE type to consider?
TODO: should we support JavaFX Property<T>?

Custom container extractors can be provided via:

* property describing the list of FQCN (in the XML configuration file for example)
* factory builder: offer an API to add extractor classes before building `ValidatorFactory`
* service locator: use the SL pattern to find the enlistable extractors

TODO: refine how the container implementations are discovered.
See [Hibernate Validator's feature](http://docs.jboss.org/hibernate/validator/5.2/reference/en-US/html_single/#section-value-handling) 

#### When are containers used?

When a property is of a known container, constraints declarations are explored.
A typical example is a property using constraints on type parameters of `TYPE_USE` (`Collection<@Size String>`).

If constraints are discovered, the unwrapping mechanism is used
to read contained value(s) and potentially apply constraints on them (see below).

Does that mean that if we find a type use constraint, there is no need for `@Valid`?

* that would allow us not to require `@Valid` for `Optional<@notNull String>`
* when constraint annotations are present on the member or method declaration itself,
  we also enforce the use of containers (assuming the proper use of `@ConstraintsApplyTo`)

Containers of containers are applied recursively if necessary.
TODO: infinite loops?

#### Which container extractor to use?

An extractor is associated to a container type (e.g. `Collection`) and a value type (e.g. the element of the collection).
For a given container + value type tuple,
the extractor used is the one targeting the most specific container type that is a supertype of the container.
Rules used are the same used by the constraint validator selection. TODO: handles interfaces?

Value type is the data returned by the extractor, for example:

* the collection elements
* the map keys
* the map values

Depending on where constraints are placed, they will be applied to one or the other value type.
The following rules apply to link the constraints to the value type and thus the extractor.

An extractor must annotate the type parameter it targets as value type with `@ExtractedValue`.

    // extract the key of a map: constraints on map keys are thus applied
    class MapKeyExtractor extends ManyContainerValuesExtractor<Map<@ExtractedValue Key,Value>>, Key> {
    }

`@ExtractedValue` can point to a specific supertype type parameter

    // declare List<T> as the type parameter targeted (index)
    class IntegerList extends ManyContainerValuesExtractor<@ExtractedValue(typeParameterHost=List.class, typeParameterIndex=0) IntegerList, Integer> {
    }
    
    // declare List<T> as the type parameter targeted (name)
    // probably a bit brittle
    class IntegerList extends ManyContainerValuesExtractor<@ExtractedValue(typeParameterHost=List.class, typeParameterName="E") IntegerList, Integer> {
    }

Note that it is possible that there are no type parameter associated to the extractor.
The constraints are hosted not on a type parameter but on the field or getter itself in conjunction with `@ConstraintsApplyTo(CONTAINED_VALUES)`.
See next section for a detailed explanation of `@ConstraintsApplyTo`.

    class SomeContainer { ... }
    
    class ExamplePojo {
        // constraint applies to what's inside SomeContainer
        @NotNull @ConstraintsApplyTo(CONTAINED_VALUE) SomeContainer foo;
    }
    
    class SomeContainerExtractor extends SingleContainerValueExtractor<@ExtractedValue SomeContainer,Containee> {
        ...
    }

In this case the type parameter is identified as an ad-hoc "no type parameter".

We can also enhance the extractor contract to return a generic `Path` object representing how navigation from the container to the value type happens (or is represented).
TODO: refine the `Path` approach. One specific question is around indexing of List or keys for Maps. Template?

##### Alternative approach: extractors returning `ValueAndPath`

Gunnar proposes an alternative to the extractor.
This alternative provides:

* one extractor per container type (and not container + value type)
* the extractor selected is the one matching the most specific super type of the container
    * only one extractor is executed per container

    interface SingleValueExtractor<I, O> {

        O extractValue(I input);

        // only invoked if invalid; Property name enough as input?
        // do we even need any input?
        Path.Node getNode(String property);
    }

    interface MultiValueExtractor<I, O> {

        ValueAndNodeIterator<O> extractValues(I input);

        // should it extend Java Iterator?
        public interface ValueAndNodeIterator<O> {

            boolean hasNext();

            O next();

            // Used to identify the location where constraints should be looked for
            TypeVariable<?> typeVariable();

            // only invoked if invalid; Property name enough as input?
            // might need to be Path instead of Path.Node
            Path.Node getNode(String property);
        }
    }

    // implementation example
    class MapExtractor implements MultiValueExtractor<Map, Object> {

        public ValueAndNodeIterator<Object> extractValues(Map input) {
            Set<Map.Entry<?, ?>> entrySet = input.entrySet();
            final Iterator<Map.Entry> iterator = input.entrySet().iterator();
            final TypeVariable<Class<Map>> k = Map.class.getTypeParameters()[0];
            final TypeVariable<Class<Map>> v = Map.class.getTypeParameters()[1];

            // returns alternatively key and value for each map entry
            return new ValueAndNodeIterator<Object>() {

                private boolean atKey = true;
                private Map.Entry<?, ?> current;

                public boolean hasNext() {
                    return iterator.hasNext();
                }

                public Object next() {
                    if ( atKey ) {
                        current = iterator.next();
                        atKey = false;
                        return current.getKey();
                    }
                    else {
                        atKey = true;
                        return current.getValue();
                    }
                }

                public TypeVariable<?> typeVariable() {
                    return atKey ? k : v;
                }

                public Node getNode(String property) {
                    // TODO Auto-generated method stub
                    return null;
                }
            };
        }
    }


In this approach, a container offering multiple value types (like `Map`) will have a unique extractor.
This extractor will return (an iterator of) the values and offer the ability to compute the `Path.Node`
and retrieve the `TypeVariable`.
For example the map extractor will return `2n` elements (for a map of `n`).

The `TypeVariable` is used to know which type parameter this value corresponds to.
Constraints will be looked on this type parameter - whether on the class itself or its subclasses.

Open questions and limitations:

* is `TypeVariable` both enough and necessary to express the type parameter targeted?
    * an alternative is to provide an object containing the same info as `@ExtractedValue`: parameter host and parameter index
    * At first sight, `TypeVariable` does not provide the parameter host information
* this model makes extractor resolution simpler as a single extractor is present per container
* but it does not allow extractor composition
    * a subclass of Collection with special extracting demands will need to reimplement the regular collection extraction logic as well as its custom one in one class

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
    @Min(5) IntegerProperty age;

This is useful for JavaFX to force the validation of the contained properties.

One can also force the constraints to apply to the container or the container value per site

    // the list must have 5 elements at least
    @ConstraintsApplyTo(CONTAINED_VALUES)
    @Size(min=5)
    Optional<List<Integer>> ages;
    
    class IntegerList extends ArrayList<Integer> {};
    
    // each age must be >= at 2
    @ConstraintsApplyTo(CONTAINED_VALUES)
    @Min(2)
    IntegerList ages;

Note that the preferred form is `List<@Min(2) Integer> ages;`.

Here is a scary example

    // each integer must be >= at 2
    @ConstraintsApplyTo(CONTAINED_VALUES)
    @Min(2)
    Optional<@ConstraintsApplyTo(CONTAINED_VALUES) List<Integer>> weirdo;

`@ConstraintApplyTo` can be applied in type use slots.

`@ConstraintApplyTo` offers a way to define at which level nested container resolution stops (if necessary).
Not by an explicit depth level but rather by its placement.

Let's show some more examples for good measure

    @Size Optional<String> foo; // illegal as @Size does not apply to Optional
    Optional<@Size String> foo; // legal as @Size applies to String
    
    @Min IntegerProperty foo; // legal because the extractor for JavaFX uses @ConstraintsApplyTo(CONTAINED_VALUES)
    
    @Size Collection<String> foo;  // The size applies to the collection, not the string since the extractor has the default @ConstraintsApplyTo(CONTAINER) value

TODO: should we offer a per annotation override:
`@NotNull(validAppliedTo=CONTAINED_VALUE)`.
The drawback is that old annotations will have to add the new attribute to offer the option.

WARNING: `@ConstraintApplyTo` can only be used on containers that have a single value type.
How to differentiate different value types otherwise ?

#### `@Valid`

Cascading via `@Valid` should also honor containers.

    Collection<@Valid PlushGiraffe> giraffes;
    
    @Valid
    Collection<PlushGiraffe> giraffes

The first form is the most readable.
The second form should be supported for backward compatibility reasons for collections and maps

Here are the various questions:

    class Foo {
       @Valid // cascade all or only the legacy ones? gut feeling is legacy
       Map<@RegExp(...) String, @Min(4) Integer> bars;

       // clear intent
       Map<@Valid @RegExp(...) String, @Valid @Min(4) Integer> bars;

       // TODO no place to put the @Valid on the key / value
       // so we should support legacy Map and decide what to do on random types
       StringIntegerMap bazs;
    }

TODO: Find an answer to the `@Valid` questions

#### `@ConstraintsApplyTo` Value for built-in containers

`Optional` defaults to `CONTAINER`.
`Iterable` and `Map` default to `CONTAINER`.
JavaFX `Property<T>` defaults to `CONTAINED_VALUES`.

The default for JavaFX property differs
because in this community the idiom `IntegerProperty` prevails over `Property<Integer>`.

#### Complex type parameter hierarchies

Complex hierarchies involving multiple levels of generic types are not trivial to solve
and will require the use of [FasterXML's Classmate](https://github.com/FasterXML/java-classmate)
or more likely an enhanced version of it.

    interface Map<K,V> { ... }
    // type parameter names change between subclass and superclass
    // and the position can be different between the class and the implements / extends clause
    public class CrazyMap<Last, First> implements Map<First, Last> { ... }
    
    public class Example {
        // String is Map's type parameter V and Long is Map's type parameter K
        private CrazyMap<@RegExp(...) String, @Min(0) Long> crazyMap = ...;
    }

In this situation, we need to follow the (annotated) type parameter across two or more levels up the hierarchy chain.
Note that type parameter names can vary between the subclass definition and the superclass definition.

I've played with Classmate and it does not seem to retain the information in its data even though it solves that problem internally to find the right type.
We might need to contribute to expose that somehow.

Also I don't think Classmate exposes annotations on type use, so we would need to contribute that or use something else like Jandex or plain Java reflection API.

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

### Drawbacks

The logic is less regular than Gunnar's proposal.
And thus could lock us for future enhancements.
Where? Dunno.

But it has less far reaching implications in particular around method validation.

### Naming options

`SingleContainerValueExtractor`: `ValidatedValueUnwrapper`, `ValueExtractor`

### Remaining TODOs

Should we have a BV 1.1 based logic that forces to use a global `@ConstraintsApplyTo(CONTAINER)`
to enforce strict backward compatibility.
And a BV 2.0 based logic (driven by the XML version?) would have the right ergonomics as described above?

## Alternative proposal: Consider type-constraints as instance-specific amendment of constraint set (Gunnar)

**TL,DR** The two proposals have converged more or less in the course of the discussion;
Essentially this proposal is a generalization of the more explicit approach which considers specific container types (lists, maps etc.) only.
Instead of supporting only some explicitly "known" container types, this proposal seeks to generalize that for any generic container type, e.g. a custom `Tuple` type.

Admittedly, the number of such container types is rather limited and we cover the largest part by the spec'ed support for list et al. in the other proposal. And cases like Tuple could be addressed by a custom extractor. So I'd be fine without this feature, as most cases are covered by default and we are extensible for others; We still could spec such generalization later on if we think it makes sense.

### Motivation

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

When encountering `@Valid`, we'll look for matching extractor implentations.
See Emmanuel's original proposal and my alternative above for extractor contracts.

A conforming implementation provides out-of-the-box extractor implementations for bean references (used by default) and collections.

Representing the `Optional` case in this generic fashion is nice, but two shortcomings need to be addressed:

* There should be no element in the constraint violation path for the wrapped element, only the container itself (this depends on the container type; For `Optional`, suppressing makes sense, but for `List` not)
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

#### Alternative for @Valid suggested by Emmanuel

If a member, parameter or return value declaration presents an annotated type use, then @Valid is implied for that declaration. @Valid is permitted but redundant in this case.

    public class Foo {
        Bar<@NotNull Baz> baz;
        // equivalent to
        @Valid
     Bar<@NotNull Baz> baz2;
    }

    public class Foo {
        @Valid //optional
        Buz<String, @Min(5) Integer> num;

        // validates Buz as there is an optional @Valid here
        // inside buz, cascade validation to @Foo
        Buz<@Valid Foo, Integer> num;
    }

Note that this model, while regular, is not the behavior of Collection and Map:

* `@Valid Collection<Foo>` is equivalent to `@Valid Collection<@Valid Foo>`
* `@Valid Map<Foo, Bar>` is equivalent to `@Valid Collection<Foo, @Valid Bar>`

TODO:

Should we consider the former form as legacy and deprecated?

* New code would write it as `Collection<@Valid Foo>` or `@Valid Collection<@Valid Foo>` for the verbose.
* New code would write it as `Map<Foo, @Valid Bar>` or @Valid Collection<@Valid Foo>` for the verbose.
* What should `@Valid Map<@Valid Foo, Bar>` do ?
* How to disable that implicit `@Valid`, e.g. if I don't want cascaded validation of `Bar<@NotNull Baz> baz`?

#### Misc.

**Explicitly not supported:** Applying constraints to container types with the intention of targetting the wrapped value.
I.e. the following would not work:

    // No validator for @Size+String
    @Size(max=20)
    private Optional<String> name;

Maybe that's ok, as in most cases there will be a type parameter. For JavaFX with its types such as `IntegerProperty` we could require compatible implementations to provide the required validator implementions e.g. for `@Min` + `IntegerProperty`. Or we ignore that, I've never heard of demand.

TODO: Gauge demand for JavaFX support

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
