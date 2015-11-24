Script.Load("lua/Marine.lua")

function Marine_OnInitialized_Hook( self )
	-- initialize params
	self.duelParams = { medSpamInterval = 0, timeLastMedpack = 0 }
end

function Marine:SetMedSpamInterval( time )
	self.duelParams.medSpamInterval = time
end

local original_MarinesOnInitialized
original_MarinesOnInitialized = Class_ReplaceMethod("Marine", "OnInitialized", function (self)
	original_MarinesOnInitialized(self)
	Marine_OnInitialized_Hook(self)
end)
