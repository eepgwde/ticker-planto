// Exit this file immediately to use the production "Final" implementation by
// uncommenting the \ comment.


// Uncomment
// \

.t.x:();
.t.t:`;
.t.n:0;

// With trap, assign to a global and redefine the caller.
.u.upd1:{[t;x]
	 .t.n+:1;
	 v0:@[ t insert;x;`err];
	 f0: -11h = type v0; // failed, print trace.
	 if[f0; 0N!"error: ", string t];
	 if[f0; 0N!{ count y[x;] }[;x] each til count x];
	 if[f0; .t.x:x; .t.t:t; .u.upd1: {[t;x]}];
	 if[f0; : ::]; // return
	 pub t; }

\

// Other implementations.

// Just insert
.u.upd1:{[t;x]
	 t insert x; }

// Insert and publish
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
