/*  CS:GO Gloves SourceMod Plugin
 *
 *  Copyright (C) 2017 Kağan 'kgns' Üstüngel
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see http://www.gnu.org/licenses/.
 */

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
  int clientIndex = GetClientOfUserId(event.GetInt("userid"));
  if (IsValidClient(clientIndex)) {
    GivePlayerGloves(clientIndex);
  }
}

public Action ChatListener(int client, const char[] command, int args) {
  int playerTeam = GetClientTeam(client);
  char msg[128];
  GetCmdArgString(msg, sizeof(msg));
  StripQuotes(msg);
  if (g_bWaitingForSeed[client] && IsValidClient(client) && g_iGloves[client][playerTeam] != 0 && !IsChatTrigger()) {
    g_bWaitingForSeed[client] = false;

    int seedInt;
    if (StrEqual(msg, "!cancel") || StrEqual(msg, "!iptal") || StrEqual(msg, "")) {
      PrintToChat(client, " %s \x02%t", g_ChatPrefix, "SeedCancelled");
      return Plugin_Handled;
    } else if ((seedInt = StringToInt(msg)) < 0 || seedInt > 8192) {
      PrintToChat(client, " %s \x02%t", g_ChatPrefix, "SeedFailed");
      return Plugin_Handled;
    }

    g_iSeed[client][playerTeam] = seedInt;
    g_iSeedRandom[client][playerTeam] = -1;

    if (playerTeam == GetClientTeam(client)) {
      int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
      if (activeWeapon != -1) {
        SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
      }
      GivePlayerGloves(client);
      if (activeWeapon != -1) {
        DataPack dpack;
        CreateDataTimer(0.1, ResetGlovesTimer, dpack);
        dpack.WriteCell(client);
        dpack.WriteCell(activeWeapon);
      }
    }

    CreateTimer(0.5, SeedMenuTimer, GetClientUserId(client));

    PrintToChat(client, " %s \x04%t: \x01%i", g_ChatPrefix, "SeedSuccess", seedInt);

    return Plugin_Handled;
  } else if (g_bWaitingForWear[client] && IsValidClient(client) && g_iGloves[client][playerTeam] != 0 &&
             !IsChatTrigger()) {
    g_bWaitingForWear[client] = false;

    float floatVal;
    if (StrEqual(msg, "!cancel") || StrEqual(msg, "!iptal") || StrEqual(msg, "")) {
      PrintToChat(client, " %s \x02%t", g_ChatPrefix, "SeedCancelled");
      return Plugin_Handled;
    } else if ((floatVal = StringToFloat(msg)) <= 0 || floatVal >= 1) {
      PrintToChat(client, " %s \x02%t", g_ChatPrefix, "SeedFailed");
      return Plugin_Handled;
    }

    g_fFloatValue[client][playerTeam] = floatVal;

    if (playerTeam == GetClientTeam(client)) {
      int activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
      if (activeWeapon != -1) {
        SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
      }
      GivePlayerGloves(client);
      if (activeWeapon != -1) {
        DataPack dpack;
        CreateDataTimer(0.1, ResetGlovesTimer, dpack);
        dpack.WriteCell(client);
        dpack.WriteCell(activeWeapon);
      }
    }

    CreateFloatMenu(client).Display(client, MENU_TIME_FOREVER);

    PrintToChat(client, " %s \x04%t: \x01%f", g_ChatPrefix, "FloatSetSuccess", floatVal);

    return Plugin_Handled;
  }

  return Plugin_Continue;
}