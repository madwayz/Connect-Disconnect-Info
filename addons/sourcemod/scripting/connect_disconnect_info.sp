#include <sourcemod>
#include <csgo_colors>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Announce Message",
	author = "madwayz",
	description = "Заменяет стандартные сообщение при подключении и отключении игроков",
	version = "1.0.0",
	url = ""
}

#define SPECTATOR_TEAM 1
#define TERRORIST_TEAM 2
#define COUNTER_TERRORIST_TEAM 3

public void OnPluginStart()
{
	LoadTranslations("connect_disconnect_info.phrases");
	HookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre);
	HookEvent("player_connect", OnPlayerConnect, EventHookMode_Pre);
	HookEvent("player_team", Event_PlayerTeam, EventHookMode_Pre);
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	char sName[128];
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	int iRounds = GameRules_GetProp("m_totalRoundsPlayed");
	event.GetString("name", sName, sizeof(sName));
	event.BroadcastDisabled = true;
	int iTeam = event.GetInt("team");

	if (iTeam == TERRORIST_TEAM) CGOPrintToChatAll("%t", "player_team_t", iClient);
	else if (iTeam == COUNTER_TERRORIST_TEAM) CGOPrintToChatAll("%t", "player_team_ct", iClient);
	else if (iTeam == SPECTATOR_TEAM) {
		if(iClient && CheckAdminMenuFlag(iClient) && iRounds != 15)
		{
			CGOPrintToChatAll("%t", "player_team_spec", iClient, iClient);
		}
	}
}

public void OnPlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
	char sName[128], sReason[192];
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	if(!dontBroadcast) event.BroadcastDisabled = true;
	event.GetString("reason", sReason, sizeof(sReason));
	event.GetString("name", sName, sizeof(sName));
	if(iClient && CheckAdminMenuFlag(iClient))
	{
		CGOPrintToChatAll("%t", "player_connect", iClient, iClient);
	}

}

public void OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	char sReason[64];
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	if(!dontBroadcast) event.BroadcastDisabled = true;
	event.GetString("reason", sReason, sizeof(sReason));

	if(IsValidClient(iClient) && GetClientTeam(iClient) >= 0 && iClient && CheckAdminMenuFlag(iClient)) {
		if(StrContains(sReason, "Disconnect") >= 0) CGOPrintToChatAll("%t", "player_disconnect", iClient, iClient);
		else {
			if (StrContains(sReason, "Забанен админом:", false) >= 0 ||
				StrContains(sReason, "Banned by administrator", false) >= 0 ||
				StrContains(sReason, "You was banned by admin", false) >= 0) sReason = "Забанен администратором";
			else if(StrContains(sReason, "Вы были кикнуты за AFK", false) >= 0) sReason = "AFK";
			else if(StrContains(sReason, "timed out", false) >= 0) sReason = "Разорвалось соединение";
			else if(StrContains(sReason, "No user logon", false) >= 0) sReason = "Пользователь не авторизован";
			else if(StrContains(sReason, "Kicked by GameVoting", false) >= 0) sReason = "Кикнут голосованием";
			else if(StrContains(sReason, "Kicked", false) >= 0) sReason = "Кикнут администратором";
			else if(StrContains(sReason, "You was banned by admin: |乡|", false) >= 0) sReason = "Забанен голосованием";
			else if(StrContains(sReason, "VAC banned from secure server", false) >= 0) sReason = "Заблокирован VAC'ом";
			else if(StrContains(sReason, "VAC authentication error", false) >= 0) sReason = "Ошибка VAC";
			else if(StrContains(sReason, "Сервер перезапускается. Попробуйте", false) >= 0) sReason = "Сервер перезапускается";
			else if(StrContains(sReason, "[Warn System]", false) >= 0) sReason = "Получил предупреждение";
			else sReason = "Причина неизвестна";
			CGOPrintToChatAll("%t", "player_flyout", iClient, sReason);
		}
	}
}

bool CheckAdminMenuFlag(int iClient)
{
	if(GetUserFlagBits(iClient) != ADMFLAG_GENERIC) return false;
	return true;
}

stock bool IsValidClient(int client)
{
  return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client) && !IsFakeClient(client));
}
