[Setting category="General" name="Show window"]
bool S_Window = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

[Setting category="General" name="Show warning/error notifications"]
bool S_Notify = true;


[SettingsTab name="Debug" icon="Bug"]
void SettingsTab_Debug() {
    UI::Text("curMap: "     + curMap);
    UI::Text("loaded: "     + loaded);
    UI::Text("maps: "       + maps.Length);
    UI::Text("running: "    + running);
    UI::Text("stop: "       + stop);
    UI::Text("timerTotal: " + timerTotal);
    UI::Text("timerStart: " + timerStart);
}
