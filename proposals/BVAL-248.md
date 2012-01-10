---
title: Introduce an evalutation order for constraints defined on a single property
layout: default
author: Emmanuel Bernard
---

# #{page.title}

[Link to JIRA ticket](https://hibernate.onjira.com/browse/BVAL-248)

## Goals

A popular use case requires to:

- avoid running expensive/complex constraints before cheap/simple ones
- still return at least one constraint failure per target (eg property)

Group sequence as defined in 1.0 does not let you do that as it stops validation
globally for the subsequent groups if a failure is found.

## Related issues

A partial solution for this could be provided by making sure `@ReportAsSingleViolation` does not 
validate the composing constraint if a composed constraint fails. See [BVAL-259][BVAL-259] and
[BVAL-220][BVAL-220].

[BVAL-259]: https://hibernate.onjira.com/browse/BVAL-259
[BVAL-220]: https://hibernate.onjira.com/browse/BVAL-220

## Solutions

### Option 1: `@GroupSequence` with ordering scope

We can reuse group sequence but refine the scope of their execution from global to per target.
A target is a property (field, getter) or a class.

	interface Cheap {}
	interface Expensive {}

	@GroupSequence(value={Cheap.class,Expensive.class}, scope=PER_TARGET)
	public class DomainObject {

		@Size(max=50, groups=Cheap.class) // constraint 1a
		@Pattern(regexp="[a-z]*", groups=Expensive.class)  // constraint 1b
		private String name;
		
		@Size(max=20, groups=Cheap.class) // constraint 2a
		@URL(groups=Expensive.class) // constraint 2b
		private String email;
		
		@Size(max=100, groups=Cheap.class) // constraint 3a
		@Pattern(regexp="[0-9]*", groups=Expensive.class) // constraint 3b
		private String password;
	}


The default `@GroupSequence.scope` would be `GLOBAL` which is the current behavior. `PER_TARGET` would mean that sequences are
applied per target. We stop validating a specific target (property or class) for subsequent groups 
of this sequence if a constraint fails on the target itself.

In our example we could get the following constraint failures:

- name: size beyond 50
- email: not a url
- password: too long

This solution is not technically as orthogonal than a true salience model (see below).
In particular, to mix that with partial validation, one has to create one group sequence
per partial group. Is that a problem in practice? It already reduces the number of 
interfaces to create by a whole lot.

Also, one could write a preset of `PER_TARGET` group sequence and reuse it across all the project.

We can apply the same kind of ordering solution on `@ReportAsSingleViolation`.

### Option 2: Add explicit _order_ parameter to constraints

We can't rely on the order annotations are declared in the source file as Java compilers and runtime do not
guarantee that. We might work around that with annotation processors or ways to read data from the bytecode 
but I'd see that as overkill. __Thoughts?__ So we need explicit order numbers defining a proper ordering.

	public class DomainObject {

       @ConstraintSequence(value={PER_TARGET))
       @Size(max=50, ordering=1) // constraint 1a
       @Pattern(regexp="[a-z]*", ordering=2)  // constraint 1b
       private String name;

       @ConstraintSequence(value={PER_TARGET))
       @Size(max=20,  ordering=1) // constraint 2a
       @URL(ordering=2) // constraint 2b
       private String email;

       @ConstraintSequence(value={PER_TARGET))
       @Size(max=100, ordering=1) // constraint 3a
       @Pattern(regexp="[0-9]*", ordering=2) // constraint 3b
       private String password;
	}

Constraints with lower numbers would be executed before constraints with higher numbers.

Ordering would be an orthogonal concern to groups entirely which is a plus compared to Option 1.
But numbers are:

- inelegant
- meaningless per se and not self documented 
- error prone: it's easy to have strange behaviors because someone changes one of the numbers
- hard to reorder or insert if not properly anticipated - think Basic line numbers (10, 20, 30, 35, 37, 38, 40, 50) :)

This solution will only work on constraints written for Bean Validation 1.1 and above as we would require
to add an `order` parameter to the constraint. There are two options, use an annotation on the param definition
or use the `valid` prefix.

    @Constraint(validatedBy = {})
    @interface Size {
    	...
    	@javax.validation.constraint.param.Order int order default 0;
    }

    //or

    @Constraint(validatedBy = {})
    @interface Size {
    	...
    	int validOrder default 0;
    }

Older constraints not defining order will be executed before the other ones.

Questions:

- should number ordering be honored per target only? Or globally? Or should it be configurable? 
  What about inheritance? If per target, that would probably reduce some of the candidates for bugs. 
  Inheritance would still be a problem.

Note that global ordering might reduce performance of Bean Validation engines.

### Option 3: `@ConstraintSequence`

The general idea is to define the sequence of constraints as it should be applied

 	@NotEmpty()
	@IsValidBinCodeNumber()
	@IsCardBannedNumber()
	@IsValidCardNumber()
	@ConstraintSequence(value={NotEmpty.class, IsValidBinCodeNumber.class,IsCardBannedNumber.class, IsValidCardNumber.class}, 
		                shortCirtcuit=true)
	private String creditCard;

It suffers a few drawbacks:

- does not accept parameters
- does not accept multiple constraints of the same type
- cannot do parallel reports (ie all errors of order=1) but that's a lesser concern

So in its current form is not usable.


### Number groups

We can offer number groups to reduce the number of groups a user has to declare. 
	
	package javax.validation.groups;

	@GroupSequence({Level1.class, Level2.class, Level3.class, Level4.class, Level5.class, Level6.class, Level7.class, Level8.class, Level9.class, Level10.class})
	interface Order {
	    interface Level1 {}
	    interface Level2 {}
	    interface Level3 {}
	    ...
	    interface Level10 {}
	}


I am not a big fan of this solution though.