#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <csgo_colors>

public Plugin myinfo =
{
	name = "Connect and Disconnect Info [CS:GO]",
	author = "1mpulse & modified by madwayz",
	description = "Заменяет стандартные сообщение при подкл./откл. игроков",
	version = "1.0.0",
	url = ""
}
public void OnPluginStart() 
{
	LoadTranslations("connect_disconnect_info.phrases");
	HookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre);
	HookEvent("player_connect", OnPlayerConnect, EventHookMode_Pre);
}

public void OnPlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
	char sName[128], sReason[192], szBuffer[512];
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	if(!dontBroadcast) event.BroadcastDisabled = true;
	event.GetString("reason", sReason, sizeof(sReason));
	event.GetString("name", sName, sizeof(sName));
	FormatEx(szBuffer, sizeof(szBuffer), "%T", "player_connect", iClient, sName);
	CGOPrintToChatAll(szBuffer);
}

public void OnPlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	char sReason[64];
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	if(!dontBroadcast) event.BroadcastDisabled = true;
	event.GetString("reason", sReason, sizeof(sReason));
	if(StrContains(sReason, "Disconnect") >= 0) sReason = "Отключился";
	else if(StrContains(sReason, "Забанен админом:", false) >= 0 
		|| StrContains(sReason, "Banned by administrator", false) >= 0 
		|| StrContains(sReason, "You was banned by admin", false) >= 0
		) sReason = "Забанен администратором";
	else if(StrContains(sReason, "Вы были кикнуты за AFK", false) >= 0) sReason = "AFK";
	else if(StrContains(sReason, "timed out", false) >= 0) sReason = "Разорвалось соединение";
	else if(StrContains(sReason, "No user logon", false) >= 0) sReason = "Пользователь не авторизован";
	else if(StrContains(sReason, "Kicked by GameVoting", false) >= 0) sReason = "Кикнут голосованием";
	else if(StrContains(sReason, "Kicked by Console", false) >= 0) sReason = "Кикнут консолью";
	else if(StrContains(sReason, "You was banned by admin: |乡|", false) >= 0) sReason = "Забанен голосованием";
	else if(StrContains(sReason, "VAC banned from secure server", false) >= 0) sReason = "Заблокирован VAC'ом";
	else if(StrContains(sReason, "VAC authentication error", false) >= 0) sReason = "Ошибка VAC";
	else if(StrContains(sReason, "Kicked by administrator", false) >= 0) sReason = "Кикнут администратором";
	else if(StrContains(sReason, "Сервер перезапускается. Попробуйте", false) >= 0) sReason = "Сервер перезапускается";
	else sReason = "Причина неизвестна";
	
	if((GetClientTeam(iClient) >= 0) && IsValidClient(iClient)) {
		CGOPrintToChatAll("%t", "player_disconnect", iClient, sReason);
	}
}

stock bool IsValidClient(int client)
{
  return (client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client) && !IsFakeClient(client));
}