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

.t.idx:1
.t.x:()

upd1:{ [t;x]
      x: update tid:.t.idx+i from x;
      .t.idx:.t.idx + count x;
      .t.x:x;
      .t.a,:delete bid, bsize from update atime:time, atid:tid from select from x where not null ask ; 
      .t.b,:delete ask, asize from update btime:time, btid:tid from select from x where not null bid ; 
      : :: }

upd: upd1

h:hopen `::5010           / connect to tickerplant
{ h(".u.sub";x;d) } each t;

\

upd: { [t;x] }

aa: `tid xdesc select from .t.a where sym in `AAPL
ba: `tid xdesc select from .t.b where sym in `AAPL

x0:aj[`sym`tid; ba; aa]

x0:delete from x0 where (null ask) or (null bid)

select from x0 where bid >= ask

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-p 5018 -t 1000"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
