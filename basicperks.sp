#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <sdktools_gamerules>
#include <dhooks>

#define ZPSMAXPLAYERS 24
#define Version "1.0"
#define CVarFlags FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY

new BasicPerksOffSet = -1;


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
    RegConsoleCmd("sm_showbasicperks", ShowBasicPerks);

    new Handle:hGameData = LoadGameConfigFile("zpsbasicperks");
    BasicPerksOffSet = GameConfGetOffset(hGameData, "OnRoundStart");
    CloseHandle(hGameData);

    if(BasicPerksOffSet == -1)
    {
        PrintToServer("[Basic Perks] BasicPerks OffSet not found");
        return;
    }
    else
    {
        PrintToServer("[Basic Perks] BasicPerks OffSet found");
    }
    
    //HookEvent("player_spawn", EventRoundStart);
}


public Action EventRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    // Get round state 
    int roundState = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
    PrintCenterTextAll("Round State: %d", roundState);

    //ShowBasicPerks(client, client);
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
            SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", 5.0);
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
            SetEntityHealth(client, 100 + 100);
            GivePlayerAmmo(client, 100, 2, false);
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

//  If player hit a zombie or a entity with this function, he will get damage
/*public void OnTakeDamage(int &attacker, int &inflictor, int &victim, float &damage, int &damagetype, int &weapon, int &hitgroup, int &dmgflags)
{
    if (GetEntProp(victim, Prop_Send, "m_iClass") == 1)
    {
        if (GetEntProp(attacker, Prop_Send, "m_iClass") == 2)
        {
            if (GetEntProp(attacker, Prop_Send, "m_iPerk") == 3)
            {
                PrintCenterText(attacker, "-%f", damage);
            }
        }
    }
}*/