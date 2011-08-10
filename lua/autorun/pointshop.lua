if not datastream then require("datastream") end

if SERVER then
	AddCSLuaFile("autorun/pointshop.lua")
	
	AddCSLuaFile("vgui/NNJGShop.lua")
	AddCSLuaFile("vgui/NNJGShopButton.lua")
	AddCSLuaFile("vgui/NNJGShopIcon.lua")
	AddCSLuaFile("vgui/NNJGShopTab.lua")
	AddCSLuaFile("vgui/NNJGShopItem.lua")
	AddCSLuaFile("vgui/NNJGShopPreview.lua")
	
	AddCSLuaFile("sh_pointshop.lua")
	AddCSLuaFile("sh_config.lua")
	AddCSLuaFile("sh_items.lua")
	AddCSLuaFile("cl_player_extension.lua")
	AddCSLuaFile("cl_pointshop.lua")
	AddCSLuaFile("VistaSkin.lua")
	
	include("sh_pointshop.lua")
	include("sh_config.lua")
	include("sh_items.lua")
	include("sv_player_extension.lua")
	include("sv_pointshop.lua")
end

if CLIENT then
	include("vgui/NNJGShop.lua")
	include("vgui/NNJGShopButton.lua")
	include("vgui/NNJGShopIcon.lua")
	include("vgui/NNJGShopTab.lua")
	include("vgui/NNJGShopItem.lua")
	include("vgui/NNJGShopPreview.lua")
	
	include("sh_pointshop.lua")
	include("sh_config.lua")
	include("sh_items.lua")
	include("cl_player_extension.lua")
	include("cl_pointshop.lua")
	include("VistaSkin.lua")
end