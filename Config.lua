

Config = {}

Config.Items = { 
	
-- Example / Exemple

-- 'item' 	is the database name of the item ( not the label )
-- 'prix' 	is the price it will be sold at a 10% marge 
-- 'legal' 	if set on false it will call the cop 1/Chance of the time 
-- 'sale'	if the money is gived in black money

-- 'item' 	est le nom de l'item dans la bdd ( pas le label )
-- 'prix' 	est le prix de vente avec une marge 10% 
-- 'legal' 	si mis sur false la police sera prevenu 1/Chance du temps 
-- 'sale'	si l'argent est donné en sale

--	{ item = '', 		prix = , 	legal = ,	sale = },

	 	
	{ item = 'weed_pooch', 	prix = 50, 	legal = false,	sale =  false },	
	{ item = 'coke_pooch', 	prix = 70, 	legal = false,	sale =  false },	
	{ item = 'meth_pooch', 	prix = 80, 	legal = false,	sale =  false },	
	{ item = 'opium_pooch', prix = 100, 	legal = false,	sale =  false },

	
	{ item = 'cigare', 	prix = 45, 	legal = true,	sale =  false },	
	{ item = 'gitanes', 	prix = 20, 	legal = true,	sale =  false },
	

}
