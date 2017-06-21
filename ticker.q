/ ticker.q
/ simple tickerplant example
/ not suitable for production code, for this use kdb+tick

// weaves
// some discrepancies here.
// kx used to use ssl.q to be a feed.
// This is a simple example of a tickerplant (all coded in q).

// Schema for published tables.
\l sym.q

// Schema by hand.
/ quote:flip `time`sym`bid`ask`bsize`asize`mode`ex!()
/ trade:flip `time`sym`price`size`stop`cond`ex!()

// client subscription handler.
//
// Maintain a dictionary against a list of [symbols;tables;handle]
// client sends (table;sym-list) for each table
// This forms a tuple (sym-list; file-handle)
Sub:`quote`trade!()
.u.sub:{ Sub[x],: enlist (enlist raze y),neg .z.w }

// local: publish to all subscribers for their tables and symbols.
// passing the name of the table to pub1.
pub:{{.[pub1;(x;y)]}[x;] each Sub x}

// Distributor - callback the method on the client is upd[t;symbols]
// special symbol is ` - send the whole table.

/ trace version.
pub1:{[t;b] 0N!t; s:raze b[0]; 0N!.Q.s1 s; h:b[1]; 0N!.Q.s1 h; }

/ switch off
pub1: {[t;b] }

pub1:{[t;b] s:raze b[0]; h:b[1]; 
      sel:$[any ` = raze s;value t;select from t where sym in s]; 
      if[count sel;@[h;("upd";t;sel);()]] }

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

// Final
.u.upd1:{[t;x]
	 t insert x;
	 pub t;
	 delete from t }


\

// To just trace the .u.upd1 operation, you change its definition you override in
// the following file. You can only load these with the qsys q invokers Qp or Qr.
// (So only in emacs.)

.sys.qreloader enlist "u-upd1.q"

.sys.qreloader enlist "u-upd0.q"

/  Local Variables: 
/  mode:q 
/  q-prog-args: "-p 5010"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
