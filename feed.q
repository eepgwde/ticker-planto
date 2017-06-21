// generate data for rdb demo

sn:2 cut (`AMD;"ADVANCED MICRO DEVICES"; `AIG;"AMERICAN INTL GROUP INC"; `AAPL;"APPLE INC COM STK"; `DELL;"DELL INC"; `DOW;"DOW CHEMICAL CO"; `GOOG;"GOOGLE INC CLASS A"; `HPQ;"HEWLETT-PACKARD CO"; `INTC;"INTEL CORP"; `IBM;"INTL BUSINESS MACHINES CORP"; `MSFT;"MICROSOFT CORP")

s:first each sn
n:last each sn
p:9h$33 27 84 12 20 72 36 51 42 29 / price
p0:p
m:" ABHILNORYZ" / mode
c:" 89ABCEGJKLNOPRTWZ" / cond
e:"NONNONONNN" / ex

// volatility 5% per annum 4 hours a day
// allow for two sigma.
v1: 2 * 0.05 % sqrt 4 * 250 

/
mode - might be the BBO conditions
ex - is exchange, New York and Other
c - conditions but I don't recognise 8 or 9.
\

// init.q

// cnt - the number of stocks
// pi
// gen - looks like a drift
// normalrand - Box-Muller Normal RV
// randomize - set the random seed to a function of the time.
// rnd - is a round to a bip (1/100th of a 1%) is 0.025 is 0.03

cnt:count s
pi:acos -1
gen:{exp 0.001 * normalrand x}
normalrand:{(cos 2 * pi * x ? 1f) * sqrt neg 2 * log x ? 1f}
randomize:{value "\\S ",string "i"$0.8*.z.p%1000000000}
rnd:{0.01*floor 0.5+x*100}
vol:{10+`int$x?90}

// Reproducible using a fixed seed.
// randomize[]
\S 235721

// =========================================================
// generate a batch of prices
// qx index, qb/qa margins, qp price, qn position.
// 
// Makes use of alias ::
//
// d is a set of deltas.
//
// n0 is a set of indicators for which deltas to use
// qx is a clever index randomize
// qx=/:til cnt returns indicators, 1 if the index is in qx. So for
// qx === 3 2 3 9 8 5 8 6 1 1
// n0 === null, 8 9, 1, 0 2, null , 5 , 7, null, 4 6, 3
// ie. no zeroes appear in qx, so the delta at position 0 is not selected.
// because 1 1 in qx at positions 8 and 9, then then deltas at positions 8 and 9 are chosen
// because 2 in qx at position 1, then the delta at pos 1 is chosen.
//
// d n0 is shorthand for d[n0]
// 
// qp raze n - removes any nulls
//
// t[] uses an 'n' but it isn't clear what it is.
//
// There is a problem with this. p begins as the initial prices and is
// overwritten each time batch is called, but batch can introduce nulls.
// And, eventually, all the prices are assigned null and stay that way.
// 
batch:{
       d:gen x;
       qx::x?cnt;
       qb::rnd x?v1; // uniform fluctuations at volatility
       qa::rnd x?v1;  // uniform fluctuations at volatility
       n0:where each qx=/:til cnt;
       s0:p*prds each d n0;
       qp::x#0.0;
       // This adjusts bid and asks.
       (qp raze n0):rnd raze s0;
       // New prices to update are:
       p2::rnd last each s0;
       i0: where not null p2;
       // Update global prices
       p[i0]:(type p)$p2 i0;
       qn::0}
// gen feed for ticker plant

len:10
batch len

maxn:15 / max trades per tick
qpt:5   / avg quotes per trade

// =========================================================

// Generate a set of trades.
//
// A useful test is: flip t 10
// If it doesn't flip, the field count, n, may be wrong.
t:{
 if[not (qn+x)<count qx;batch len];
   i:qx qn+til x;qn+:x;
   i: i where not null s i; n:count s i;
   (s i;p2 i;`int$n?99;1=n?20;n?c;e i)}

// see feed0.q
// split bid from quote and randomly choose a subset.
q:{
 if[not (qn+x)<count qx;batch len];
   i:qx qn+til x; qn+:x;
   i: i where not null s i; n:count s i;
   ba: (flip (s i;p2[i]*1f-qb[i];9h$n#0N;vol n;7h$n#0N;n?m;e i)),flip (s i;9h$n#0N;p2[i]*1+qa[i];7h$n#0N;vol n;n?m;e i);
   n0: count ba;
   flip ba n?n0 }

feed:{h$[rand 2;
 (".u.upd";`trade;t 1+rand maxn);
 (".u.upd";`quote;q 1+rand qpt*maxn)];}

feedm:{ sw:rand 2;
       t0: $[sw; t 1+rand maxn; q 1+rand qpt*maxn];
       a:count t0[0;];
       h(".u.updm"; $[sw; `trade; `quote]; (enlist a#x),t0 ); }


/// Initialize with some timestamped records
/// o is the time origin. Time now less an hour.
/// d is then the timespan
/// len is the length of list to submit. n is the last entries.
/// Randomly generate 'len' timespans, take the last n.
/// Submit.
init0:{ [len;n]
       o:`time$.z.T - `timespan$60*60*1000*1000*1000;
       d:`timespan$.z.T-o;
       len: $[null len; floor d%113; len];
       feedm each (neg n) # `timespan$desc len?d; }

/// init: init0[10]
init: init0[;5]

// Test the times by viewing
// feedm: { 0N!.Q.s1 x }
// init[10]

// weaves: disable here for debug
// \
/// Connect and send
   
h:neg hopen `::5010
/// These are useful single sends for testing.
// h(".u.upd";`quote;q 1);
// h(".u.upd";`trade;t 5);


// Test feed with this
// feed[]

/// Initial data uses feedm that uses .u.updm to send time-marks.
init[10]

/// Now set up the timer delivery, no time-marks are added by this.

.z.ts:feed

//  Local Variables: 
//  mode:q 
//  q-prog-args: "localhost:5010 -t 507 -halt"
//  fill-column: 75
//  comment-column:50
//  comment-start: "/  "
//  comment-end: ""
//  End:
