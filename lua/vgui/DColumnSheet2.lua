local PANEL = {}

function PANEL:Init ()
end

function PANEL:GetActiveSheetName()
	return self.ActiveButton:GetText()
end

function PANEL:SetActiveButton(active)
	DColumnSheet.SetActiveButton(self, active)
	self:OnSheetChanged(active:GetText())
end

function PANEL:SetActiveSheet(name)
	for k, v in ipairs(self.Items) do
		if v.Button:GetText() == name then
			self:SetActiveButton(v.Button)
			break
		end
	end
end

-- Hooks
function PANEL:OnSheetChanged(name)
end

vgui.Register("DColumnSheet2", PANEL, "DColumnSheet")