dofile("sys/lua/timerex.lua")
-- stun gun script
if stunGun == nil then stunGun = {} end
function stunGun.initTheArray(limit,value)
	if value == nil then value = 0 end
	array = {}
	for i=1,limit do
		array[i] = value
	end
	return array
end

stunGun.CONST_AMMO = 4 -- cartridges for the stun gun
stunGun.CONST_SHAKE = 150 -- 50 shake value = 1 sec, thus total 3sec shake
stunGun.CONST_SPEEDMOD = -25 -- slowdown value when stunned
stunGun.CONST_STUNNED_TIME = 5000 --ms
stunGun.CONST_HURT_WHEN_STUNNED = 1 -- 0 = damage, 1 = no damage

stunGun.player = stunGun.initTheArray(32)

addhook("attack2", "stunGun.attack2")
addhook("spawn", "stunGun.spawn")
addhook("team", "stunGun.team")
addhook("leave", "stunGun.leave")
addhook("hit", "stunGun.hit")

function stunGun.attack2(id, mode)
	if player(id, "team") == 2 then
		if player(id, "weapontype") == 1 then
			if mode == 1 then
				stunGun.player[id].enabled = true
			else
				stunGun.player[id].enabled = false
			end
		end
	end
end
function stunGun.spawn(id)
	if player(id, "team") == 2 then
		stunGun.player[id].ammo = stunGun.CONST_AMMO
	end
end
function stunGun.team(id, team, look)
	if team == 2 then
		stunGun.player[id] = {
			enabled = false,
			ammo = stunGun.CONST_AMMO,
		}
		msg2(id, "\169255255255Stun Gun equiped, \169255080090"..stunGun.player[id].ammo.." \169255255255cartridges left")
	end
end
function stunGun.leave(id)
	if stunGun.player[id] ~= 0 then
		stunGun.player[id] = nil
		stunGun.player[id] = 0
	end
end
function stunGun.hit(vid, sid, wep, hpdmg, apdmg, rawdmg, objid)
	local r = 0
	if (player(sid, "team") == 2) and (player(vid, "team") == 1) then
		if wep == 1 then
			if stunGun.player[sid].enabled then
				if stunGun.player[sid].ammo > 0 then
					stunGun.player[sid].ammo = stunGun.player[sid].ammo - 1
					msg2(vid, "\169255255255You have been stunned by \169050120255"..player(sid, "name"))
					print(player(sid, "name").." stunned "..player(vid, "name").." ("..stunGun.player[sid].ammo.." left)")
					msg2(sid, "\169255080090"..stunGun.player[sid].ammo.." \169255255255cartridges left")
					parse('speedmod '..vid..' '..stunGun.CONST_SPEEDMOD)
					parse('shake '..vid..' '..stunGun.CONST_SHAKE)
					timerEx(stunGun.CONST_STUNNED_TIME, function(vid)
						parse('speedmod '..vid..' 0')
					end, 1, vid)
					r = stunGun.CONST_HURT_WHEN_STUNNED
				end
			end
		end
	end
	return r
end