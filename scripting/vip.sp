#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <cstrike>

#define WEAPONS_MAX_LENGTH 32

#define WEAPONS_SLOTS_MAX 5

enum WeaponsSlot
{
    Slot_Invalid        = -1,
    Slot_Primary        = 0,
    Slot_Secondary      = 1,
    Slot_Melee          = 2,
    Slot_Projectile     = 3,
    Slot_Explosive      = 4,
    Slot_NVGs           = 5
}

public Plugin:myinfo =
{
    name = "VIP",
    author = "Aleksander Niedźwiedź",
    description = "VIP",
    version = "1.0",
    url = "https://github.com/shadaxv"
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	MarkNativeAsOptional("GetEngineVersion");
}

#define WEAPONS_MAX_LENGTH 32

#define WEAPONS_SLOTS_MAX 5


public OnPluginStart()
{
	HookEvent("round_start",Event_RoundStart,EventHookMode_Post);
}

public Action:Event_RoundStart(Handle:event,const String:name[],bool:dontBroadcast)
{
	for (new client = 1; client < MaxClients + 1; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			if(GetAdminFlag(GetUserAdmin(client), Admin_Custom4))
			{
				Kevlar(client, 2);
				Health(client, 40, 1);
				Grenade(client, 3);
				new money = GetEntData(client, FindSendPropOffs("CCSPlayer", "m_iAccount"));
				SetEntData(client, FindSendPropOffs("CCSPlayer", "m_iAccount"), money + 1500);
			}

			else if(GetAdminFlag(GetUserAdmin(client), Admin_Custom3))
			{
				Kevlar(client, 2);
				Health(client, 25, 1);
				Grenade(client, 2);
				new money = GetEntData(client, FindSendPropOffs("CCSPlayer", "m_iAccount"));
				SetEntData(client, FindSendPropOffs("CCSPlayer", "m_iAccount"), money + 1000);
			}

			else if(GetAdminFlag(GetUserAdmin(client), Admin_Custom2))
			{
				Kevlar(client, 1);
				Health(client, 15, 1);
				Grenade(client, 1);
				new money = GetEntData(client, FindSendPropOffs("CCSPlayer", "m_iAccount"));
				SetEntData(client, FindSendPropOffs("CCSPlayer", "m_iAccount"), money + 750);
			}

			if(GetAdminFlag(GetUserAdmin(client), Admin_Custom5))
			{
			
			}
		}
	}
}

public Health(client, amount, type)
{
	switch(type)
	{
		case 1:
		{
			SetEntityHealth(client, GetClientHealth(client) + amount);
		}
		case 2:
		{
			SetEntityHealth(client, amount);
		}
	}
}

public Kevlar(client, type)
{
	switch(type)
	{
		case 1:
		{
			SetEntProp(client, Prop_Send,"m_ArmorValue", 100, 1);
		}
		case 2:
		{
			GivePlayerItem(client, "item_assaultsuit");
			SetEntProp(client, Prop_Send,"m_ArmorValue", 100, 1);
		}
	}
}

public Medishot(client)
{
	new String:healthshot[] = "healthshot";
	new String:c4[] = "c4";
	if(!WeaponsClientHasWeapon(client, c4))
	{
		if(!WeaponsClientHasWeapon(client, healthshot))
		{
			GivePlayerItem(client, "weapon_healthshot");
		}
	}
	else
	{
		new ent = GetPlayerWeaponSlot(client, 4);
		RemovePlayerItem(client, ent);
		RemoveEdict(ent);
		if(!WeaponsClientHasWeapon(client, healthshot))
		{
			GivePlayerItem(client, "weapon_healthshot");
		}
		GivePlayerItem(client, "weapon_c4");
	}
}

public Grenade(client, type)
{
	new String:flashbang[] = "flashbang";
	new String:smokegrenade[] = "smokegrenade";
	new flash = WeaponsClientHasWeapon(client, flashbang);
	new smoke = WeaponsClientHasWeapon(client, smokegrenade);
	switch(type)
	{
		case 1:
		{
			GivePlayerItem(client, "weapon_flashbang");
			GivePlayerItem(client, "weapon_decoy");
		}
		case 2:
		{
			GivePlayerItem(client, "weapon_smokegrenade");
			GivePlayerItem(client, "weapon_flashbang");
			GivePlayerItem(client, "weapon_decoy");
		}
		case 3:
		{
			GivePlayerItem(client, "weapon_smokegrenade");
			GivePlayerItem(client, "weapon_flashbang");
			GivePlayerItem(client, "weapon_flashbang");
			GivePlayerItem(client, "weapon_decoy");
		}
	}
}

//disabled
/*public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker_index = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(GetAdminFlag(GetUserAdmin(attacker_index), Admin_Custom5))
	{
		new playerHealth = GetClientHealth(attacker_index);
		new playerHealth2 = 0;
		if(playerHealth < 101 && playerHealth > 94)
		{
			health(attacker_index, 100, 2);
			playerHealth2 = 100 - playerHealth;
			PrintToChat(attacker_index, " \x10[HP] \x01Otrzymałeś \x10%d\x01 HP za zabójstwo.", playerHealth2);
		}
		else if(playerHealth < 95)
		{
			health(attacker_index, 5, 1);
			playerHealth2 = 5;
			PrintToChat(attacker_index, " \x10[HP] \x01Otrzymałeś \x10%d\x01 HP za zabójstwo.", playerHealth2);
		}
	}

	return Plugin_Continue;
}*/

stock bool:WeaponsClientHasWeapon(client, const String:weapon[])
{
    new weapons[WeaponsSlot];
    WeaponsGetClientWeapons(client, weapons);

    decl String:classname[64];

    for (new x = 0; x < WEAPONS_SLOTS_MAX; x++)
    {
	
        if (weapons[x] == -1)
        {
            continue;
        }

        GetEdictClassname(weapons[x], classname, sizeof(classname));
        ReplaceString(classname, sizeof(classname), "weapon_", "");
        if (StrEqual(weapon, classname, false))
        {
            return true;
        }
    }

    return false;
}

stock WeaponsGetClientWeapons(client, weapons[WeaponsSlot])
{
    for (new x = 0; x < WEAPONS_SLOTS_MAX; x++)
    {
        weapons[x] = GetPlayerWeaponSlot(client, x);
    }
}

stock WeaponsGetDeployedWeaponIndex(client)
{
    return GetEntDataEnt2(client, offsActiveWeapon);
}

stock WeaponsSlot:WeaponsGetDeployedWeaponSlot(client)
{

    new weapons[WeaponsSlot];
    WeaponsGetClientWeapons(client, weapons);

    new deployedweapon = WeaponsGetDeployedWeaponIndex(client);

    if (deployedweapon == -1)
    {
        return Type_Invalid;
    }

    for (new x = 0; x < WEAPONS_SLOTS_MAX; x++)
    {
        if (weapons[x] == deployedweapon)
        {
            return WeaponsSlot:x;
        }
    }

    return Type_Invalid;
}
