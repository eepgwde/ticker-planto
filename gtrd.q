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

upd1:{ [t;x]
      x: update tid:.t.idx+i from x;
      .t.idx:.t.idx + count x;
      .t.x:x;
      .t.a,:select by atid from delete bid, bsize from update atime:time, atid:tid from select from x where not null ask ; 
      .t.b,:select by btid from delete ask, asize from update btime:time, btid:tid from select from x where not null bid ; 
      : :: }

upd: upd1

h:hopen `::5010           / connect to tickerplant
{ h(".u.sub";x;d) } each t;

\

upd: { [t;x] }

aa: `tid xasc select from .t.a where sym in first d
ba: `tid xasc select from .t.b where sym in first d

x0:aj[`sym`tid; ba; aa]

x0:delete from x0 where (null ask) or (null bid)

x0: select from x0 where (bid >= ask),(btime >= atime)

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
