local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local Duration = Bollo:NewModule("Duration")

function Duration:OnEnable()
	Bollo.RegisterCallback(self, "OnUpdate")
end

function Duration:OnUpdate()
end
