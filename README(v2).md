v2 handles:

Loading player data
Saving data
Updating values
Caching system
Autosave loop
Retry system for DataStore errors

Uses pcall with retry system
Automatically saves all players every 60 seconds


--locate this and change your data here
{
	coins = 0,
	level = 1,
	xp = 0,
}
