
x:10
p:p0

// Randomly generate some bid and ask adjustments
qb:rnd x?1.0
qa:rnd x?1.0

// Randomly generate some indices across all stocks.
// longitudinally specify the indices of deltas to use - ragged list
// raze n0 is then a list of the stock indices to be changed.
qx:x?cnt
n0:where each qx=/:til cnt
n0

// Randomly generate some normal deviations
// Select those using the longitudinal indices and apply a cumulative product.
d:gen x
s0:p*prds each d n0
// s0 is now the shifts in prices of the stocks.

// This adjusts bid and asks.
qp:x#0.0
(qp raze n0):rnd raze s0

p1:p
p2:last each s0
pX:raze rnd 1_fills (p1 p2)

p:pX

qn:0


// Simon G then goes on to generate set of trades like this.
// batch[] will produce a set of trades. These will be split up into
// transmission batches. qn is used to track the number remaining in the set.
// 

// Check if we need a new batch.
// qn tracks the trades available from batch[]
qn:0
x: 3

if[not (qn+x)<count qx;batch len];

// qx is the set of stock indices from batch[].
// n is a selector adjusted by this transmission batch size, qn, which is then
// incremented
i:qx n1:qn+til x
qn+:x

// Select from stock symbols using i, prices from batch[] using n1
// This means that if i is for stocks A, B, C we rely upon qp to be in the
// same order
// 
(s i;qp n1;`int$x?99;1=x?20;x?c;e i)

