POINTSHOP.Config = {}

-- Edit the lines below to your liking.
-- Do not delete any lines.
-- Just set each line to true or false, or a desired value.
-- Edit shop items in the sh_items.lua file.

POINTSHOP.Config.ShopKey = "F4" -- F1, F2, F3 or F4. Default is F4.

POINTSHOP.Config.ShopNotify = true -- Tell the player how many points they have and how to open the shop when they first spawn?

POINTSHOP.Config.PointsTimer = true -- Enable the timer for giving a player points for playing for a certain amount of time.
POINTSHOP.Config.PointsTimerDelay = 30 -- Delay in minutes between giving points.
POINTSHOP.Config.PointsTimerAmount = 10 -- Amount to give after the above delay.

POINTSHOP.Config.DonatorText = -- Donator text that will be showen in the donator Tab
[[
===WE ARE CURRENTLY FIXING TRAILS===

If you survive a round, and don't die, your trail won't re-appear 
the following round. We are going to fix this, please be
patient. If you don't want to buy a trail
until it is fixed, it's fine. If you
DO buy one, however, your trail will not
be lost when we fix this bug,
and no points will be lost.

Want to earn points quickly? For now
people who haven't donated or aren't admin
only gain one point for a legit kill,
and it's hard to get points for anything
you want. 

Want to make it a lot easier?
Donate $10 or more to www.nonerdsjustgeeks.com
and post a donation thread in the correct
forum, we'll add you to VIP ASAP;

You will gain two points for every legit kill, 
lose only one point for a team-kill, and be able
to votekick players that are breaking the rules,
causing trouble and being general dicks.

Also visit our website, we have other servers!
www.nonerdsjustgeeks.com
All bans are posted on:
www.nonerdsjustgeeks.com/bans]]


-- Don't edit this unless you know what you are doing.
-- No really, don't.

POINTSHOP.Config.SellCost = function(cost) -- Tells the shop how much to give a player back when they sell an item. Whatever you do, don't delete this function.
	-- return cost -- Full.
	return cost * 0.75 -- Three quarters.
	-- return cost * 0.5 -- Half.
end

-- End config.