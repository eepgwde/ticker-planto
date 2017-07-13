// @file gtrd1.q
// @author weaves
//
// Update operation.
// 
// Stores bids and asks. Marries them up and generates trades. 
//

upd1:{ [t;x]
      x: update tid:.t.idx+i from x;
      .t.idx:.t.idx + count x;
      .t.x:x;
      .t.a,:select by atid from delete bid, bsize from update atime:time, atid:tid from select from x where not null ask ; 
      .t.b,:select by btid from delete ask, asize from update btime:time, btid:tid from select from x where not null bid ; 
      : :: }

// Using converge to solve for a root using Newton's method.
// {[xn] xn-((xn*xn)-2)%2*xn}/[1.5]
