---
title: Work on method level validation
author: Emmanuel Bernard
layout: news
tags: [proposal]
---
The expert groups has begun its work on method-level validation. A feature that was drafted in the
latest spec (appendix) but that we could nto finish in time.

You will be able to define constraints on parameters and your favorite interception technology
(CDI, @Inject, AspectJ, Spring etc) will call Bean Validation.

The final approach is not fixed yet but it will look like this.

<pre>public class BidManager {
    public void placeBid(&#64;Min(0) BigDecimal upTo) { ... }
}
</pre>

Want to know more? Join the expert group mailing list. [Learn how](/contribute).