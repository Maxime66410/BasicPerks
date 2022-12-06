#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <sdktools_gamerules>
#include <dhooks>

#pragma newdecls required // enforces new syntax
#define ZPSMAXPLAYERS 24
#define Version "1.0"
#define CVarFlags FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY

// Get round start offset
DynamicDetour ddOnRoundStart = null;

GameData g_pGameConfig = null;

public Plugin myinfo =
{
	name = "Basic Perks",
	author = "Maxime66410 | Furrany Studio",
	description = "Add Basic Perks for gameplay improvement",
	version = SOURCEMOD_VERSION,
	url = "https://furranystudio.fr"
};

public void OnPluginStart()
{
    g_pGameConfig = new GameData("zpsbasicperks");
    if(g_pGameConfig == null)
    {
        SetFailState("Gamedata file zpsbasicperks.txt is missing");
        return;
    }

    ddOnRoundStart = DynamicDetour.FromConf(g_pGameConfig, "OnRoundStart");
    if(ddOnRoundStart == null)
    {
        SetFailState("Failed to setup OnRoundStart detour. Update your Gamedata!");
        return;
    }
    ddOnRoundStart.Enable(Hook_Post, Hook_OnRoundStart);
}

public MRESReturn Hook_OnRoundStart()
{   
    // Round has started
    // Get all players
    int iPlayers = MaxClients;
    for(int i = 1; i <= iPlayers; i++)
    {
        // Check if player is connected
        if(IsClientInGame(i))
        { 
            // Get player's class
            int iClass = GetClientTeam(i);

            // Check if player is not a zombie and not a spectator
            if(iClass == 2)
            {
                // Give player perks
                ShowBasicPerks(i, true);
            }
        }
    }
    return MRES_Ignored;
}

public Action EventRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    return Plugin_Continue;
}


public int PanelHandler1(Menu menu, MenuAction action, int param1, int param2)
{
    if (action == MenuAction_Select)
    {
        switch(param2)
        {
            case 1:
            {
                PrintToConsole(param1, "You selected perk : Runner");
                PrintToConsole(param1, "Speed + 15% | - 15% Health");
                PrintToConsole(param1, "You get melee weapon is Wooden Plank");
                GivePerks(param1, param2);
                return;
            }
            case 2:
            {
                PrintToConsole(param1, "You selected perk : Medic => Health");
                PrintToConsole(param1, "Health + 10% | Regen + 15%");
                PrintToConsole(param1, "You get Green inoculator and Red inoculator");
                GivePerks(param1, param2);
                return;
            }
            case 3:
            {
                PrintToConsole(param1, "You selected perk : Tank");
                PrintToConsole(param1, "Health + 20% | Speed - 10% | Damage + 10% | Armor + 30%");
                PrintToConsole(param1, "You get Sledgehammer");
                GivePerks(param1, param2);
                return;
            }
            default:
            {
                PrintToConsole(param1, "You selected nothing");
                return;
            }
                
        }
    }
    else if (action == MenuAction_Cancel)
    {
        PrintToServer("Client %d's menu was cancelled.  Reason: %d", param1, param2);
    }
}
 
public Action ShowBasicPerks(int client, int args)
{
    Panel panel = new Panel();
    panel.SetTitle("--- Perks Menu ---");
    panel.DrawItem("Runner");
    panel.DrawItem("Medic");
    panel.DrawItem("Tank");
 
    panel.Send(client, PanelHandler1, 20);
 
    delete panel;
 
    return Plugin_Handled;
}

// Give Perks to player
public void GivePerks(int client, int perk)
{
    switch(perk)
    {
        case 1:
        {
            // Runner
            SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 200.0);
            SetEntityHealth(client, 100 - 15);
            GivePlayerItem(client, "weapon_plank");
            return;
        }
        case 2:
        {
            // Medic
            SetEntityHealth(client, 100 + 20);
            GivePlayerItem(client, "weapon_inoculator_delay");
            GivePlayerItem(client, "weapon_inoculator_full");
            return;
        }
        case 3:
        {
           // Tank
            
            // Strip all weapons
            // Get all Inventory m_iCurrentInventorySlot
            int iInventory = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons");
            if(iInventory != 0)
            {
                int iInventoryCount = GetEntPropArraySize(client, Prop_Send, "m_hMyWeapons");
                /*PrintToChatAll("Inventory Count : %d", iInventoryCount);*/
                for(int i = 0; i < iInventoryCount; i++)
                {
                    int iInventorySlot = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", i);
                    if(iInventorySlot != 0 && iInventorySlot >= 1)
                    {
                        // CStripWeapons
                        //PrintToChatAll("Inventory Slot : %d", iInventorySlot);
                        RemovePlayerItem(client, iInventorySlot);
                    }
                }
            }

            // Give Tank Perks
            SetEntityHealth(client, 100 + 100);
            GivePlayerAmmo(client, 100, 2, false);
            GivePlayerAmmo(client, 100, 1, false);
            GivePlayerAmmo(client, 100, 3, false);
            // Give player sledgehammer in slot 1
            GivePlayerItem(client, "weapon_sledgehammer");
            return;
        }
        default:
        {
            PrintToConsole(client, "You selected nothing");
            return;
        }
            
    }
}