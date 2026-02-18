const string  pluginColor = "\\$FF0";
const string  pluginIcon  = Icons::ClockO;
Meta::Plugin@ pluginMeta  = Meta::ExecutingPlugin();
const string  pluginTitle = pluginColor + pluginIcon + "\\$G " + pluginMeta.Name;

uint                  curMap     = 0;
bool                  loaded     = false;
PlayChallenge::Map@[] maps;
bool                  running    = false;
bool                  stop       = false;
uint64                timerTotal = 0;
uint64                timerStart = 0;

void Main() {
    OnEnabled();
}

void OnDestroyed() {
    Reset();
}

void OnDisabled() {
    OnDestroyed();
}

void OnEnabled() {
    if (PlayChallenge::Demo()) {
        NotifyError("this plugin requires the full game!");
        return;
    }

    LoadMapsAsync();
}

void Render() {
    if (false
        or !S_Window
        or !loaded
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
    if (true
        and !PlayChallenge::Demo()
        and UI::MenuItem(pluginTitle, "", S_Window)
    ) {
        S_Window = !S_Window;
    }
}

void RenderWindow() {
    UI::Text("Current Map: #" + maps[curMap].name + " / 200");
    const uint64 timer = timerStart > 0 ? Time::Now - timerStart : timerTotal;
    UI::Text("Time (RTA): " + (timer > 0 ? Time::Format(timer) : "-:--:--.---"));

    UI::BeginDisabled(false
        or running
        or !loaded
    );
    if (UI::Button("start")) {
        timerTotal = 0;
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
        timerTotal = Time::Now - timerStart;
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
            PlayChallenge::Map@ nextMap = maps[curMap];
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
                timerTotal = Time::Now - timerStart;
                break;
            }
        }
    }

    curMap = 0;
    running = false;
    stop = false;
}
