Nyan Cat <3 Chef
================

A formatter for [Chef](http://opscode.com) dedicated to the wonderful Nyan Cat!

    Starting Chef Client, version 10.14.4
    Compiling cookbooks
    .............................................................done.
    Converging 138 resources
    278/278: _-_-_+-_-_-_-_+_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-__,------,
    270/278: _-_-_+-_-_-_-_+_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-__|  /\_/\
      8/278: _-_-_+-_-_-_-_+_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_~|_( - .-)
      0/278: _-_-_+-_-_-_-_+-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_ ""  ""

    System converged.

This formatter will display the total number of processed resources, as the
number of unchanged, updated and failed resources.

The rainbow changes colors as it runs.

This is inspired by [Nyan Cat RSpec Formatter](https://github.com/mattsears/nyan-cat-formatter).
Actually no, scratch that: this is basically a ripoff. So sue me.

Usage
=====

Install the gem:

    gem install nyan-cat-chef-formatter

If you are using Omnibus Chef you need to specify the full path to the `gem`
binary:

    /opt/chef/embedded/bin/gem install nyan-cat-chef-formatter

Or write a cookbook to install it using the `chef_gem` resource, if that's
how you roll.

Then add the following to your `/etc/chef/client.rb` file:

    gem 'nyan-cat-chef-formatter'
    require 'nyan-cat-chef-formatter'

This enables the formatter, but doesn't use it by default. To see Nyan in all its
glory, run:

    chef-client -Fnyan -lfatal

Enjoy!

For serious Nyan addicts only!
------------------------------

To enable the Nyan formatter by default, add the following line to
`/etc/chef/client.rb`:

    formatter "nyan"

Contributing
----------

Once you've made your great commits:

1. Fork Nyan Cat
2. Create a topic branch - git checkout -b my_branch
3. Push to your branch - git push origin my_branch
4. Create a Pull Request from your branch
5. That's it!

Author
----------
[Andrea Campi](https://www.github.com/andreacampi) :: @andreacampi
[Matt Sears](https://wwww.mattsears.com) :: @mattsears
