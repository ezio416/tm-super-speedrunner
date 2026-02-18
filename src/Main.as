const string  pluginColor = "\\$FF0";
const string  pluginIcon  = Icons::ClockO;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

uint curMap = 0;
Map@[] maps;
bool running = false;
bool stop = false;
uint64 timerStart = 0;

void Main() {
    auto App = cast<CTrackMania>(GetApp());

    while (App.ChallengeInfos.Length < 200)
        yield();

    for (uint i = 0; i < App.ChallengeInfos.Length; i++) {
        CGameCtnChallengeInfo@ map = App.ChallengeInfos[i];
        if (map !is null && map.MapUid != "" && !map.Name.Contains("VR"))
            maps.InsertLast(Map(map));
    }

    if (maps.Length < 200)
        throw("too few maps: " + maps.Length);
}

void Render() {
    if (false
        or !S_Window
        or (true
            and S_HideWithGame
            and !UI::IsGameUIVisible()
        )
        or (true
            and S_HideWithOP
            and !UI::IsOverlayShown()
        )
    ) {
        return;
    }

    const int flags = UI::GetDefaultWindowFlags()
        | UI::WindowFlags::AlwaysAutoResize
        | UI::WindowFlags::NoFocusOnAppearing
    ;

    if (UI::Begin(pluginTitle, S_Window, flags)) {
        RenderWindow();
    }

    UI::End();
}

void RenderMenu() {
    if (UI::MenuItem(pluginTitle, "", S_Window)) {
        S_Window = !S_Window;
    }
}

void RenderWindow() {
    UI::Text("Current Map: #" + maps[curMap].name + " / 200");
    UI::Text("Time (RTA): " + (timerStart > 0 ? Time::Format(Time::Now - timerStart) : "-:--:--.---"));

    UI::BeginDisabled(running);
    if (UI::Button("start")) {
        timerStart = Time::Now;
        startnew(SpeedrunAsync);
    }
    UI::EndDisabled();

    UI::SameLine();
    UI::BeginDisabled(false
        or !running
        or stop
    );
    if (UI::Button("stop")) {
        timerStart = 0;
        stop = true;
    }
    UI::EndDisabled();
}

void SpeedrunAsync() {
    running = true;

    auto App = cast<CTrackMania>(GetApp());

    bool next = true;

    while (!stop) {
        yield();

        if (next) {
            Map@ nextMap = maps[curMap];
            print("PLAYING NEXT MAP (index " + curMap + "): " + nextMap.name + " | " + nextMap.path);
            nextMap.Play();
            next = false;
            sleep(10000);
        }

        auto Playground = cast<CTrackManiaRaceNew>(App.CurrentPlayground);
        next = true
            and Playground !is null
            and Playground.UIConfigs.Length > 0
            and Playground.UIConfigs[0] !is null
            and Playground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::EndRound
        ;

        if (next) {
            curMap++;
            if (curMap == 200) {
                curMap = 0;
                break;
            }
        }
    }

    curMap = 0;
    running = false;
    stop = false;
}

class Map {
    string name;
    string path;

    Map(CGameCtnChallengeInfo@ map) {
        name = map.Name;
        path = map.FileName;
    }

    void Play() {
        startnew(CoroutineFunc(PlayAsync));
    }

    void PlayAsync() {
        print("loading map " + name + " from path " + path);

        auto App = cast<CTrackMania>(GetApp());
        App.BackToMainMenu();
        while (!App.ManiaTitleFlowScriptAPI.IsReady)
            yield();
        App.ManiaTitleFlowScriptAPI.PlayMap(path, "TMC_CampaignSolo", "");
        while (!App.ManiaTitleFlowScriptAPI.IsReady)
            yield();
    }
}
