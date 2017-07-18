/// @author weaves
///
/// Extra methods 
/// 

/// You can check time and sequence consistency in the rdb with these.

\d .tq

xid: { [t] any not 0 < deltas t `xid }
time: { [t] any not 0 <= deltas t `time }

\d .

// Exchange id - tag each order and trade.

\d .ex

xid: 1

xidu: { [n] x: .ex.xid + til n; .ex.xid: 1 + max x; x }

\d .

