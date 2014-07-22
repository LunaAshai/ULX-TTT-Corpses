function corpse_find( v ) -- Finds the corpse of a specified player.
        for _, ent in pairs( ents.FindByClass( "prop_ragdoll" ) ) do
		if ent.uqid == v:UniqueID() and ent:IsValid() then
			return ent or false
		end
	end
end

function corpse_identify( corpse ) -- Identifies the specified corpse.
	if corpse then
		player.GetByUniqueID( corpse.uqid ):SetNWBool( "body_found", true ) -- Setting the scoreboard to be as if the body had been found.
		CORPSE.SetFound( corpse, true ) -- Setting the body to be identified.
	end
end

function corpse_unidentify( corpse ) -- Unidentifies the specified corpse.
	if corpse then
		player.GetByUniqueID( corpse.uqid ):SetNWBool( "body_found", false ) -- Setting the scoreboard to be as if the body hasn't been found.
		CORPSE.SetFound( corpse, false ) -- Setting the body to be unidentified.
		SendFullStateUpdate()
	end
end

function ulx.identify( calling_ply, target_ply, unidentify )
	body = corpse_find( target_ply ) -- Do this to find the target's corpse.
	if not body then ULib.tsayError( calling_ply, "This player's corpse does not exist!", true ) return end

	if not unidentify then -- Check if ulx unidentify is being used instead.
		ulx.fancyLogAdmin( calling_ply, "#A identified #T's body!", target_ply )
		corpse_identify( body )
		
		if target_ply:GetRole() == ROLE_TRAITOR then
			SendConfirmedTraitors( GetInnocentFilter( false ) ) -- Update innocent's list of traitors.
			SCORE:HandleBodyFound( calling_ply:Nick(), body )
		end
	else
		ulx.fancyLogAdmin( calling_ply, "#A unidentified #T's body!", target_ply )
		corpse_unidentify( body )
	end
end
local identify = ulx.command( CATEGORY_NAME, "ulx identify", ulx.identify, "!identify" )
identify:addParam{ type=ULib.cmds.PlayerArg }
identify:addParam{ type=ULib.cmds.BoolArg, invisible=true }
identify:defaultAccess( ULib.ACCESS_SUPERADMIN )
identify:setOpposite( "ulx unidentify", {_, _, true}, "!unidentify", true )
identify:help( "Identifies a target's body." )
 
function ulx.removebody( calling_ply, target_ply )
	body = corpse_find( target_ply ) -- Do this to find the target's corpse.
	if not body then ULib.tsayError( calling_ply, "This player's corpse does not exist!", true ) return end

	ulx.fancyLogAdmin( calling_ply, "#A removed #T's body!", target_ply )

	if string.find( body:GetModel(), "zm_", 6, true ) then
		body:Remove()
	elseif body.player_ragdoll then
		body:Remove()
	end

end
local removebody = ulx.command( CATEGORY_NAME, "ulx removebody", ulx.removebody, "!removebody" )
removebody:addParam{ type=ULib.cmds.PlayerArg }
removebody:defaultAccess( ULib.ACCESS_SUPERADMIN )
removebody:help( "Removes a target's body." )
