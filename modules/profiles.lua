local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local profiles = bollo:NewModule("Profiles")

function profiles:OnInitialize()
	if not self.options then
		self.options =  LibStub("AceDBOptions-3.0"):GetOptionsTable(bollo.db)
	end
	bollo:AddOptions(self)
end
