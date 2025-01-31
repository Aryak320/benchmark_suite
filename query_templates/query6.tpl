define A=TEXT({"STANDARD",1},{"SMALL",1},{"MEDIUM",1},{"LARGE",1},{"ECONOMY",1},{"PROMO",1});
define B=TEXT({"ANODIZED",1},{"BURNISHED",1},{"PLATED",1},{"POLISHED",1},{"BRUSHED",1});
define C=TEXT({"TIN",1},{"NICKEL",1},{"BRASS",1},{"STEEL",1},{"COPPER",1});
define SIZE=RANDOM(1,50,uniform);
SELECT part.p_name, part.p_brand
FROM part
WHERE p_type = '[A] [B] [C]'
AND p_size = [SIZE]
GROUP BY part.p_brand, part.p_name;

