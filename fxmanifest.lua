fx_version "cerulean"

game "gta5"

author "github.com/AdrianCeku"

description "ultimate5-utils"

version "0.1b"

lua54 "yes"

shared_scripts{

}

client_scripts{
	"client/main.lua",
	"client/functions.lua",
	"client/distanceChecker.lua",
	"client/callbacks.lua",
	"client/exports.lua",
}

server_scripts{
	"server/functions.lua",
	"server/callbacks.lua",
	"server/main.lua",
	"server/exports.lua",
}
