#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <zr_grenade_effects>

float g_fMaxTime[MAXPLAYERS+1];

bool g_bEnabled;
float g_fInterval
int g_iCash;

ConVar g_CvarEnable, g_CvarInterval, g_CvarCash;

public Plugin myinfo =
{
	name = "Napalm Grenade Burning Cash",
	author = "Oylsister",
	description = "Give a player a money while napalm grenade still burning the zombies",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	g_CvarEnable = CreateConVar("zr_napalm_burn_cash_enabled", "1.0", "Enabled This plugin or not", _, true, 0.0, true, 1.0);
	g_CvarInterval = CreateConVar("zr_napalm_burn_cash_interval", "0.2", "Every X second while napalm still burn victim will get cash", _, true, 0.1, false);
	g_CvarCash = CreateConVar("zr_napalm_burn_cash_money", "10", "How much cash player will receive per X second while napalm still burn victim", _, true, 1.0, false);
	
	HookConVarChange(g_CvarEnable, OnConVarChange);
	HookConVarChange(g_CvarInterval, OnConVarChange);
	HookConVarChange(g_CvarCash, OnConVarChange);
}

public void OnConVarChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (convar == g_CvarEnable)
	{
		g_bEnabled = !g_bEnabled;
	}
	else if (convar == g_CvarInterval)
	{
		g_fInterval = GetConVarFloat(g_CvarInterval);
	}
	else
	{
		g_iCash = GetConVarInt(g_CvarCash);
	}
}

public int ZR_OnClientIgnited(int client, int attacker, float duration)
{
	g_fMaxTime[attacker] = GetEngineTime() + duration;
	
	CreateTimer(g_fInterval, GiveAttackerMoney, attacker, TIMER_REPEAT);
}

public Action GiveAttackerMoney(Handle timer, any client)
{
	int g_iClientCash;
		
	if(GetEngineTime() < g_fMaxTime[client])
	{
		g_iClientCash = GetEntProp(client, Prop_Send, "m_iAccount");
		SetEntProp(client, Prop_Send, "m_iAccount", g_iClientCash + g_iCash);
		return Plugin_Continue;
	}
	
	else
	{
		return Plugin_Stop;
	}
}