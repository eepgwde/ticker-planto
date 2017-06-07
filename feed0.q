
x:5
p:p0

// Randomly generate some bid and ask adjustments
qb:rnd x?1.0
qa:rnd x?1.0

// Randomly generate some indices across all stocks.
// longitudinally specify the indices of deltas to use - ragged list
qx:x?cnt
n0:where each qx=/:til cnt
n0

// Randomly generate some deviations
// Select those using the longitudinal indices and apply a cumulative product.
d:gen x
s0:p*prds each d n0

// This adjusts bid and asks.
qp:x#0.0
(qp raze n0):rnd raze s0

p1:p
p2:last each s0
pX:raze rnd 1_fills (p1 p2)

p:pX

qn:0
