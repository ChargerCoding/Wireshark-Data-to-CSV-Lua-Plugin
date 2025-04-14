# Wireshark-Data-to-CSV-Lua-Plugin
Converts data gathered from Wireshark packets into a table that is converted to a csv to the user's documents folder.
To use it, place it in your local Lua plugins folder for Wireshark (can be found by going to Help > About Wireshark, 
click on the "Folders" tab, and under "Personal Lua Plugins" you can find the path. Make sure that Lua is enabled in 
Wireshark. It is by default, but you can edit the init.lua file (to find the path, do the same to find the local lua plugins 
folder but instead look for "Global configuration") and set enable_lua to true. In Wireshark, begin a capture or load a capture
file and allow the data to be gathered. If it is a premade file, the exported data can be found in your documents folder as 
"packets.csv". If it is a live capture, you csn check the Lua console to see the packets being processed. Once you end the
capture, the data is exported.
