local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local Sort = bollo:NewModule("Sort")

local table_sort = table.sort

function Sort:OnInitialize()
	local defaults = {
		profile = {
		}
	}

	self.db = bollo.db:RegisterNamespace("Bollo-Sort", defaults)
end

function Sort:OnEnable()
	bollo.RegisterCallback(self, "PreUpdateIcons")
end

local SortTimeleft = function(a, b)
	a = a and a:GetTimeLeft() or 0
	b = b and b:GetTimeLeft() or 0
	return a > b
end

local SortAlphabetical = function(a, b)
	return a:GetBuff() > b:GetBuff()
end

function Sort:PreUpdateIcons(event, icons)
	return table_sort(icons, SortTimeleft)
	--return table_sort(icons, SortAlphabetical)
end
