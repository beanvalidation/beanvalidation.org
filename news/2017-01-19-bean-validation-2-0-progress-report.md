---
title: Bean Validation 2.0 Progress Report
author: Gunnar Morling
layout: news
tags: [news]
---

It has been a few months since we've kicked of the work on Bean Validation 2.0 (JSR 380).
We have made some good progress, so I'd like to give you a quick update on what has been achieved so far and what the next steps will be.
This is planned to be the first post of a regular blog series with JSR 380 status updates.

## Expert group formation

It all started with the review ballot of the JCP executive committee on the new JSR.
The ballot was approved with a [huge majority](https://www.jcp.org/en/jsr/results?id=5871), allowing the JSR to proceed and create its expert group.

In a short time, [individuals and representatives](https://www.jcp.org/en/jsr/detail?id=380) from multiple companies joined the EG, providing input and experiences from different angles and perspectives.
This also gives us very good connections to the EGs of other specs such as JAX-RS or java.time (JSR 310) which will be beneficial for creating new (or improving existing) integrations with those.

## First changes

With the first EG members on board, we didn't loose time and began with the work on the new spec revision.
One of the initial actions was to convert the spec document from DocBook into the fabulous [AsciiDoc](http://asciidoc.org/) format.
Using AsciiDoc comes with many advantages which make working on the spec a much more enjoyable experience:

* It can be written using any text editor
* Changes are easier to track, e.g. when reviewing pull requests on GitHub
* We can include actual source files from the API instead of copying them

While that's primarily a technicality interesting to those working on the spec, it also is beneficial for Bean Validation users,
as you for instance can easily track all the changes done so far by examining a [simple diff](https://github.com/beanvalidation/beanvalidation-spec/compare/2a9d0ce21856386a8bf9a1d9e963ebffc049604a...spec-full) on GitHub.

## Support for new date and time API

The primary theme in Bean Validation is the embrace of Java 8.
Java 8 comes with a variety of improvements to the language (e.g. Lambda expressions and default methods)
but also many useful additions to the class library.

One prominent example of the latter is the new date and time API ([JSR 310](https://www.jcp.org/en/jsr/detail?id=310)).
Types such as `Instant`, `LocalDate` or `ZonedDateTime` are supported by the `@Past` and `@Future` constraints now ([BVAL-496](https://hibernate.atlassian.net/browse/BVAL-496)):

    @Future
    private LocalDate deliveryDate;

`@Past` and `@Future` also have a new attribute `orPresent()` now:

    @Past(orPresent=true)
    private final Year inceptionYear = Year.of( 2017 );

That's useful for types such as `Year` or `LocalDate` which don't represent a specific instant but rather an interval of time
and you want to consider the entire current year, day etc. as valid.

Another improvement related to the validation of dates and times is the new `ClockProvider` extension point.
It allows you to specify what is "now" when validating `@Past` and `@Future`.
That comes in handy for instance if you want to work with the time and time zone of the currently logged in user in a multi-user, multi-timezone application.

But it's also useful for (re-)running batch jobs with a different logical date than the current one or for testing with a fixed point in time considered as "now":

    Validator validator = Validation.byDefaultProvider()
		    .configure()
        .clockProvider( () -> Clock.fixed(
            Instant.parse("2017-01-19T11:00:00.00Z" ),  ZoneId.systemDefault() )
        )
        .buildValidatorFactory()
        .getValidator();

## Validation of container elements

Looking at language changes in Java 8, the newly allowed locations for annotations ([type annotations](https://docs.oracle.com/javase/tutorial/java/annotations/type_annotations.html)) prove themselves a very useful feature for Bean Validation.
By putting constraints to type arguments of parameterized types, it finally gets possible to apply constraints to the elements of collections in a concise and intuitive way ([BVAL-508](https://hibernate.atlassian.net/browse/BVAL-508)):

    List<@NotNull @Email String> emails;

Putting the constraints to the `String` type argument makes it apparent that they should not be applied to the list object itself, but rather to each contained element.

Similarly, it's possible to put constraints to the elements of an array:

    String @NotNull @Email[] emails;

Also cascaded validation gets more flexible with that.
It's now possible to mandate that the keys _and_ values of maps should be validated
(so far, only values were validated) by using `@Valid` like this:

    Map<@Valid Customer, @Valid Address> primaryAddressByCustomer;

But it doesn't end there.
The spec also defines support for `java.util.Optional`:

    Optional<@Past LocalDate> getRegistrationDate();

As well as for the hierarchy of property types in JavaFX:

    Property<@Min(1) Integer> revenue;

Acknowledging that JavaFX provides dedicated non-generic sub-types of `Property` for specific data types (e.g. `StringProperty` or `IntegerProperty`),
it is also supported to put constraints on the element itself in this case:

    @Min(1)
    IntegerProperty revenue;

This becomes possible by defining means of "automatic value unwrapping" for specific types such as the JavaFX ones.
Check out the [latest spec draft](http://beanvalidation.org/latest-draft/spec/#appendix-valueextraction-wrappedelements) to learn more about how this is handled.

While the spec mandates support for type argument constraints on types such as `Iterable`, `Map`, `Optional` and some more,
this can be easily extended via the `ValueExtractor` contract.
This interface is used when the Bean Validation engine needs to obtain the elements of a constrained container.

Custom extractor implementations can be plugged in when bootstrapping a validator,
allowing to use type argument constraints with custom collection types such as the ones defined by [Google's Guava library](https://github.com/google/guava/wiki/NewCollectionTypesExplained) (e.g. `Multimap` or `Table`):

    ListMultimap<@Valid Customer, @Email String> emailsByCustomer;

We consider to detect custom extractors using the [service loader mechanism](http://docs.oracle.com/javase/8/docs/api/index.html?java/util/ServiceLoader.html),
allowing providers of container types to bundle corresponding extractors with their library and making them automatically available to you.

Validation of container elements is by far the most complex feature and we'd like to gather some more feedback on it before committing to it.
Hence its current proposal is added as [an appendix](http://beanvalidation.org/latest-draft/spec/#appendix-value-extraction) to the spec draft.
We are eager to learn about your thoughts and feedback in general, but it's especially important for this issue due to its complexity.
So if you have any ideas around it, please make sure to let us know, e.g. by commenting below.

## Other improvements

While support for JSR 310 and validation of container elements have been the largest features we've been working on so far,
there are some more smaller, yet very useful improvements.

E.g. all the built-in constraints are [repeatable annotations](http://docs.oracle.com/javase/tutorial/java/annotations/repeating.html) now, allowing to define them several times without requiring the explicit `@List` annotation ([BVAL-497](https://hibernate.atlassian.net/browse/BVAL-497)):

    @ZipCode(countryCode = "fr", groups = Default.class, message = "zip code is not valid")
    @ZipCode(
        countryCode = "fr",
        groups = SuperUser.class,
        message = "zip code invalid. Requires overriding before saving."
    )
    private String zipCode;

`ConstraintValidator#initialize()` has an empty default implementation now ([BVAL-555](https://hibernate.atlassian.net/browse/BVAL-555)),
simplifying the implementation of constraint validators that don't need to access any constraint attributes.
You can simply omit the `initialize()` method:

    public class AssertTrueValidator implements ConstraintValidator<AssertTrue, Boolean> {

        @Override
	      public boolean isValid(Boolean bool, ConstraintValidatorContext constraintValidatorContext) {
            return bool == null || bool;
        }
    }

Another nice improvement is the usage of actual parameter names when reporting constraint violations for constraints on method or constructor parameters ([BVAL-498](https://hibernate.atlassian.net/browse/BVAL-498)).
Provided you have enabled reflective parameter name access during compilation (using `-parameters` javac option),
`Path.Node#getName()` will return the actual parameter name instead of "arg0", "arg1" for parameter nodes.

## Next steps

We are currently working on picking up some loose ends around the proposal for container element validation.
Once that is done, we feel it is the right time to put out an Alpha1 release of Bean Validation 2.0 and post it for Early Draft Review to the JCP.
This should get the discussed changes into the hands of more people out there and will let us improve and hone the features added so far.

In parallel we'll continue with some other features from the backlog.
Issues high on our priority list are:

* Adding some new constraints as per our [recent survey](/news/2016/09/15/which-constraints-to-add/), e.g. `@NotEmpty`, `@NotBlank`
* Separating the notions of message resolver and message interpolator ([BVAL-217](https://hibernate.atlassian.net/browse/BVAL-217))
* Ability to validate an object and a list of changes ([BVAL-214](https://hibernate.atlassian.net/browse/BVAL-214))

We also contemplate the idea of using Java 8 Lambda expressions and method references for defining constraints without an explicit `ConstraintValidator` implementation class.
This is already supported in the reference implementation:

    ConstraintMapping mapping = ...
    mapping.constraintDefinition( Directory.class ) // @Directory is a constraint annotation
        .validateType( File.class ).with( File::exists );

We haven't decided yet whether to put this into the spec or not.
So we recommend you give it a try in the reference implementation and let us know about your thoughts.
The feedback when [sharing the idea](https://twitter.com/gunnarmorling/status/819631488358563840) on Twitter was [very encouraging](https://twitter.com/dblevins/status/819633752888475648).

We are also [working](https://java.net/projects/jax-rs-spec/lists/users/archive/2017-01/message/4) with the expert group for JAX-RS 2.1 ([JSR 370](https://www.jcp.org/en/jsr/detail?id=370)) to further improve integration of the two specs, e.g. in the [field of I18N](https://java.net/jira/browse/JAX_RS_SPEC-539).

This list of issues is not cast in stone, so if there is anything close to your heart, please speak up and let us know about your ideas.

One more thing I'm really excited about is that Bean Validation will eventually get its own logo.
Many thanks to Hendrik Ebbers who got in touch with a designer who already created this awesome draft:

<div style="text-align:center">
<img src="/images/bv_logo_scribble.jpg" alt="Bean Validation logo draft" style="width: 350px" />
</div>

Could there be a better representation of Bean Validation thank Duke validating a bean?
This work should be finalized very soon.

## Outreach

To get more closely in touch with the Bean Validation users out there, we've also submitted talks on Bean Validation 2.0 to several conferences.
I will be presenting on it at [JavaLand 2017](https://www.javaland.eu/konferenz/konferenzplaner/konferenzplaner_details.php?id=522447&locS=0&vid=529258) and have plans for some JUGs.
You also can expect a new edition of the [Asylum Podcast](http://asylum.libsyn.com/) discussing Bean Validation 2.0 and working on a JSR in general in the next weeks.
And you can find an [interview with me](https://www.heise.de/developer/artikel/Bean-Validation-ist-sehr-nuetzlich-fuer-Microservice-Architekturen-3321829.html) on Bean Validation 2.0 on heise Developer (in German).

## Raise your feedback

Bean Validation is a true community effort, so we are eager to learn about your suggestions and proposals.
Don't be shy, get a discussion started by dropping a comment below, posting to the [feedback forum](https://forum.hibernate.org/viewforum.php?f=26) or sending a message to the [Bean Validation mailing list](https://lists.jboss.org/mailman/listinfo/beanvalidation-dev).
