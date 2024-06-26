#pragma semicolon               1
#pragma newdecls                required

#include <sourcemod>
#include <colors>


public Plugin myinfo = {
	name = "AdminKickImmunity",
	author = "TouchMe",
	description = "Adds admin immunity from kicks",
	version = "build0001",
	url = "https://github.com/TouchMe-Inc/l4d2_admin_kick_immunity"
}


#define TRANSLATIONS            "admin_kick_immunity.phrases"


/**
 * Called before OnPluginStart.
 *
 * @param myself      Handle to the plugin
 * @param bLate       Whether or not the plugin was loaded "late" (after map load)
 * @param sErr        Error message buffer in case load failed
 * @param iErrLen     Maximum number of characters for error message buffer
 * @return            APLRes_Success | APLRes_SilentFailure
 */
public APLRes AskPluginLoad2(Handle myself, bool bLate, char[] sErr, int iErrLen)
{
	if (GetEngineVersion() != Engine_Left4Dead2)
	{
		strcopy(sErr, iErrLen, "Plugin only supports Left 4 Dead 2");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations(TRANSLATIONS);

	AddCommandListener(Cmd_CallVote, "callvote");
}

Action Cmd_CallVote(int iClient, const char[] sCmd, int iArgs)
{
	if (iArgs < 2) {
		return Plugin_Continue;
	}

	char sVoteType[16]; GetCmdArg(1, sVoteType, sizeof(sVoteType)); 

	if (!StrEqual(sVoteType, "kick", false)) {
		return Plugin_Continue;
	}

	char sOption[64]; GetCmdArg(2, sOption, sizeof(sOption));

	int iTarget = GetClientOfUserId(StringToInt(sOption));

	if (iTarget < 1) {
		return Plugin_Continue;
	}

	AdminId ClientId = GetUserAdmin(iClient);
	AdminId TargetId = GetUserAdmin(iTarget);

	if (TargetId == INVALID_ADMIN_ID && ClientId == INVALID_ADMIN_ID) {
		return Plugin_Continue;
	}

	if (CanAdminTarget(ClientId, TargetId)) {
		return Plugin_Continue;
	}

	CPrintToChat(iTarget, "%T%T", "TAG", iTarget, "TRY_KICK", iTarget, iClient);

	return Plugin_Handled;
}
