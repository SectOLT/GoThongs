#define PotionsMethod$setPotion 1		// (str)name, (key)texture, (int)charges, (int)flags, (float)cooldown, (obj)spellData
#define PotionsMethod$resetCooldown 2	// 
#define PotionsMethod$remove 3			// (int)allow_drop
#define PotionsMethod$use 4				// 


#define PotionsFlag$no_drop 0x1			// Don't spawn an item if replaced
#define PotionsFlag$raise_event 0x2		// Raise event on the current level when potion is consumed
#define PotionsFlag$is_in_hud 0x4		// The potion is in HUD. Just have your avatar drop it

#define Potions$set(targ, name, texture, charges, flags, cooldown, spellData) runMethod(targ, "got Potions", PotionsMethod$setPotion, [name, texture, charges, flags, cooldown, spellData], NORET)
#define Potions$resetCooldown(targ) runMethod(targ, "got Potions", PotionsMethod$resetCooldown, [], NORET)
#define Potions$remove(targ, allow_drop) runMethod(targ, "got Potions", PotionsMethod$remove, [allow_drop], NORET)
#define Potions$use(targ) runMethod(targ, "got Potions", PotionsMethod$use, [], NORET)


#define PotionName$minorHealing "Pot_mHP"
#define PotionName$minorMana "Pot_mMP"
#define PotionName$greaterHealing "Pot_gHP"
#define PotionName$greaterMana "Pot_gMP"



