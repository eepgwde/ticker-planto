// @file gtrd1.q
// @author weaves
//
// Update operation.
// 
// Stores bids and asks. Marries them up and generates trades. 
//

.t.ticks: 10

.z.ts: ::

// Write some data out after so many ticks and finish

syn0: { [ts] .t.ticks-:1; if[.t.ticks > 0; : ::];
       0N!"finished"; `:./t set get `.t;
       .z.ts: ::; .sys.exit[0] }

upd1:{ [t;x]
      x: update id0:.t.id0, tid:.t.idx+i from x;
      .t.idx+:count x;
      .t.id0+:1;
      .t.x:x;
      .t.a,:select by atid from delete bid, bsize from update atime:time, atid:tid from select from x where not null ask ; 
      .t.b,:select by btid from delete ask, asize from update btime:time, btid:tid from select from x where not null bid ; 
      : :: }

// Using converge to solve for a root using Newton's method.
// {[xn] xn-((xn*xn)-2)%2*xn}/[1.5]

\

// Load a sample file.

`.t set get `:./t

.t.offers: select `.t.a$atid by sym, ask from .t.a

.t.bids: select `.t.b$btid by sym, ask:bid from .t.b

// It's possible to match on the key.

(key .t.bids)#.t.offers

# Choose one batch
.t.batch0: 7
.t.batch: select from .t.a where id0 = 7

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
