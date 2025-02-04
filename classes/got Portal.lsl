#ifndef _Portal
#define _Portal

// Fixed table rows
#define portalRow$players db4$0		// JSON array of players
#define portalRow$huds db4$1		// JSON array of HUDs
#define portalRow$desc db4$2		// Custom description passed on spawn
#define portalRow$pos db4$3			// (vector)spawn pos
#define portalRow$live db4$4		// (bool)is_live
#define portalRow$group db4$5		// (str)spawngroup
#define portalRow$spawner db4$6		// (key)object that requested the spawn



#define Portal$getPlayers() llJson2List(db4$fget(gotTable$portal, portalRow$players))
#define Portal$getHuds() llJson2List(db4$fget(gotTable$portal, portalRow$huds))
#define Portal$getDesc() db4$fget(gotTable$portal, portalRow$desc)
#define Portal$getPos() ((vector)db4$fget(gotTable$portal, portalRow$pos))
#define Portal$getLive() ((int)db4$fget(gotTable$portal, portalRow$live))
#define Portal$getGroup() db4$fget(gotTable$portal, portalRow$group)
#define Portal$getSpawner() db4$fget(gotTable$portal, portalRow$spawner)



// Events sent as llRegionSay on a custom channel to save script time. Lets you affect NPCs from non-level scripts on the fly.
// Channel for sending and receiving portal events
#define Portal$evtChan(player) playerChan(player)+696969
#define Portal$gEvt$ini "INI"			// Sent when rezzed.
#define Portal$gEvt$inject "INJ"		// An integer pin is appended. You can now inject your requested scripts.

#define Portal$gTask$inject "INJ"		// Appended with (int)nr_scripts. Asks to inject one or more scripts. 
										// Portal replies with Portal$gEvt$inject when ready.
										// You have 3 sec per script to complete the injection, plus 2 seconds.
										// After that, the pin is reset.
#define Portal$gTask$injectDone "IJD"	// Immediately closes the transfer window, and has the target forget the pin.
#define Portal$gTask$get "GET"		// Callbacks an ini call to the script sending the GET command.

#define Portal$requestScriptInject(targ, evtChan, numScripts) llRegionSayTo(targ, evtChan, Portal$gTask$inject+(str)(numScripts))
#define Portal$scriptInjectDone(targ, evtChan) llRegionSayTo(targ, evtChan, Portal$gTask$injectDone)

// Helpful macros to automate
#define Portal$playerLists \
	list PLAYERS; \
	list PLAYER_HUDS;

#define Portal$isPlayerListIfStatement script == "got Portal" && (evt == evt$SCRIPT_INIT || evt == PortalEvt$players)
#define Portal$plif Portal$isPlayerListIfStatement
#define Portal$hif script == "got Portal" && evt == PortalEvt$playerHUDs
#define Portal$isScriptInit script == "got Portal" && evt == evt$SCRIPT_INIT

// Handles players and HUDs inside onEvt
#define Portal$handlePlayers() \
	if( Portal$plif ) \
		PLAYERS = data; \
	if( Portal$hif ) \
		PLAYER_HUDS = data;
	
	
#define Portal$handlePlayerLists() Portal$handlePlayers()

// Portal sends an evt$SCRIPT_INIT after all dependencies have been loaded with data being a json array of players

#define PortalMethod$resetAll 0				// void - Resets everything
#define PortalMethod$reinit 1				// NULL - refetches all scripts
#define PortalMethod$remove 2				// (bool)force - Deletes object. got LevelLite in a non live prim and persistent objects will ignore this unless force is TRUE
#define PortalMethod$save 3					// NULL - Auto callbacks
#define PortalMethod$iniData 4				// (str)data, (str)spawnround, (key)requester, (vec)pos - Sets config data. Legacy method. Data is passed on rez now.
#define PortalMethod$debugPlayers 5			// void - Says the loaded PLAYERS to the owner
#define PortalMethod$removeBySpawnround 6	// spawnround - Removes any item with a specific spawnround
#define PortalMethod$removeBySpawner 7		// (key)spawner - Removes any portal object spawned by spawner
#define PortalMethod$forceLiveInitiate 8	// Forces the portal to reinitialize as if it was live
#define PortalMethod$persistence 9			// (bool)persistant - Ignores remove calls unless override is true
#define PortalMethod$sendPlayers 10			// void - Forces a portal player and HUD event
#define PortalMethod$remoteLoad 11			// (key)targ, (str)script, (int)pin, (int)startParam

#define BIT_DEBUG 536870912			// This is the binary bit (30) that determines if it runs in debug mode or not
#define BIT_GET_DESC 1073741824		// This is the binary bit (31) that determines if it needs to get custom data from the spawner or not. If BIT_GET_DESC is set. The first 29 bits become an ID instead of a position, passed back to the spawner.
#define BIT_TEMP 2147483648			// Sets if it should be temp on rez. Needed because some legacy items may incorrectly be temp. LSL works in mysterious ways

// got LevelData should NOT be in this. It's auto fetched along with got LevelLite
#define PORTAL_SEARCH_SCRIPTS (list)"ton MeshAnim"+"got Follower"+"jas MaskAnim"+"got AniAnim"+"got Projectile"+"got Status"+"got Monster"+"got FXCompiler"+"got FX"+"got NPCSpells"+"jas Attached"+"got Trap"+"got LevelLite"+"got LevelAux"+"got LevelLoader"+"got Spawner"+"got BuffSpawn"+"got ClassAtt"+"got PlayerPoser"+"got AnimeshScene"+"got MonsterGrapple"
#define PORTAL_SEARCH_OBJECTS ["Trigger"]

