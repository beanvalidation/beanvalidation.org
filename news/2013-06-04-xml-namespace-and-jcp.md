---
title: XML namespace and JCP
author: Emmanuel Bernard
layout: news
tags: [feedback]
---
Antonio Goncalves, fellow JCP member and friend [has asked
me](http://antoniogoncalves.org/2013/06/04/java-ee-7-deployment-descriptors/)
why Bean Validation XML's namespace has not moved from its original location to
the jcp.org location like other Java EE 7 specifications.

I don't remember being aware that such a move was orchestrated so there are two
possible reasons:

1. I was never been made aware of the move,
2. I was aware of it but considered that it was low priority compared to the [other
   issues][issues] we were working on.

Provided we had to work hard till the last minute, and that the community never
was keen on the XML support we put in Bean Validation, #2 is not impossible but
I suspect it's #1 or I would have opened an issue to track the task.

Anyways, that's not a problem. Anyone can open an issue (I've just [created
one](https://hibernate.atlassian.net/browse/BVAL-455) for this task), write a
couple of pull requests to fix the spec, TCK and RI as explained in [our
contribute section](/contribute/). Scratch your own itch: so who's jumping? :)

We will have to wait for the next version of the spec to avoid breaking older
applications but if it's committed, it won't be forgotten.

PS: no, I'm not bitter, but since I haven't blogged in a while that was a good
occasion to remind everyone of the power of contributions ;)

[issues]: https://hibernate.atlassian.net/issues/?jql=project%20%3D%20BVAL%20AND%20fixVersion%20in%20(%221.1.0.Alpha1%20(early%20draft%201)%22%2C%20%221.1.0.Beta1%20(public%20draft%201)%22%2C%20%221.1.0.Beta2%22%2C%20%221.1.0.Beta3%22%2C%20%221.1.0.Beta4%22%2C%20%221.1.0.CR1%22%2C%20%221.1.0.CR2%22%2C%20%221.1.0.CR3%22%2C%20%221.1.0.Final%22)%20AND%20status%20in%20(Resolved%2C%20Closed)
