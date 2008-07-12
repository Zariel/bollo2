local bollo = LibStub("AceAddon-3.0"):GetAddon(bollo)
local conf = bollo:NewModule("Config")

function conf:OnEnable()
end

function bollo:OnModuleCreated(module)
	self:Print(module)
end
