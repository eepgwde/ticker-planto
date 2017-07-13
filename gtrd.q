// @file gtrd.q
// @author weaves
//
// Generalized trading client.
// 
// Stores bids and asks. Marries them up and generates trades. 
//
// 

x:.z.x 0                  / client type
s:`;                   	  / default all symbols
d:`GOOG`IBM`MSFT          / symbol selection
t:`quote                   / default tables

\l sym.q

// Add a transaction id.

.t.a: delete bid, bsize from update atime:time, tid:i, atid:i from quote;
.t.b: delete ask, asize from update btime:time, tid:i, btid:i from quote;

.t.a: select by atid from .t.a;
.t.b: select by btid from .t.b;

.t.t:([] bid:`.t.a$(); ask:`.t.b$(); cond:`char$(); ex:`char$())

.t.idx:1
.t.x:()

.sys.qreloader enlist "gtrd1.q"

upd: upd1

h:hopen `::5010           / connect to tickerplant
{ h(".u.sub";x;d) } each t;

\

upd: { [t;x] }

aa: `tid xasc select from .t.a where sym in d
ba: `tid xasc select from .t.b where sym in d

x0:aj[`sym`tid; ba; aa]

x0:delete from x0 where (null ask) or (null bid)

x0: select from x0 where (bid >= ask),(btime >= atime)

x0: value `sym`time`bid xasc x0

b0: x0[0;]

xb: ungroup select `.t.b$distinct btid by time,sym from x0
xa: ungroup select `.t.a$distinct atid by time,sym from x0

// Rules:
// At bid time, find max bid, find all offers less than max bid, sum offered sizes
// create trades at offered price, for amounts, lowest prices first.
// If sum offered sizes >= bid size, then cancel bid and cancel offers.
// 

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-p 5019 -t 1000"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
