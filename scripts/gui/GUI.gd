extends CanvasLayer

#var total_coins = 100

func update_GUI(coins):
	$Interface/CoinCounter/Coins.text = String(coins)
#	$Interface/CoinCounter/Total.text = "/" + String(total_coins)

func update_weapon_GUI(arrow_level, stored_arrow):
	$Interface/WeaponGUI/ArrowLevel.text = str(arrow_level)
	$Interface/WeaponGUI/StoredArrow.text = str(stored_arrow)


