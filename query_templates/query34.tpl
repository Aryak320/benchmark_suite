-- Query5: Retrieve suppliers who have supplied parts with a supply cost greater than a certain value
DEFINE SUPPLYCOST = RANDOM(100,1000,uniform);
PROVENANCE OF (
SELECT s.*
FROM supplier s, partsupp ps
WHERE s.s_suppkey = ps.ps_suppkey
AND ps.ps_supplycost > [SUPPLYCOST]);

