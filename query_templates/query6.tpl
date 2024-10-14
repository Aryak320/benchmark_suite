
-- Query6: Retrieve parts that are of a certain type and size
DEFINE SYLLABLE_A = TEXT({"STANDARD",1},{"SMALL",1},{"MEDIUM",1},{"LARGE",1},{"ECONOMY",1},{"PROMO",1});
DEFINE SYLLABLE_B = TEXT({"ANODIZED",1},{"BURNISHED",1},{"PLATED",1},{"POLISHED",1},{"BRUSHED",1});
DEFINE SYLLABLE_C = TEXT({"TIN",1},{"NICKEL",1},{"BRASS",1},{"STEEL",1},{"COPPER",1});
DEFINE SIZE = RANDOM(1,50,uniform);
SELECT *
FROM part
WHERE p_type = '[SYLLABLE_A] [SYLLABLE_B] [SYLLABLE_C]'
AND p_size = [SIZE];

