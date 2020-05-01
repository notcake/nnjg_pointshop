POINTSHOP.Config = {}

-- Edit the lines below to your liking.
-- Do not delete any lines.
-- Just set each line to true or false, or a desired value.
-- Edit shop items in their respective files in the items folder.

POINTSHOP.Config.ShopKey = "F4" -- F1, F2, F3 or F4. Default is F4. Set to "None" to disable.

POINTSHOP.Config.ShopNotify = true -- Tell the player how many points they have and how to open the shop when they first spawn?

POINTSHOP.Config.DisplayPoints = false -- Shows players how many points they have on their screen.

POINTSHOP.Config.AlwaysDrawHats = false -- Should hats always be drawn? Override in your gamemode.

POINTSHOP.Config.PointsTimer = true -- Enable the timer for giving a player points for playing for a certain amount of time.
POINTSHOP.Config.PointsTimerDelay = 30 -- Delay in minutes between giving points.
POINTSHOP.Config.PointsTimerAmount = 10 -- Amount to give after the above delay.

POINTSHOP.Config.OnNPCKilled = false -- Give Points when an NPC is killed by a player?
POINTSHOP.Config.OnNPCKilledAmount = 10 -- Amount to give for killing an NPC.

POINTSHOP.Config.PlayerDeath = false -- Give Points when a player is killed by a player?
POINTSHOP.Config.PlayerDeathAmount = 10 -- Amount to give for killing a player.

POINTSHOP.Config.DonatorText = -- Donator text that will be showen in the donator Tab
[[
Thanks to:
Trivkz - Coding
!cake - Coding
_Undefined - Coding base PS
All donators - You're awesome :)

Want to earn points quickly? Want to gain an advantage?
You've just went to the right tab! 

Donate $10 or more to NoNerdsJustGeeks and post a donation thread in the correct forum;
You will be added to VIP shortly when done.

You'll gain two points for every legit kill, lose only one point for a team-kill,
and be able to votekick players if an admin isn't around to handle the issues that trouble-makers bring!

Also visit our website, we have other servers!
www.nonerdsjustgeeks.com
All bans are posted on:
www.nonerdsjustgeeks.com/bans]]

-- Don't edit this unless you know what you are doing.
-- No really, don't.

POINTSHOP.Config.SellCost = function(cost) -- Tells the shop how much to give a player back when they sell an item. Whatever you do, don't delete this function.
	-- return cost -- Full.
	return math.Round(cost * 0.75) -- Three quarters.
	-- return cost * 0.5 -- Half.
end

-- End config.