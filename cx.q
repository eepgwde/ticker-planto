/ cx.q
/ example clients

/ client type
// when testing set x and load
if[ not any `x = key `.; x:.z.x 0]

s:`;                   	  / default all symbols
d:`GOOG`IBM`MSFT          / symbol selection

// Switch to the sub-set if something else on the command-line.
if[ count .z.x 1; s:d]

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

/ last
/ If last appears as first part of string
.t.x:()
if[any 0 = x ss "last";
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

// VWAPs
if[any 0 = x ss "vwap"; t:`trade;
   // over all trades
   .vwap.f0: {[t;x] vwap+:select size wsum price,sum size by sym from x};

   // over last minute
   .vwap.f1: {[t;x] vwap1+:select size wsum price,sum size by sym,time.minute from x};

   // over last 10 ticks
   .vwap.xf2:{[p;s](-10#s)wavg -10#p};
   .vwap.f2:{[t;x] .[`.u.t;();,'';select price,size by sym from x]; 
             vwap2::`sym xkey select sym,vwap2:.vwap.xf2'[price;size]from .u.t};

   // over last minute
   .vwap.xf3: {[t;p;s](n#s)wavg(n:(1+t bin("t"$.z.Z)-60000)-count t)#p};

   .vwap.f3: {[t;x] .[`.u.t1;();,'';select time,price,size by sym from x];
              vwap3::`sym xkey select sym,vwap3:.vwap.xf3'[time;price;size] from .u.t1};

   fs: `$".vwap.",/: ( string 1_ key .vwap ) where { x[0] = "f" } each string 1_ key .vwap;
   upd: { [t;x] { [f; t; x] f . (t;x) }[;t;x] peach fs };
   upd: { [t;x] (fs).\:(t;x) }

   ]

{ h(".u.sub";x;s) } each t;

/  Local Variables: 
/  mode:q 
/  q-prog-args: "last d -p 5016 -t 1000"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
