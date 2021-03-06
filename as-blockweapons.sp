/* 
 * BlockWeapons plugin for StSv Community Server #1
 * Copyright (C) 2013-14 Mario6493 & Anarchy Steven
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 * 
 * For more info, see LICENSE file of this repository.
 */


#pragma semicolon 1 

#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <tf2items>
#include <tf2items_giveweapon>

#define AUTOLOAD_EXTENSIONS
#define REQUIRE_EXTENSIONS

new Handle:g_PluginActive = INVALID_HANDLE;
new String:curMapName[64];

public Plugin:myinfo = 
{
	name = "Block Weapons",
	author = "Anarchy Steven, Mario6493",
	description = "Blocks weapons. Duh.",
	version = "1.0",
	url = "http://www.gemini.software/"
}

public OnPluginStart()
{
	g_PluginActive = CreateConVar("tf_blockweapons_enabled", "1", "Is the weapon blocker enabled?", 0, true, 0.0, true, 1.0);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("post_inventory_application", Event_PlayerRegenerated, EventHookMode_Post);
}

public OnMapStart()
{
	GetCurrentMap(curMapName, sizeof(curMapName));
	
	SetConVarBool(g_PluginActive, (strncmp("arena_", curMapName, 6, false) == 0 || strncmp("vsh_", curMapName, 4, false) == 0));
}

public Event_PlayerSpawn(Handle:event,const String:name[],bool:dontBroadcast)
{
	if (GetConVarBool(g_PluginActive))
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));

		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			// Need a timer here because if we do it too early, our changes won't take effect
			CreateTimer(0.1, Timer_WeaponCheck, client);
		}
	}
}

public Event_PlayerRegenerated(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarBool(g_PluginActive))
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));

		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			CreateTimer(0.1, Timer_WeaponCheck, client);
		}
	}
}

public Action:Timer_WeaponCheck(Handle:timer, any:client)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client)) 
	{
		new TFClassType:playerClass = TF2_GetPlayerClass(client);
		
		switch (playerClass)
		{
			case TFClass_Spy: 
			{
				if (strncmp("arena_", curMapName, 6, false) == 0)
				{
					if (Weapon_IsBlocked(client, 4))
					{
						// If blocked, remove weapon slot (PDA2) and give Invis Watch instead.
						TF2_RemoveWeaponSlot(client, 4);
						TF2Items_GiveWeapon(client, 30);
						PrintToChat(client, "The Cloak and Dagger is disabled in this gamemode.");
					}
				}
			}
			case TFClass_Scout: 
			{
				if (strncmp("vsh_", curMapName, 4, false) == 0)
				{
					if (Weapon_IsBlocked(client, 0))
					{
						// If blocked, remove weapon slot (Primary) and give Scattergun instead.
						TF2_RemoveWeaponSlot(client, 0);
						TF2Items_GiveWeapon(client, 13);
						PrintToChat(client, "The Baby Face's Blaster is disabled in this gamemode.");
					}
				}
			}
			case TFClass_Engineer:
			{
				if (strncmp("vsh_", curMapName, 4, false) == 0)
				{
					if (Weapon_IsBlocked(client, 1))
					{
						// If blocked, remove weapon slot (Secondary) and give Pistol instead.
						TF2_RemoveWeaponSlot(client, 1);
						TF2Items_GiveWeapon(client, 22);
						PrintToChat(client, "The Short Circuit is disabled in this gamemode.");
					}
				}
			}
		}
		
	}
}

stock bool:Weapon_IsBlocked(client, slot)
{
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, slot));

	new currentWeapon = GetEntDataEnt2(client, FindSendPropOffs("CTFPlayer", "m_hActiveWeapon"));
	if (IsValidEntity(currentWeapon))
	{
		switch (GetEntProp(currentWeapon, Prop_Send, "m_iItemDefinitionIndex"))
		{
			case  60, 528, 772: return true;
		}
	}

	return false;
}