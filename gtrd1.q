// @file gtrd1.q
// @author weaves
//
// Update operation.
// 
// Stores bids and asks. Marries them up and generates trades. 
//

\l sym.q

\l extra0.q

// Load the feed timing data.

`.feed set get `:./feed;

.t.ticks: 10

.z.ts: ::

// Write some data out after so many ticks and finish

syn0: { [ts] .t.ticks-:1; if[.t.ticks > 0; : ::];
       0N!"finished"; `:./t set get `.t;
       .z.ts: ::; .sys.exit[0] }


/

// Debug: a data collector

upd1:{ [t;x]
      .t.x:x;
      `.t.batch insert x;
      `.t.quotes upsert `xid xkey .t.batch; }

\

/// Do some matching and issue cancel quotes and trades.
///
/// Create a batch, upsert to a local quotes table indexed on xid.
/// Delete from this table all those that are complete/cancelled, ie. "C" in mode.
///
/// Remove the cancels from the batch and check if empty.
///
/// Otherwise, resolve those aggressor orders and update the ticker-plant.
/// Send cancellations/completions for the quotes using the prior xid index.
/// Send trades with new xid indices.

upd1:{ [t;x]
      `.t.batch insert x;
      `.t.quotes upsert `xid xkey .t.batch;
      delete from `.t.quotes where mode = "C";

      t0: delete from .t.batch where mode = "C";
      if[ 0 = count t0; : ::];
      x0: resolve[t0];
      feed[.z.p; (`quote;x0[0]) ];
      feed[.z.p; feed0[`trade; x0[1]]];
      delete from `.t.batch; }

/// Convert a quote into a trade record.
q2t: { [q0] q0: (0!q0);
      px: (q0[`bid][0] ; q0[`ask][0]);
      px: (px where not null px)[0];
      size0: (q0[`bsize][0] ; q0[`asize][0]);
      size0: (size0 where not null size0)[0];
      (0N; q0[`sym][0]; px; size0; 0b; "A"; q0[`ex][0]) }

/// Cancel a quote
q2q: { [q0] q0: (0!q0);
      px: (q0[`bid][0] ; q0[`ask][0]);
      px: (px where not null px)[0];
      size0: (q0[`bsize][0] ; q0[`asize][0]);
      size0: (size0 where not null size0)[0];
      // seq, sym, bid, ask, bsize, asize, mode, ex
      (q0[`xid][0]; q0[`sym][0]; q0[`bid][0]; q0[`ask][0]; q0[`bsize][0]; q0[`asize][0]; q0[`mode][0]; q0[`ex][0]) }


/// For trades, Add a sequence number
feed0: { [tr1; tr0] 
	a:count tr0[0;]; tr0[0;]: .ex.xidu a; 
	(tr1; tr0) }

// Send to ticker-plant.
// ts is a .z.p timestamp and order/trade
feed:{ [ts; x0] nx010: count x0[1][0;];
      ts1: (enlist asc nx010#`timespan$ts - .feed.start0);
      h(".u.upd"; x0[0]; ts1,x0[1] ); }


resolve: { [tb]
	  q1s:(); t1s:();
	  while[ 0 < count tb; q0:1#tb; tb: 1_tb;
		tick0:.z.p;
		t1: q2t[q0]; t1s,:enlist t1;
		q1: update bid:0f, mode:"C" from q0 where not null bid;
		q1: update ask:0f, mode:"C" from q1 where not null ask;
		q1s,:enlist q2q[q1] ] ;
	  (flip q1s; flip t1s) }

\

// Load some sample data.
// And test completion by sending a trade and a completed quote.

`.t set get `:./t

// Test a trade

q0: 1#.t.quotes

t1: q2t[q0]
t1: flip enlist t1

feed0[`trade;t1]

q1: update bid:0N, ask:0N, mode:"C" from q0;
q1: flip enlist q2q[q1];

upd: { [t;x] : :: }
h:neg hopen `::5010

feed[.z.p; feed0[`trade; t1]]

feed[.z.p; (`quote;q2q[q0])]

x0: resolve[5#0!.t.quotes]

feed[.z.p; (`quote;x0[0]) ]

feed[.z.p; feed0[`trade; x0[1]]]

\

.ask.r0: () 
.bid.r0: ()

// Recreate the batches

.ask.b0: select atid by time from .t.a
.bid.b0: select btid by time from .t.b

.ask.b1: 1#.ask.b0
.ask.b0: 1_.ask.b0

.bid.b1: 1#.bid.b0
.bid.b0: 1_.bid.b0

.t.offers: select `.t.a$atid by sym, ask from .t.a

.t.bids: select `.t.b$btid by sym, ask:bid from .t.b

// It's possible to match on the key.

(key .t.bids)#.t.offers

# Choose one batch
.t.batch0: 7
.t.batch: select from .t.a where id0 = 7

syn0: { [x] show (type x; x) }

\

// Allocations example

buys:2 1 4 3 5 4f
sell:12f

// The objective is to draw successively from the buys until we have
// exactly filled the sell, then stop. In our case the result we are
// seeking is,

allocation: 2 1 4 3 2 0

// The insight is to realize that the cumulative sum of the allocations
// reaches the sell amount and then levels off: this is an equivalent
// statement of what it means to do FIFO allocation.

sums allocation
// 2 3 7 10 12 12

// We realize that the cumulative sum of buys is the total amount
// available for allocation at each step.

sums buys
// 2 3 7 10 15 19f

// To make this sequence level off at the sell amount, simply use &.

sell&sums buys
// 2 3 7 10 12 12f

// Now that we have the cumulative allocation amounts, we need to unwind
// this to get the step-wise allocations. This entails subtracting
// successive items in the allocations list.

// Wouldn't it be nice if q had a built-in function that returned the
// successive differences of a numeric list? There is one: deltas and –
// no surprise – it involves an adverb (called each-previous – more about
// that in Chapter 5).

deltas 1 2 3 4 5
// 1 1 1 1 1
deltas 10 15 20
// 10 5 5

// Observe in your console display that deltas returns the initial item
// untouched. This is just what we need.

// Returning to our example of FIFO allocation, we apply deltas to the
// cumulative allocation list and we're done.

deltas sell&sums buys

// Now fasten your seatbelts as we switch on warp drive. In real-world
// FIFO allocation problems, we actually want to allocate buys FIFO not
// just to a single sell, but to a sequence of sells. You say, surely
// this must require a loop. Please don't call me Shirley. And no loopy
// code.

// We take buys as before but now we have a list sells, which are to be
// allocated FIFO from buys.

buys:2 1 4 3 5 4f
sells:2 4 3 2
allocations
// 2 0 0 0 0 0
// 0 1 3 0 0 0
// 0 0 1 2 0 0
// 0 0 0 1 1 0

// The idea is to extend the allocation of buys across multiple sells by
// considering both the cumulative amounts to be allocated as well as the
// cumulative amounts available for allocation.

sums[buys]
// 2 3 7 10 15 19f

sums[sells]
// 2 6 9 11

// The insight is to cap the cumulative buys with each cumulative sell.

2&sums[buys]
// 2 2 2 2 2 2f

6&sums[buys]
// 2 3 6 6 6 6f

9&sums[buys]
// 2 3 7 9 9 9f

11&sums[buys]
// 2 3 7 10 11 11f

// Contemplate this koan and you will realize that each line includes the
// allocations to all the buys preceding it. From this we can unwrap
// cumulatively along both the buy and sell axes to get the incremental
// allocations.

// Our first task is to produce the above result as a list of lists.

// 2 2 2 2  2  2
// 2 3 6 6  6  6
// 2 3 7 9  9  9
// 2 3 7 10 11 11

// Adverbs to the rescue! Our first task requires an adverb that applies
// a dyadic function and a given right operand to each item of a list on
// the left. That adverb is called each left and it has the funky
// notation \:. We use it to accomplish in a single operation the four
// individual & operations above.

sums[sells] &\: sums[buys]
// 2 2 2 2  2  2
// 2 3 6 6  6  6
// 2 3 7 9  9  9
// 2 3 7 10 11 11

// Now we apply deltas to unwind the allocation in the vertical direction.

deltas sums[sells]&\:sums[buys]
// 2 2 2 2 2 2
// 0 1 4 4 4 4
// 0 0 1 3 3 3
// 0 0 0 1 2 2

// For the final step, we need to unwind the allocation across the rows.

// The adverb we need is called each. As a higher-order function, it
// applies a given function to each item of a list (hence its name). For
// a simple example, the following nested list has count 2, since it has
// two items. Using count each gives the count of each item in the list.

(1 2 3; 10 20)

count (1 2 3; 10 20)

count each (1 2 3; 10 20)

// In the context of our allocation problem, we realize that deltas each
// is just the ticket to unwind the remaining cumulative allocation
// within each row.

deltas each deltas sums[sells] &\: sums[buys]

// 2 0 0 0 0 0
// 0 1 3 0 0 0
// 0 0 1 2 0 0
// 0 0 0 1 1 0


/  Local Variables: 
/  mode:q 
/  q-prog-args: "-p 5019 "
/  fill-column: 75
/  comment-column:50
/  comment-start: "//  "
/  comment-end: ""
/  End:
