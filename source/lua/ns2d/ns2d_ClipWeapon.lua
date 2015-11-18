local originalOnReload
originalOnReload = Class_ReplaceMethod("ClipWeapon", "OnReload", 
	function(self, player)
		originalOnReload(self, player)
		// Fill this Clip to full:
		self:GiveAmmo(5, false)
	end)