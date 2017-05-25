// generate data for rdb demo

sn:2 cut (
 `AMD;"ADVANCED MICRO DEVICES";
 `AIG;"AMERICAN INTL GROUP INC";
 `AAPL;"APPLE INC COM STK";
 `DELL;"DELL INC";
 `DOW;"DOW CHEMICAL CO";
 `GOOG;"GOOGLE INC CLASS A";
 `HPQ;"HEWLETT-PACKARD CO";
 `INTC;"INTEL CORP";
 `IBM;"INTL BUSINESS MACHINES CORP";
 `MSFT;"MICROSOFT CORP")

s:first each sn
n:last each sn
p:33 27 84 12 20 72 36 51 42 29 / price
m:" ABHILNORYZ" / mode
c:" 89ABCEGJKLNOPRTWZ" / cond
e:"NONNONONNN" / ex

// init.q

cnt:count s
pi:acos -1
gen:{exp 0.001 * normalrand x}
normalrand:{(cos 2 * pi * x ? 1f) * sqrt neg 2 * log x ? 1f}
randomize:{value "\\S ",string "i"$0.8*.z.p%1000000000}
rnd:{0.01*floor 0.5+x*100}
vol:{10+`int$x?90}

// randomize[]
\S 235721

// =========================================================
// generate a batch of prices
// qx index, qb/qa margins, qp price, qn position
batch:{
 d:gen x;
 qx::x?cnt;
 qb::rnd x?1.0;
 qa::rnd x?1.0;
 n:where each qx=/:til cnt;
 s:p*prds each d n;
 qp::x#0.0;
 (qp raze n):rnd raze s;
 p::last each s;
 qn::0}
// gen feed for ticker plant

len:10
batch len

maxn:15 / max trades per tick
qpt:5   / avg quotes per trade

// =========================================================
t:{
 if[not (qn+x)<count qx;batch len];
 i:qx n:qn+til x;qn+:x;
 (s i;qp n;`int$x?99;1=x?20;x?c;e i)}

q:{
 if[not (qn+x)<count qx;batch len];
 i:qx n:qn+til x;p:qp n;qn+:x;
 (s i;p-qb n;p+qa n;vol x;vol x;x?m;e i)}

feed:{h$[rand 2;
 (".u.upd";`trade;t 1+rand maxn);
 (".u.upd";`quote;q 1+rand qpt*maxn)];}

feedm:{h$[rand 2;
	  (".u.updm";`trade;(enlist a#x),t a:1+rand maxn);
	  (".u.updm";`quote;(enlist a#x),q a:1+rand qpt*maxn)];}


/// Initialize with some timestamped records
/// o is the time origin. Time now less an hour.
/// d is then the timespan
/// len is the length of list to submit. n is the last entries.
/// Randomly generate 'len' timespans, take the last n.
/// Submit.
init0:{ [len;n]
       / o:"t"$9e5*floor (.z.T-3600000)%9e5;

       o:`time$.z.T - `timespan$60*60*1000*1000*1000;
       d:`timespan$.z.T-o;
       len: $[null len; floor d%113; len];
       feedm each (neg n) # `timespan$desc len?d; }

/// init: init0[10]
init: init0[;5]

// Test by viewing
// feedm: { 0N!.Q.s1 x }
// init[10]

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
//  q-prog-args: "localhost:5010 -t 507"
//  fill-column: 75
//  comment-column:50
//  comment-start: "/  "
//  comment-end: ""
//  End:
