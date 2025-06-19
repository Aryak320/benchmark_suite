-- start query 8 in stream 0 using template query36.tpl
PROVENANCE OF (
SELECT *
FROM lineitem
WHERE l_shipmode = 'MAIL'
AND l_quantity < 48
AND l_linestatus = 'F');

-- end query 8 in stream 0 using template query36.tpl