#define Portal$save() runOmniMethod("got Portal", PortalMethod$save, [], "SV")
#define Portal$killAll() runOmniMethod("got Portal", PortalMethod$remove, [], TNN)
// overrides all persistence
#define Portal$nukeAll() runOmniMethod("got Portal", PortalMethod$remove, [TRUE], TNN)
#define Portal$iniData(targ, data, spawnround, requester, pos) runMethod(targ, "got Portal", PortalMethod$iniData, [data, spawnround, requester, pos], TNN)
#define Portal$removeBySpawnround(spawnround) runOmniMethod("got Portal", PortalMethod$removeBySpawnround, [spawnround], TNN)
#define Portal$removeSpawnedByThis() runOmniMethod("got Portal", PortalMethod$removeBySpawner, [llGetKey()], TNN)
#define Portal$kill(targ) runMethod((str)targ, "got Portal", PortalMethod$remove, [], TNN)
#define Portal$persistence(on) runMethod((str)LINK_THIS, "got Portal", PortalMethod$persistence, [on], TNN)
#define Portal$sendPlayers() runMethod((str)LINK_THIS, "got Portal", PortalMethod$sendPlayers, [], TNN)
#define Portal$remoteLoad( portalPrim, targ, script, pin, startParam ) runMethod((str)portalPrim, "got Portal", PortalMethod$remoteLoad, (list)(targ) + (script) + (pin) + (startParam), TNN)

// Get spawn desc config
#define portalConf() #error "Use Portal$get instead of portalConf"
/*
This data is still generated, but you should use LSD instead in new scripts
llList2String(llGetLinkPrimitiveParams(LINK_THIS, [PRIM_TEXT]),0)
// Config is an array:
/*
	00	(vec)pos
	01	(int)live
	02	(var)customDesc
	03	(str)spawnround

#define portalConf$pos (vector)j(portalConf(), 0)
#define portalConf$live (int)j(portalConf(), 1)
#define portalConf$desc j(portalConf(), 2)
#define portalConf$spawnround j(portalConf(), 3)
*/



#define PortalEvt$desc_updated 1		// (var)desc_from_spawner - Portal has received a custom desc from the level
#define PortalEvt$spawner 2				// (key)spawner - Spawner is the key of the object that requested the spawn
#define PortalEvt$playerHUDs 3			// (arr)huds - Player HUDs have changed
#define PortalEvt$players 4				// (arr)players - Player UUIDs have been updated


/*
	name : name of prim to rez
	pos : absolute position in sim
	rot : absolute rotation
	spawnOffset : where to spawn initially before calling llSetRegionPos() to pos
	flags : (previously debug) 1 = spawn as a dummy
	desc : custom object desc
	spawnGroup : spawn group the object belongs to (if any)
	sender : UUID of prim that requested the spawn originally (if any)
	rezParams : custom rez params passed to llRezObjectWithParams
*/
#define PortalRezFlag$dummy 0x1		// 
#define PortalRezFlag$ack 0x2		// Handles by got Spawner. Tells the portal that we expect an ack message on successful start.
key _portal_spawn_v3( 
	string name, 
	vector pos, 
	rotation rot, 
	vector spawnOffset, 
	integer flags, 
	string spawnGroup,
	key sender,
	string desc, 
	list rezParams
){
	
	rezParams = (list)
		REZ_PARAM + 1 + // Start param should be 1 to make it update the code
		REZ_POS + (llGetPos()+spawnOffset) + FALSE + TRUE +
		REZ_ROT + rot + FALSE + 
		REZ_PARAM_STRING + mkarr((list)pos + flags + spawnGroup + sender + desc) +
		rezParams
	;
	return llRezObjectWithParams(name, rezParams);

}
// Maps to REZ_PARAM_STRING
#define PORTALDESC_POS 0
#define PORTALDESC_DEBUG 1
#define PORTALDESC_SPAWNGRUOP 2
#define PORTALDESC_SPAWNER 3
#define PORTALDESC_DESC 4


// THESE 3 ARE LEGACY. USE _portal_spawn_v3
// Legacy: Spawns with reqDesc FALSE. If you need reqdesc you have to use the new function which gets pos from the spawner instead.
// Temp is also removed.
/*
_portal_spawn_std(string name, vector pos, rotation rot, vector spawnOffset, integer debug){
	vector mpos = llGetRootPosition();
	vector local = vecFloor(mpos)+(pos-vecFloor(pos));
	integer in = vec2int(pos);
	if( debug )
		in = in|BIT_DEBUG;
	llRezAtRoot(name, local+spawnOffset, ZERO_VECTOR, rot, in);
}
_portal_spawn_absolute(string name, vector pos, rotation rot, integer debug){
	integer in;
	if( debug )
		in = in|BIT_DEBUG;
	llRezAtRoot(name, pos, ZERO_VECTOR, rot, in);
}
_portal_spawn_new( int id, string name, rotation rot, vector spawnOffset, integer debug ){
	
	id = id | BIT_GET_DESC | (BIT_DEBUG*(!!debug));
	llRezAtRoot(name, llGetRootPosition()+spawnOffset, ZERO_VECTOR, rot, id);

}
*/
#define _portal_spawn_std(a,b,c,d,e) #error "Use _portal_spawn_v3 instead"
#define _portal_spawn_absolute(a,b,c,d) #error "Use _portal_spawn_v3 instead"
#define _portal_spawn_new(a,b,c,d,e) #error "Use _portal_spawn_v3 instead"




#endif

