function MenuCallbackHandler:_increase_infamous_custom(yes_clbk)
	managers.menu_scene:destroy_infamy_card()
	if managers.experience:current_level() < 100 or managers.experience:current_rank() >= #tweak_data.infamy.ranks then
		return
	end
	local rank = managers.experience:current_rank() + 1
	
	managers.experience:set_current_rank(rank)
	managers.experience:_set_current_level(100)--(managers.experience:current_level() - 30)
	
	local offshore_cost = Application:digest_value(tweak_data.infamy.ranks[rank], false)
	if offshore_cost > 0 then
		managers.money:deduct_from_total(managers.money:total())
		managers.money:deduct_from_offshore(offshore_cost)
	end
	
	if managers.menu_component then
		managers.menu_component:refresh_player_profile_gui()
	end
	local logic = managers.menu:active_menu().logic
	if logic then
		logic:refresh_node()
		logic:select_item("crimenet")
	end
	managers.savefile:save_progress()
	managers.savefile:save_setting(true)
	managers.menu:post_event("infamous_player_join_stinger")
	if yes_clbk then
		yes_clbk()
	end
	if SystemInfo:distribution() == Idstring("STEAM") then
		managers.statistics:publish_level_to_steam()
	end
end

function custominfamy()
	if not (managers.experience:current_level() >= 130 and managers.experience:current_rank() < #tweak_data.infamy.ranks) then
		local _menu = QuickMenu:new("Custom Infamy", " You need at least level 130 and be below max infamy rank.", {{text = "[  :(  ]", is_cancel_button = true}})
		_menu:Show()
		return
	end
	local infamous_cost = Application:digest_value(tweak_data.infamy.ranks[managers.experience:current_rank() + 1], false)
	local yes_clbk = params and params.yes_clbk or false
	local no_clbk = params and params.no_clbk
	local params = {}
	params.cost = managers.experience:cash_string(infamous_cost)
	params.free = infamous_cost == 0
	if infamous_cost <= managers.money:offshore() and managers.experience:current_level() >= 100 then
		function params.yes_func()
			local rank = managers.experience:current_rank() + 1
			managers.menu:open_node("blackmarket_preview_node", {
				{
					back_callback = callback(MenuCallbackHandler, MenuCallbackHandler, "_increase_infamous_custom", yes_clbk)
				}
			})
			managers.menu:post_event("infamous_stinger_level_" .. (rank < 10 and "0" or "") .. tostring(rank))
			managers.menu_scene:spawn_infamy_card(rank)
		end
	end
	function params.no_func()
		if no_clbk then
			no_clbk()
		end
	end
	managers.menu:show_confirm_become_infamous(params)
end


_toggleCustominfamy = not _toggleCustominfamy
if _toggleCustominfamy then
	local _menu = QuickMenu:new("Custom Infamy", "If you are at least level 130 and bellow maximum infamy you'll gain one infamy level and your level will be set to 100.\n PS: If you fulfilled above you'll get warning message, you are free to ignore it (I didn't manage to remove it yet).", {{text = "[ I understand. ]", is_cancel_button = true}})
	_menu:Show()
	custominfamy()
end