# ticker-planto
Simplified version of kdb+-tick

Scripts in this folder will run a real time tickerplant demo.

The original example is now on github.

https://github.com/KxSystems/cookbook/tree/master/start/tick

and is discussed here.

http://code.kx.com/q/tutorials/startingq/tick/

--

This is an even more simplified version for demonstration.

It only runs on Linux. It uses rlwrap and screen.

* Structure

This is discussed in the tutorial, but a ticker-plant (ticker.q) publishes
to its clients, or subscribers, these are (r.q and cx.q instances). It
receives ticks from a feed (this demo uses feed.q.)

The ticker-plant interoperates with a special client, the real-time
database, the r.q instance. This is *not* in this demo. The rdb is
implemented using cx.q - the generic client with a number of methods -
vwap, last and others. rdb is one of those.

* Installation and Running

** Installation: top level source directory - no build

You'll need the q interpreter in the ~/q directory. (Soft links work for me.)

** Running

run.sh calls run1.sh
run1.sh uses screen to display all the services in one console, and runs
the q interpreters under rlwrap in it.

 $ run.sh

starts everything. And a screen session called ticker-1234 will be
active. (The 1234 is a more or less random number.)

Attach to that screen. The clients should be updating. The most useful is
'last', it should display the last trades and quotes.

*** Testing

You can change what services run by specifying them like this.

You would start the ticker.q script in your q/kdb+ IDE and run other
scripts.

 $ run.sh feed last

Is a very simple configuration for testing the subscribe and publish
processes.

If you want to debug the feed.q then

 $ run.sh ticker last


* Changes

** ticker.q and feed.q - init feedm and .u.updm

I've added a .u.updm method to the ticker.q process. It is used by the feed
to initialize the system.

You can also use this replay a lot of data at once, asynchronously, ie. not
in real-time.

** feed.q - back-loading

The feed process now generates some sample ticks over the last hour and
replays all those to the ticker plant, (using a special method on the feed,
feedm, which calls .u.updm on the ticker plant.)

After that, it begins to replay in real-time, using feed, assigned to
synchronous method .z.ts, and the .u.upd method.

* Examples

** ticker, feed and last

There is a log-file of a run of 

 $ run.sh ticker last feed

There is an image of couple of updates.

* Usefulness

The terms of the licence for the use of the 32 bit free download are such
that you can't use this implementation in commercial use.

** Developing clients

If you want to develop clients this will work well enough.

** Coding in q

q/kdb+ systems are tailored for their environment.

 - Much use is made of the host OS to do scheduling and file system
   management, so no need to learn large APIs. 

 - There are no configuration files that adapt your process's application
   to the environment. So you don't usually start up in debug mode and load
   special functions. You write three of so variants of a function and use
   the text editor to define one.

 - Only do expensive application logic coding in the startup.

 - There is no debugger to speak of. 

* Postamble

** New to q/kdb+?

I'd recommend the kx website and the excellent tutorials. This ticker plant
isn't a very good test-bed for learning q/kdb+.

** Ticker plants in operation

The q/kdb+ ticker plant is much more evolved. And it's key parts are
usually implemented in 'k', the programming language that q is derived
from.


** This file's Emacs file variables

[  Local Variables: ]
[  mode:text ]
[  mode:outline-minor ]
[  mode:auto-fill ]
[  fill-column: 75 ]
[  coding: iso-8859-1-unix ]
[  comment-column:50 ]
[  comment-start: "[  "  ]
[  comment-end:"]" ]
[  End: ]
