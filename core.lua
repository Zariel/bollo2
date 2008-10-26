local LCH = LibStub("CallbackHandler-1.0", true)
assert(LCH, "Bollo requires CallbackHandler-1.0")

Bollo = LibStub("AceAddon-3.0"):NewAddon("Bollo2", "AceEvent-3.0")

function Bollo:OnInitialize()
	self.events = LCH:New(Bollo)
	self.db = LibStub("AceDB-3.0"):New("BolloDB2", {})

	self.frame = CreateFrame("Frame")

	local timer = 1

	local OnUpdate = function(self, elapsed)
		if timer >= 1 then
			Bollo.events:Fire("OnUpdate")
		else
			timer = timer + elapsed
		end
	end

	function Bollo.events:OnUsed(target, event)
		if event == "OnUpdate" then
			Bollo.frame:SetScript("OnUpdate", OnUpdate)
		end
	end

	function Bollo.events:OnUnuse(target, event)
		if event == "OnUpdate" then
			Bollo.frame:SetScript("OnUpdate", nil)
		end
	end
end

function Bollo:OnEnable()
	local bf = _G["BuffFrame"]
	bf:UnregisterAllEvents()
	bf:Hide()
	bf:SetScript("OnUpdate", nil)
	bf:SetScript("OnEvent", nil)
	_G.BuffButton_OnUpdate = nil

	local defaults = {
		profile = {
			max = 40,
			perRow = 20,
			size = 32,
			spacing = 20,
			rowSpacing = 25,
			growthX = "LEFT",
			growthY = "DOWN",
			anchor = "TOPRIGHT",
			scale = 1,
			x = 0,
			y = 0,
			color = {
				r = 0,
				g = 1,
				b = 1,
				a = 0
			},
		},
	}

	self:NewDisplay("Buff", "HELPFUL", defaults)
	self:NewDisplay("Debuff", "HARMFUL", defaults)
	--self:RegisterEvent("PLAYER_AURAS_CHANGED")
	self:UNIT_AURA(nil, "player")
	self:RegisterEvent("UNIT_AURA")
end


function Bollo:UNIT_AURA(event, unit)
	if unit == "player" then
	    for _, mod in ipairs(self.registry) do
		    mod:Update()
	    end
	end
end
