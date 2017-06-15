// weaves
//
// This picks apart the logic of stock price generation.


x:10
p:p0

// Randomly generate some bid and ask adjustments
qb:rnd x?1.0
qa:rnd x?1.0

// Randomly generate some indices across all stocks.
// longitudinally specify the indices of deltas to use - ragged list
// each row of n0 is then the jumps to apply to the stocks.
qx:x?cnt
n0:where each qx=/:til cnt
n0

// Randomly generate some normal deviations
// Select those using the longitudinal indices and apply a cumulative product.
d:gen x
s0:p*prds each d n0
// s0 is now the prices of the stocks.

// For simplicity, just use the last values.

// This adjusts bid and asks.
qp:x#0.0
(qp raze n0):rnd raze s0

// Use this to hold the changed prices
p2:rnd last each s0

// New prices to update are:
i0: where not null p2
p[i0]:(type p)$p2 i0

qn:0


// Simon G then goes on to generate set of trades like this.
// batch[] will produce a set of trades. These will be split up into
// transmission batches. qn is used to track the number remaining in the set.
//
// use qx to select from p2

// Check if we need a new batch.
// qn tracks the trades available from batch[]
qn:0
x: 3

if[not (qn+x)<count qx;batch len];

// qx is the set of stock indices from batch[].
// n is a selector adjusted by this transmission batch size, qn, which is then
// incremented
// Choose just those that are 
i:qx n1:qn+til x
qn+:x

// Select from stock symbols using i, prices from batch[] using n1
// This means that if i is for stocks A, B, C we rely upon qp to be in the
// same order
// 
(s i;p2 i;`int$x?99;1=x?20;x?c;e i)


// Split bids and asks.

if[not (qn+x)<count qx;batch len];
i:qx qn+til x
qn+:x
i: i where not null s i

(s i;p2[i]-qb[i];p2[i]+qa[i];vol x;vol x;x?m;e i)

ba: (flip (s i;p2[i]-qb[i];9h$(count i)#0N;vol x;7h$(count i)#0N;x?m;e i)),flip (s i;9h$(count i)#0N;p2[i]+qa[i];7h$(count i)#0N;vol x;x?m;e i)
n0: count ba
flip ba (count i)?n0
