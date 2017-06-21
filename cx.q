/ cx.q
/ example clients

x:.z.x 0                  / client type
s:`;                   	  / default all symbols
d:`GOOG`IBM`MSFT          / symbol selection
t:`trade`quote            / default tables
h:hopen `::5010           / connect to tickerplant

/ rdb
if[x~"rdb";
 upd:insert]

/ high low close volume
if[x~"hlcv";
 t:`trade;
 hlcv:([sym:()]high:();low:();price:();size:());
 upd:{[t;x]hlcv::select max high,min low,last price,sum size by sym
  from(0!hlcv),select sym,high:price,low:price,price,size from x}]

/ last - needs work. Doesn't show prices if any are null.
/ Or the ticker plant needs to be filtered.
.t.x:()
if[x~"last";
   upd:{[t;x]
	if [ 0 = count .t.x; .t.x:x ];
	.[t;();,;select by sym from x] } ]

/ show only - runs on the timer.
if[x~"show";
 tabcount:()!();
 / count the incoming updates
 upd:{[t;x] tabcount+::(enlist t)!enlist count x};
 / show the dictionary every t milliseconds
 .z.ts:{if[0<count tabcount; 
	 -1"current total received record counts at time ",string .z.T;
	 show tabcount;
	 -1"";]};
 if[0=system"t"; system"t 5000"]]

/ all trades with then current quote
if[x~"tq";
 upd:{[t;x]$[t~`trade;
  @[{tq,:x lj q};x;""];
  q,:select by sym from x]}]

if[x~"vwap";t:`trade;
 upd:{[t;x]vwap+:select size wsum price,sum size by sym from x};
 upds:{[t;x]vwap+:select size wsum price,sum size by sym from x;show x}]

{h(".u.sub";x;s)} each t;

/  Local Variables: 
/  mode:q 
/  q-prog-args: "last -p 5016 -t 1000"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
