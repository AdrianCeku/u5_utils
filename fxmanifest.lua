fx_version 'cerulean'

game 'gta5'

author 'github.com/AdrianCeku'

description 'ultimate5-utils'

version '1.0'

lua54 'yes'

shared_scripts{

}

client_scripts{
	"client/functions.lua",
	"client/distanceChecker.lua",
	"client/callbacks.lua",
	"client/main.lua",
}

server_scripts{
	"server/functions.lua",
	"server/callbacks.lua",
	"server/main.lua",
}
