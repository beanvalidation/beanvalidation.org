---
title: How to contribute to this website
layout: default
author: Emmanuel Bernard
---

# #{page.title}

This website's sources are hosted on GitHub at 
<https://github.com/beanvalidation/beanvalidation.org> and its pages are written
in [Markdown](http://daringfireball.net/projects/markdown/) and simple and intuitive
markup language.

Send a pull request with your changes and you are done.

## infrastructure

You need to:

* get Ruby
* if on Mac OS, get XCode (needed for native gems)
* `gem install awestruct` or `sudo gem install awestruct`
* `git clone git://github.com/beanvalidation/beanvalidation.org.git;cd beanvalidation.org`

## Serve the site locally

* Go in your `~/beanvalidation.org` directory.  
* Run  `awestruct -d`
* Open your browser to <http://localhost:4242>

Any change will be automatically picked up except for `_partials` files, `_base.css`
and sometimes new blog entries.

### If your changes are not visible...

If for whatever reason you make some changes which don't show up, you can
completely regenerate the site:

    awestruct -d --force

### If serving the site is slow...

On Linux, serving the file may be atrociously slow 
(something to do with WEBRick).

Use the following alternative:

* Go in your `~/beanvalidation.org` directory.  
* Run  `awestruct --auto -P development`
* In parallel, go to the `~/beanvalidation.org/_site` directory
* Run `python -m SimpleHTTPServer 4242`

You should be back to millisecond serving :) 

## Markup samples

You can find sample files in the Git repository itself for both .md and 
.html.haml syntaxes. Look at them especially the .md file as it 
shows how a page should be written and how to use syntax highlighting.

Menus are in `_layout`. When you create a page, give it the right metadata:

* `title`
* `author`
* `layout`

Here is an example

    ---
    title: How to contribute to this website
    layout: default
    author: Emmanuel Bernard
	---

	This is the content of my page.