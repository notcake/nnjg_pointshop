local SKIN = {}

SKIN.PrintName			= "FusionRP" -- It wasn't green to start with.
SKIN.Author				= "Rokrox" -- FusionRP.net, all credits to this guy.
SKIN.DermaVersion		= 1.4
--skin.text_normal		= Color( 100, 100, 100, 255 )
--skin.control_color_active = Color(120, 120, 180, 255)
--skin.tooltip			= Color( 45, 145, 215, 255 )

SKIN.colOutline	= Color( 0, 100, 20, 200 )


SKIN.text_bright				= Color( 5, 100, 10, 255 )
SKIN.text_normal				= Color( 255, 255, 255, 255 )
SKIN.text_dark					= Color( 150, 150, 150, 255 )
SKIN.text_highlight				= Color( 225, 200, 200, 255 )
SKIN.fontButton					= "DefaultSmall"
SKIN.fontTab					= "DefaultSmall"
SKIN.bg_color					= Color( 50, 50, 50, 155)
SKIN.bg_color_dark				= Color( 25, 25, 25, 155)
SKIN.bg_color_sleep				= Color( 50, 50, 50, 100)
SKIN.bg_color_bright				= Color( 150, 150, 150, 175 )
SKIN.colPropertySheet 			= Color( 50, 50, 50, 200 )
SKIN.colTab			 			= Color ( 10, 250, 30 ,255)
SKIN.colTabText		 			= Color( 255, 255, 255, 255 )
SKIN.colTabTextInactive			        = Color( 155, 155, 155, 225 )
SKIN.colButtonText				= Color( 192, 192, 192, 255 )
SKIN.colButtonTextDisabled			= Color( 25, 25, 25, 255 )
SKIN.colTabInactive				= Color( 100, 100, 100, 255 )
SKIN.colTabShadow				= Color( 0, 0, 0, 150 )
SKIN.fontButton					= "DefaultSmall"
SKIN.fontTab					= "DefaultSmall"
SKIN.listview_hover				= Color( 5, 100, 10, 140 )
--SKIN.bg_alt2					= Color( 230, 100, 10, 200 )
SKIN.listview_selected			= Color( 15, 100, 10, 140 )
SKIN.control_color 				= Color( 10, 240, 60, 255 )
SKIN.control_color_highlight	        = Color( 15, 255, 5, 200 )
SKIN.control_color_active 		= Color( 28, 223, 10, 245 )
SKIN.control_color_bright 		= Color( 255, 100, 10, 235 )
SKIN.control_color_dark 		= Color( 10, 225, 30, 255 )
SKIN.colCategoryText			= Color( 15, 100, 10, 255 )
SKIN.colCategoryTextInactive	= Color( 15, 100, 10, 255 )
SKIN.fontCategoryHeader			= Color( 0, 0, 0, 255 )
SKIN.colTextEntryText		= Color( 75, 75, 75, 255 )
SKIN.colTextEntryTextHighlight	= Color( 30, 255, 10, 255 )
SKIN.colCategoryText			= Color( 45, 240, 10, 255 )
SKIN.colCategoryTextInactive	= Color( 10, 240, 20, 255 )
SKIN.fontCategoryHeader			= Color( 0, 0, 0, 255 )
SKIN.tooltip				= Color( 30, 100, 10, 160 )
SKIN.colMenuBG				= Color( 15, 100, 10, 210 )
SKIN.fontFrame					= "DefaultSmall"
SKIN.fontCategoryHeader			= "DefaultSmall"

function SKIN:PaintButton(button)
	button:SetTextColor(SKIN.colButtonText)
	
	local w, h = button:GetSize()
	local x, y = 0,0
	
	local bordersize = 8
	if w <= 32 or h <= 32 then bordersize = 4 end -- This is so small buttons don't look messed up
	
	if button.m_bBackground then
		local color1 = Color(50, 50, 50, 255)
		local color2 = Color(70, 70, 70, 150)
		
		if button:GetDisabled() then
			color2 = Color(80, 80, 80, 255)
		elseif button.Depressed or button:IsSelected() then
			/*x, y = w*0.05, h*0.05
			w = w *0.9
			h = h * 0.9*/
			color2 = Color(color2.r + 0, color2.g + 255, color2.b + 85, color2.a + 150)
		elseif button.Hovered then
			color1 = Color(color1.r + 40, color1.g + 40, color1.b + 40, color1.a)
			color2 = Color(color2.r + 40, color2.g + 40, color2.b + 40, color2.a + 40)
		end
		draw.RoundedBox(bordersize, x, y, w, h, color1)
		draw.RoundedBox(bordersize, x+1, y+1, w-2, h-2, color2)
		draw.RoundedBox(bordersize, x+1, y+1, w-2, (h-2)/2, Color(color2.r + 80, color2.g + 80, color2.b + 80, 50))
	end
end

/*---------------------------------------------------------
	TinyButton
---------------------------------------------------------*/

--function SKIN:Paint()

	--if ( !self.m_bSelected ) then
		--if ( !self.m_bAlt ) then return end
			--surface.SetDrawColor( 255, 255, 255, 10 )
		--else
			--surface.SetDrawColor( 0, 255, 0, 250 )
		--end

	--self:DrawFilledRect()

--end

/*---------------------------------------------------------
	ScrollBarGrip
---------------------------------------------------------*/
function SKIN:PaintScrollBarGrip( panel )

	local w, h = panel:GetSize()
	
	local col = self.control_color
	
	if ( panel.Depressed ) then
		col = self.control_color_active
	elseif ( panel.Hovered ) then
		col = self.control_color_highlight
	end
		
	draw.RoundedBox( 2, 0, 0, w, h, Color( 0, 0, 0, 230 ) )
	draw.RoundedBox( 2, 1, 1, w-2, h-2, Color( col.r + 30, col.g + 30, col.b + 30 ) )
	draw.RoundedBox( 2, 2, 2, w-4, h-4, col )
		
	draw.RoundedBox( 0, 3, h*0.5, w-6, h-h*0.5-2, Color( 0, 0, 0, 25 ) )

end

function SKIN:PaintOverButton( panel ) end

derma.DefineSkin("FusionRP", "Made by Rokrox.", SKIN)