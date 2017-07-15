/// @author weaves
///
/// Trading table definitions.
/// Only needed by some clients.

quote:([]time:`timespan$(); xid:`long$(); sym:`g#`symbol$(); bid:`float$(); ask:`float$(); bsize:`long$(); asize:`long$(); mode:`char$(); ex:`char$())
trade:([]time:`timespan$(); xid:`long$(); sym:`g#`symbol$(); price:`float$(); size:`int$(); stop:`boolean$(); cond:`char$(); ex:`char$())


