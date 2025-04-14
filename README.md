# Wireshark-Data-to-CSV-Lua-Plugin
Converts data gathered from Wireshark packets into a table that is converted to a csv to the user's documents folder.
To use it, place it in your local Lua plugins folder for Wireshark (can be found by going to Help > About Wireshark, click on the "Folders" tab, and under "Personal Lua Plugins" you can find the path. Make sure that Lua is enabled in Wireshark (it is by default, but you can edit the init.lua file (to find the path, do the same to find the local lua plugins folder but instead look for "Global configuration") and set enable_lua to true.
