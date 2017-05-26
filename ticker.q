/ ticker.q
/ simple tickerplant example
/ not suitable for production code, for this use kdb+tick

// weaves
// some discrepancies here.
// kx used to use ssl.q to be a feed.
// This is a simple example of a tickerplant (all coded in q).

// Schema for published tables.
\l sym.q

/ quote:flip `time`sym`bid`ask`bsize`asize`mode`ex!()
/ trade:flip `time`sym`price`size`stop`cond`ex!()

// client subscription handler.
//
// Maintain a dictionary against a list of [symbols;tables;handle]
// client sends (name;symbols;tables)
Sub:`quote`trade!()
.u.sub:{Sub[x],:enlist x,y,neg .z.w}

// local: publish to all subscribers for their tables and symbols.
pub:{{.[pub1;x]} each Sub x}

// Distributor - callback the method on the client is upd[t;symbols]
// special symbol is ` - send the whole table.
pub1:{[t;s;h]
 sel:$[s~`;value t;select from t where sym in s];
 if[count sel;@[h;("upd";t;sel);()]]}


// Feed handler
// A real ticker-plant would receive from C runtime components.
// For testing, feed.q calls us via .u.upd
// The test function is h(".u.upd";`quote;q 1)
// Sends a payload that is table name, t, and a tuple of a record
// A single quote (1)
// (,`MSFT;,28.59;,29.06;,35;,73;,\"L\";,\"N\")
// A single trade
// "`trade"
// "(,`HPQ;,36.04;,45i;,0b;,\"B\";,\"O\")"
// Multiple records can be sent q 2 gives
// "(`DELL`AIG;11.62 26.55;12.97 27.4;37 81;23 26;\"HH\";\"NO\")"
// A time mark is created, m, one for each symbol.
// The local implementation is .u.upd1 which inserts to the table
// publishes and empties the table.
// The time mark is prepended to the list

/// On initialization, time offsets are sent.

// Over-ridden: traced
.u.updm:{[t;x]
	0N!.Q.s1 t; 0N!.Q.s1 x; 0N!count x;
	.t.x:x;
	m:enlist(count x 0)#.z.T;
	.t.m:m;
	 0N!"m: ",.Q.s1 m;
	 x[0]:`time$(raze m) - x[0];
	.u.upd1[t;x] }

// Final
.u.updm: {[t;x]
	  m:enlist(count x 0)#.z.T;
	  x[0]:`time$(raze m) - x[0];
	  .u.upd1[t;x]; }


/// After initialization, time marks are added.
.u.upd:{[t;x]
	m:enlist(count x 0)#.z.T;
	.u.upd1[t;m,x] }

/// Table and publishing

// Try publishing.
.u.upd1:{[t;x]
	 t insert x;
	 pub t; }

// Over-ridden: no publish, no delete.
.u.upd1:{[t;x]
	 t insert x; }

// Final.
.u.upd1:{[t;x]
	 t insert x;
	 pub t;
	 delete from t }

// Try publishing.
.u.upd1:{[t;x]
	 t insert x;
	 pub t; }

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-p 5010"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
