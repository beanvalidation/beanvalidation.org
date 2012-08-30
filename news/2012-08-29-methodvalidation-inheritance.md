---
title: Method validation and inheritance - feedback needed!
author: Gunnar Morling
layout: news
tags: [feedback-needed]
---
Now that everybody is returning from their summer holidays, also the Bean Validation team
is getting back to their desks in order to work with full steam towards revision 1.1.

As you know, the largest new feature will be
[method validation](http://beanvalidation.org/1.1/spec/#d0e2147), that is the validation
of method parameters and return values using constraint annotations. Bean Validation 1.1
[early draft 1](http://beanvalidation.org/news/2012/03/13/release-1-1-edr1/) lays the
ground for this, and right now we're tackling some
[advanced questions](https://hibernate.onjira.com/browse/BVAL-272) still open in that area
(btw. if you haven't yet tried out the
[reference implementation](http://in.relation.to/Bloggers/FirstAlphaReleaseOfHibernateValidator5)
of ED1, this is the perfect time to do so and give us your feedback).

## The problem

One question the EG currently is [discussing](http://lists.jboss.org/pipermail/beanvalidation-dev/2012-August/000504.html) 
is whether and, if so, how a refinement of method constraints should be allowed in
sub-types. That is, if a class implements a method of an interface or overrides a method
from a super class, should the sub-type be allowed to place any additional constraints?

The current draft defines the following rules for such cases (see the
[draft document](http://beanvalidation.org/1.1/spec/#d0e2429) for all the gory details):

* No parameter constraints may be specified in addition to those constraints defined on
the method in the interface or super class.
* Return value constraints may be added in sub-types.

## The rationale

The rationale behind this is the principle of
[behavioral sub-typing](http://en.wikipedia.org/wiki/Liskov_substitution_principle), which
demands that wherever a given type `T` is used, it should be possible to replace `T` with
a sub-type `S` of `T`. This means that a sub-type must not strengthen a method's
preconditions (by adding parameter constraints), as this might cause client code working
correctly against `T` to fail when working against `S`. A sub-type may also not weaken a
method's postconditions. However, a sub-type may strengthen the method's postconditions
(by adding return value constraints), as client code working against `T` still will work
against `S`.

## Can you show me some code, please?

To give you an example, the following shows a constraint declaration considered illegal as
of the current draft, as parameter constraints are added to the `placeOrder()` method in a
sub-class of `OrderService`:

	public class OrderService {
		void placeOrder(@NotNull String customerCode, @NotNull Item item, int quantity) { ... }
	}

	public class SimpleOrderService extends OrderService {

		@Override
	    public void placeOrder(
			@Size(min=3, max=20) String customerCode,
			Item item,
			@Min(1) int quantity) { ... }
	}

## Alternatives

While this approach works, follows principles of clean OO design and also
[is employed](http://research.microsoft.com/en-us/projects/contracts/) by other
_Programming by Contract_ solutions, some voices in the EG expressed doubts whether the
handling of parameter constraints isn't too restrictive and thus may limit innovation in
that area. In particular with respect to legacy code, the question was raised whether it
shouldn't be allowed to add parameter constraints in sub-types.

One example may be a legacy interface, which _technically_ has no constraints (that is, no
parameter constraints are placed on its methods), but comes with a verbal description of
preconditions in its documentation. In this case an implementor of that interface might
wish to implement this contract by placing corresponding constraint annotations on the
implementation.

An open question in this situation is what should the behavior be if the
interface is being constrained afterwards?

## Give use your feedback!

So what do you think, should such a refinement of parameter constraints be allowed or not?
Possible alternatives:

- allow such a refinement by default
- have some sort of switch controlling the behavior (either standardized or provider-specific)

As there are pro's and con's of either approach, we'd very interested in user feedback on this.

Let us know what you think by posting a comment directly to this blog, shooting a message
to the [mailing list](https://lists.jboss.org/mailman/listinfo/beanvalidation-dev) or
participating in this [Doodle vote](http://www.doodle.com/qp78u6mqzetuas7p). Which use cases
you have encountered come to mind where the possibility to refine parameter constraints
may help you?
