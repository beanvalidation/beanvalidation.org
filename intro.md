---
title: Introduction
layout: default
author: Emmanuel Bernard
---

# What is Bean Validation

Bean Validation is a Java specification conducted under the JCP umbrella and lead
by [Emmanuel Bernard](http://emmanuelbernard.com) / [Red Hat](http://redhat.com).
Bean Validation provides a unified way of declaring and defining constraints on
an object model.
<pre>
public class User {
    &#64;NotNull &#64;Email 
    public String getEmail() { return email; }
    public void setEmail(String email) { 
      this.email = email; 
    }
    private String email;
}
</pre>

Bean Validation also defines a runtime to validate objects. Layers of your 
application (presentation, business layer, persistence) can delegate validation
logic to Bean Validation and reuse constraints declared on your domain model.
In the Java EE space, JSF, JPA, EJB and CDI components are integrating Bean Validation.

Read the [Bean Validation 1.0 specification](/1.0/spec/).