-- AWARDS
--
-- Copyright (C) 2013-2015 rubenwardy
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
-- You should have received a copy of the GNU Lesser General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
--


local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function ( s ) return s end
end

dofile(minetest.get_modpath("awards").."/api.lua")
dofile(minetest.get_modpath("awards").."/chat_commands.lua")
dofile(minetest.get_modpath("awards").."/sfinv.lua")
dofile(minetest.get_modpath("awards").."/unified_inventory.lua")
dofile(minetest.get_modpath("awards").."/triggers.lua")
awards.set_intllib(S)

