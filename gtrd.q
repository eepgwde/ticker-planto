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
// d:s
t:`quote                   / default tables

// Dummy method to start with.
upd: { [t;x] : :: }

h:hopen `::5010           / connect and subscribe to tickerplant
{ h(".u.sub";x;d) } each t;

.sys.qreloader enlist "gtrd1.q"

// Reconnect for the feed[] function
h:neg hopen `::5010

// Connect real methods.

.z.ts: syn0
upd: upd1


/  Local Variables: 
/  mode:q 
/  q-prog-args: "-p 5019 -t 1000"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
