// test.q
// Interrogating the other clients

// Map of ports and clients
h: (`symbol$())!`int$()

// connect to rdb
h[`rdb]:hopen `::5011           
h[`hlcv]:hopen `::5014
h[`last]:hopen `::5015
h[`tq]:hopen `::5016
h[`vwap]:hopen `::5017

hlcv: h[`hlcv](`hlcv)
vwap: h[`vwap](`vwap)

vwap: `sym`wprice`tsize xcol vwap

metrics: update wprice1: wprice % tsize from hlcv lj vwap

// Should be zero
count select from metrics where size <> tsize

// Should be zero too
count select from metrics where not wprice1 within (low;high)

// Add percent difference from high or low
metrics: update rwp1h: 100*(wprice1-high)%high, rwp1l:100 * (wprice1 - low)%low from metrics

// Get all at RDB

lq: h[`rdb](`quote)
lt: h[`rdb](`trade)


/  Local Variables: 
/  mode:q 
/  q-prog-args: "last d -p 5016 -t 1000"
/  fill-column: 75
/  comment-column:50
/  comment-start: "/  "
/  comment-end: ""
/  End:
