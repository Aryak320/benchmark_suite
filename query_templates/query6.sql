-- start query 6 in stream 0 using template query36.tpl
PROVENANCE OF (
SELECT *
FROM lineitem
WHERE l_shipmode = 'RAIL'
AND l_quantity < 25
AND l_linestatus = 'F');

-- end query 6 in stream 0 using template query36.tpl

