void ClearMaps() {
    maps = {};

    loaded = false;
}

void LoadMapsAsync() {
    const uint64 start = Time::Now;
    trace("loading maps");

    auto App = cast<CTrackMania>(GetApp());

    while (App.ChallengeInfos.Length < 240) {
        yield();
    }

    ClearMaps();

    uint num;

    for (uint i = 0; i < App.ChallengeInfos.Length; i++) {
        CGameCtnChallengeInfo@ map = App.ChallengeInfos[i];

        if (true
            and map !is null
            and map.MapUid.Length > 0
            and map.AuthorNickName == "Nadeo"
        ) {
            if (Text::TryParseUInt(map.NameForUi, num)) {
                maps.InsertLast(PlayChallenge::Map(map));
            }
        }
    }

    if (maps.Length != 200) {
        NotifyError("failed to load all maps after " + (Time::Now - start) + "ms");
        ClearMaps();

    } else {
        loaded = true;
        trace("loaded maps after " + (Time::Now - start) + "ms");
    }
}

void Notify(const string&in msg, const vec4&in color) {
    if (S_Notify) {
        UI::ShowNotification(pluginTitle, msg, color);
    }
}

void NotifyError(const string&in msg) {
    error(msg);
    Notify(msg, vec4(1.0f, 0.2f, 0.0f, 1.0f));
}

void NotifyWarn(const string&in msg) {
    warn(msg);
    Notify(msg, vec4(1.0f, 0.5f, 0.0f, 1.0f));
}
