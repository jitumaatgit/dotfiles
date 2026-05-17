# Tasker Automation Reference

This is the full reference document for generating Tasker XML. Copy of the Tasker AI system instructions with all 19 data definitions, catalogs, schemas, and examples.

---

## 1. Event Context Catalog Data

JSON defining available Tasker **Event** Contexts. Used for **Profiles**.

Each object represents one Event context and does NOT contain a `type` field.
For each parameter, `dialog_type_id` is OPTIONAL — if omitted, the AI infers the type.
Each Event Context may include `output_variable_list` with `{"name": "%varname", "description": "..."}` — the `name` must be the exact Tasker variable name.

**CRITICAL:** ALL Event Contexts generate built-in variables `%evtprm1`, `%evtprm2`, ... corresponding sequentially to their input parameters listed in `parameter_catalog` (`p.p` array), starting from the first parameter. The parameter with `u: 0` corresponds to `%evtprm1`, `u: 1` to `%evtprm2`, etc. These form a **Variable Array** named `%evtprm`.

**CRITICAL:** Generate XML arguments (`<Int>`, `<Str>`, `<Bundle>`, etc.) ONLY if they are explicitly listed in the `parameter_catalog` for that specific event `code`. Do not assume a default set of arguments exists.

```json
{"c":[{"c":2080,"n":"BT Connection","p":{"p":[{"a":"Bundle","u":0,"s":"","m":"Output Variables"},{"a":"Str","u":1,"s":"btn:1:?","m":"Name"},{"a":"Str","u":2,"s":"bta:1:?","m":"Address"}]},"o":{"v":[{"n":"%bt_address","d":"Address"},{"n":"%bt_alias","d":"Alias"},{"n":"%bt_battery_level","d":"Battery Level"},{"n":"%bt_paired","d":"Paired"},{"n":"%bt_class","d":"Class"},{"n":"%bt_class_name","d":"Class Name"},{"n":"%bt_connected","d":"Connected"},{"n":"%bt_encrypted","d":"Encrypted"},{"n":"%bt_major_class","d":"Major Class"},{"n":"%bt_major_class_name","d":"Major Class Name"},{"n":"%bt_name","d":"Name"},{"n":"%bt_signal_strength","d":"Signal Strength"},{"n":"%bt_type","d":"Type"}]}},{"c":2081,"n":"Music Track Changed","p":{"p":[{"a":"Bundle","u":0,"s":"","m":"Output Variables"},{"a":"Str","u":1,"s":"t:1:?","m":"Track"},{"a":"Str","u":2,"s":"t:1:?","m":"Album"},{"a":"Str","u":3,"s":"t:1:?","m":"Artist"},{"a":"Str","u":4,"s":"apppakc","m":"Package"},{"a":"Int","u":5,"s":"","m":"Type"}]},"o":{"v":[{"n":"%mt_album","d":"Album"},{"n":"%mt_all_metadata","d":"All Metadata"},{"n":"%mt_all_metadata_keys()","d":"All Metadata"},{"n":"%mt_app","d":"App"},{"n":"%mt_art","d":"Art"},{"n":"%mt_artist","d":"Artist"},{"n":"%mt_duration","d":"Duration"},{"n":"%mt_duration_formatted","d":"Duration"},{"n":"%mt_genre","d":"Genre"},{"n":"%mt_number_tracks","d":"Number Of Tracks"},{"n":"%mt_queue_icons()","d":"Queue Icons"},{"n":"%mt_queue_titles()","d":"Queue Titles"},{"n":"%mt_rating","d":"Rating"},{"n":"%mt_state","d":"State"},{"n":"%mt_track","d":"Track Name"},{"n":"%mt_track_number","d":"Track Number"},{"n":"%mt_year","d":"Year"},{"n":"%mt_playing","d":"Playing"}]}},{"c":2083,"n":"Significant Motion","p":{"p":[]}},{"c":2084,"n":"Alarm Changed","p":{"p":[{"a":"Bundle","u":0,"s":"","m":"Output Variables"},{"a":"Str","u":1,"s":"apppakc","m":"Package"}]},"o":{"v":[{"n":"%na_day","d":"Day"},{"n":"%na_month","d":"Month"},{"n":"%na_package","d":"Package"},{"n":"%na_time","d":"Time"}]}}//... truncated for length — full catalog available in original file}}
```

**NOTE:** The full Event Catalog JSON is very large. Refer to the original file at `tasker_ai_system_instructions.md` for the complete list of all event codes, their parameters, and output variables.

---

## 2. State Context Catalog Data

JSON defining available Tasker **State** Contexts. Used for **Profiles**.

Each object represents one State context. For each parameter, `dialog_type_id` is OPTIONAL. State Contexts may include `output_variable_list`. State contexts do **not** implicitly generate `%evtprm` variables.

```json
{"c":[{"c":154,"n":"Active User","p":{"p":[{"a":"Int","u":0,"s":"0:999999:?","m":"User ID"}]}},{"c":100,"n":"Airplane Mode","p":{"p":[]}},{"c":135,"n":"Auto-Sync","p":{"p":[]}},{"c":140,"n":"Battery Level","p":{"p":[{"a":"Int","u":0,"s":"0:100","m":"From"},{"a":"Int","u":1,"s":"0:100","m":"To"}]}},{"c":141,"n":"Battery Temperature","p":{"p":[{"a":"Int","u":0,"s":"0:2000","m":"From"},{"a":"Int","u":1,"s":"0:2000","m":"To"}]}},{"c":3,"n":"BT Connected","p":{"p":[{"a":"Str","u":0,"s":"btn:1:?","m":"Name"},{"a":"Str","u":1,"s":"bta:1:?","m":"Address"}]}},{"c":2,"n":"BT Status","p":{"p":[{"a":"Int","u":0,"s":"","m":"Status"}]}},{"c":4,"n":"BT Near","p":{"p":[{"a":"Str","u":0,"s":"btn:1:?","m":"Name"},{"a":"Str","u":1,"s":"bta:1:?","m":"Address"},{"a":"Int","u":2,"s":"","m":"Major Device Class"},{"a":"Int","u":3,"s":"","m":"Standard Devices"},{"a":"Int","u":4,"s":"","m":"Low-Energy (LE) Devices"},{"a":"Int","u":5,"s":"","m":"Unpaired Devices"},{"a":"Int","u":6,"s":"","m":"Toggle BlueTooth"}]}},{"c":5,"n":"Calendar Entry","p":{"p":[{"a":"Str","u":0,"s":"ctit:1:?","m":"Title"},{"a":"Str","u":1,"s":"cloc:1:?","m":"Location"},{"a":"Str","u":2,"s":"t:1:?","m":"Description"},{"a":"Int","u":3,"s":"","m":"Available"},{"a":"Str","u":4,"s":"ccal:2:?","m":"Calendar"}]}},{"c":40,"n":"Call","p":{"p":[{"a":"Int","u":0,"s":"","m":"Type"},{"a":"Str","u":1,"s":"p:3:?","m":"Number"}]}},{"c":7,"n":"Cell Near","p":{"p":[{"a":"Str","u":0,"s":"t:8","m":"Cell Tower / Last Signal"},{"a":"Str","u":1,"s":"t:4:?","m":"Ignore Cells"}]}},{"c":16,"n":"Device Idle","p":{"p":[]}},{"c":122,"n":"Display Orientation","p":{"p":[{"a":"Int","u":0,"s":"","m":"Is"}]}},{"c":123,"n":"Display State","p":{"p":[{"a":"Int","u":0,"s":"","m":"Is"}]}},{"c":80,"n":"Docked","p":{"p":[{"a":"Int","u":0,"s":"","m":"Type"}]}},{"c":175,"n":"Dreaming","p":{"p":[]}},{"c":161,"n":"Ethernet Connect","p":{"p":[{"a":"Int","u":0,"s":"","m":"Active"}]}},{"c":30,"n":"Headset Plugged","p":{"p":[{"a":"Int","u":0,"s":"","m":"Type..."}]}}//... truncated for length}
```

**NOTE:** The full State Catalog JSON is large. Refer to the original file for the complete list of all state codes including: NFC Status, Notification, Power Source, Priority Notification, Profile Active, Proximity Sensor, Signal Strength, Slider/Action Key, Subscription, Text/MMS Received, Tethering, User Activity, Variable Value (code 165), Vibrate, Volume, Wifi Connected (code 160), Wifi Near, Wimax Connected, and more.

---

## 3. Action Catalog Data

JSON defining available Tasker Actions. Used for **Tasks**.

Each action parameter uses `dialog_type_id` — if omitted, the AI infers the type.

**Format Adherence:** For parameters with specific input formats (e.g., HTTP Request Query Parameters, date/time patterns), strictly adhere to the specified format.

Actions may include `output_variable_list` (New Style) listing explicitly named output variables. Some actions use "Old Style" where specific input parameters (e.g., "Store Result In", "To Var") define the output variable name.

**Common dialog output variables:**
- `List Dialog` (378): `%ld_selected`, `%ld_button`, `%ld_selected_indices`
- `Input Dialog` (360): Variable name in `arg8`, or `%input` if empty
- `Pick Input Dialog` (390): Always `%input`
- `Text/Image Dialog` (377): `%td_button`

**Parameter `s` field:** Provides constraints:
- `"t:LINES:?"` — text input, LINES lines, ? = optional
- `"MIN:MAX:DEFAULT"` — integer range limits
- `"f"` — file path, `"uvar"` — user variable name, `"var"` — variable name, `"col"` — color, `"m"` — Task name, `"prof"` — Profile name, `"locradi"` — location+radius, `"bosta"` — structured output toggle, `"inpval"` — value with variables

**Structured Output (`bosta`):** When enabled (set its XML argument value to `1`), if the variable contains valid JSON, HTML/XML, or CSV, Tasker allows Structured Variable access.

```json
{"a":[{"c":245,"n":"Back Button","p":{"p":[]}},{"c":246,"n":"Long Power Button","p":{"p":[]}},{"c":247,"n":"Show Recents","p":{"p":[]}},{"c":244,"n":"Toggle Split Screen","p":{"p":[]}},{"c":219,"n":"Quick Settings","p":{"p":[]}},{"c":249,"n":"System Screenshot","p":{"p":[]}},{"c":259,"n":"Notification Pulse","p":{"p":[{"a":"Int","u":0,"s":"","m":"Set"}]}},{"c":18,"n":"Kill App","p":{"p":[{"a":"App","u":0,"s":"","m":"App"},{"a":"Int","u":1,"s":"","m":"Use Root"}]}},{"c":22,"n":"Load Last App","p":{"p":[]}},{"c":804,"n":"Input Method Select","p":{"p":[]}},{"c":548,"n":"Flash","p":{"p":[{"a":"Str","u":0,"s":"s:4","m":"Text"},{"a":"Int","u":1,"s":"","m":"Long"},{"a":"Int","u":2,"s":"","m":"Tasker Layout"},{"a":"Str","u":3,"s":"t:1:?","m":"Title"},{"a":"Str","u":4,"s":"img:1:?","m":"Icon"},{"a":"Str","u":5,"s":"t:1:?","m":"Icon Size"},{"a":"Str","u":6,"s":"col:1:?","m":"Background Colour"},{"a":"Str","u":7,"s":"m:1:?","m":"Task"},{"a":"Str","u":8,"s":"t:1:?","m":"Timeout"},{"a":"Str","u":9,"s":":1:?","m":"Layout"}}]}//... truncated for length}
```

**NOTE:** The full Action Catalog contains hundreds of actions. Refer to the original file for the complete list including: Variable Set (547), Variable Split (548), Variable Join (549), Multiple Variables Set (389), Array Push (355), Array Set (354), Array Process, For (39), End For (40), If (37), Else (43), End If (38), Stop (137), Perform Task, Return, Wait (30), Notify (523), HTTP Request (339), Widget v2 (461), App Info, Bundle Process, and many more.

---

## 4. Tasker XML Schema Definition

Schema for the `TaskerData` root element, defining Projects, Profiles, and Tasks.

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Tasker Data XML Structure Schema",
  "type": "object",
  "properties": {
    "TaskerData": {
      "type": "object",
      "properties": {
        "_sr": {"type": "string", "const": "", "description": "Source reference, empty for root"},
        "_dvi": {"type": "integer", "description": "Data version (e.g., 1)"},
        "_tv": {"type": "string", "description": "Tasker version (e.g., 6.6.20)"},
        "Project": {"type": "array", "maxItems": 1, "items": {"$ref": "#/definitions/ProjectType"}},
        "Loc": {"type": "array", "maxItems": 1, "items": {"$ref": "#/definitions/LocType"}},
        "Time": {"type": "array", "maxItems": 1, "items": {"$ref": "#/definitions/TimeType"}},
        "Profile": {"type": "array", "items": {"$ref": "#/definitions/ProfileType"}},
        "Task": {"type": "array", "items": {"$ref": "#/definitions/TaskType"}}
      },
      "required": ["_dvi", "_tv", "_sr"]
    }
  },
  "required": ["TaskerData"],
  "definitions": {
    "ProfileType": {
      "properties": {
        "_sr": {"type": "string"}, "_ve": {"type": "integer"},
        "cdate": {"type": "integer"}, "edate": {"type": "integer"},
        "flags": {"type": "integer", "const": 40},
        "id": {"type": "integer"}, "mid0": {"type": "integer"},
        "mid1": {"type": "integer"}, "nme": {"type": "string"}
      },
      "required": ["_sr", "_ve", "flags", "id", "mid0", "nme"]
    },
    "TaskType": {
      "properties": {
        "_sr": {"type": "string"}, "cdate": {"type": "integer"},
        "edate": {"type": "integer"}, "id": {"type": "integer"},
        "nme": {"type": "string"}, "pri": {"type": "integer"}
      },
      "required": ["_sr", "id"]
    },
    "ProjectType": {
      "properties": {
        "_sr": {"const": "proj0"}, "_ve": {"type": "integer"},
        "cdate": {"type": "integer"}, "name": {"type": "string"},
        "pids": {"type": "string"}, "tids": {"type": "string"}
      },
      "required": ["_sr", "_ve", "name", "pids", "tids"]
    }
    // StateType, EventType, ActionType, argument types follow
  }
}
```

**Key structural rules:**
- `<Profile>` gets `<flags>40</flags>` (Ignore Settings + Ignore Task Order + Run Exit On Startup)
- `<Project sr="proj0">` — `sr` MUST be exactly `"proj0"`
- Profile tasks are anonymous (NO `<nme>`); named/reusable tasks MUST have `<nme>`
- Arguments (`<Int>`, `<Str>`, `<App>`, `<Img>`, `<Bundle>`) are direct children of `<Action>`, `<State>`, or `<Event>` — no `<Arguments>` wrapper
- Condition elements (`<State>`, `<Event>`, `<Time>`, `<App>`, `<Loc>`) are direct children of `<Profile>` — no `<ContextElements>` wrapper
- Profile can have max 3 `<State>`, max 1 `<Event>`, max 1 `<Time>`, max 1 `<App>` children
- `<Bundle>` arguments should be generated with empty `<Vals sr="val"/>` when no specific values are needed
- No `<pids>` tag in Project if there are no Profiles
- No empty `<pids></pids>` — omit the tag entirely

---

## 5. Profile XML Structure

Root: `<TaskerData sr="" dvi="1" tv="6.6.20">`.

Contains `<Profile>` and anonymous `<Task>` siblings.

**Profile element:**
- `<flags>40</flags>` — always
- Contexts as direct children: `<State>`, `<Event>`, `<Loc>`, `<Time>`, `<App>`
- No `<ContextElements>` wrapper

**State contexts:** `<State sr="con[Index]" ve="2">` → `<code>` → optionally `<pin>true</pin>` (for inversion) → arguments as direct children. `<pin>true</pin>` is how 'Not' conditions are represented (e.g., Wifi *Not* Connected). `<code>` from State Catalog only.

**Event contexts:** `<Event sr="con[Index]" ve="2">` → `<code>` → arguments as direct children. `<code>` from Event Catalog only.

**Time context:** `<Time sr="conX">` — no `<code>`. Children: `<fh>`, `<fm>`, `<th>`, `<tm>`, `<rep>`, `<repval>`, `<fromvar>`, `<tovar>`. Use `-1` for unused boundaries. `<fromvar>`/`<tovar>` must be **Global Variables**.

**App context:** `<App sr="conX" ve="2">` — no `<code>`. Children: `<flags>2</flags>`, `<labelN>`, `<pkgN>` pairs. Optionally `<pin>true</pin>` for inversion. Works like a State context.

**Loc context:** `<Loc sr="conX">` — no `<code>`, no `_ve`, no `<pin>`. Children: `<lat>`, `<long>`, `<rad>`, optionally `<cname>`.

**Multi-app App context:** First action in linked Task MUST be `App Info` (335) with empty input to get `%app_package`, then `If` conditions to check which app triggered.

**Tasks:** Profile-linked via `mid0`/`mid1` — **anonymous** (NO `<nme>`). Actions are direct children with `<code>`, then arguments.

**XML escaping:** `&` → `&amp;`, `<` → `&lt;`, `>` → `&gt;`, `"` → `&quot;`, `'` → `&apos;`

---

## 6. Standalone Task XML Structure

Root: `<TaskerData sr="" dvi="1" tv="6.6.20">`.

Contains exactly one `<Task>` with `<id>` and `<nme>` (required for standalone tasks). Actions are direct children.

---

## 7. Project XML Structure

Root: `<TaskerData>` with `<Profile>`(s), `<Task>`(s), and one `<Project>` tag.

**Project element:** `<Project sr="proj0" ve="2">` with `<cdate>`, `<name>` (lowercase), `<pids>` (comma-separated Profile IDs), `<tids>` (comma-separated Task IDs — both anonymous and named).

**Task naming within Project:**
- Profile-linked tasks (`mid0`/`mid1`): **anonymous** (NO `<nme>`)
- Tasks for reuse (`Perform Task`): **MUST have `<nme>`**
- Widget-called tasks: **MUST have `<nme>`**
- Standalone tasks in project: **MUST have `<nme>`**

**IMPORTANT:** Omit `<pids>` entirely if there are no Profiles.

---

## 8. XML Examples

### Example 1: Profile — At Home Turn Volume Down (Wifi Connected State)

When connected to home Wifi "Dias":

```xml
<TaskerData sr="" dvi="1" tv="6.5.3-beta">
    <Profile sr="prof83" ve="2">
        <cdate>1743500042895</cdate>
        <edate>1743500921178</edate>
        <flags>40</flags>
        <id>83</id>
        <mid0>81</mid0>
        <nme>At Home Turn Volume Down</nme>
        <State sr="con0" ve="2">
            <code>160</code>
            <Str sr="arg0" ve="3">Dias</Str>
            <Str sr="arg1" ve="3"/>
            <Str sr="arg2" ve="3"/>
            <Int sr="arg3" val="2"/>
        </State>
    </Profile>
    <Task sr="task81">
        <cdate>1743500042880</cdate>
        <edate>1743500921177</edate>
        <id>81</id>
        <Action sr="act0" ve="7">
            <code>307</code>
            <Int sr="arg0" val="1"/>
            <Int sr="arg1" val="0"/>
            <Int sr="arg2" val="0"/>
        </Action>
        <Action sr="act1" ve="7">
            <code>304</code>
            <Int sr="arg0" val="1"/>
            <Int sr="arg1" val="0"/>
            <Int sr="arg2" val="0"/>
        </Action>
        <Action sr="act2" ve="7">
            <code>305</code>
            <Int sr="arg0" val="1"/>
            <Int sr="arg1" val="0"/>
            <Int sr="arg2" val="0"/>
        </Action>
    </Task>
</TaskerData>
```

### Example 2: Event Profile — SMS Reply with Location

When receiving message containing "where are you":

```xml
<TaskerData sr="" dvi="1" tv="6.5.3-beta">
    <Profile sr="prof66" ve="2">
        <cdate>1743081269457</cdate>
        <edate>1743501061591</edate>
        <flags>40</flags>
        <id>66</id>
        <mid0>67</mid0>
        <nme>On Received Where Are You SMS Reply Location</nme>
        <Event sr="con0" ve="2">
            <code>7</code>
            <pri>0</pri>
            <Int sr="arg0" val="0"/>
            <Str sr="arg1" ve="3"/>
            <Str sr="arg2" ve="3">*where are you*</Str>
            <Str sr="arg3" ve="3"/>
            <Str sr="arg4" ve="3"/>
        </Event>
    </Profile>
    <Task sr="task67">
        <cdate>1743081273223</cdate>
        <edate>1743501061591</edate>
        <id>67</id>
        <!-- Get Location, Send SMS, Notify, Update Widget -->
    </Task>
</TaskerData>
```

### Example 3: Multi-Condition Profile — Display On + Unlocked + Variable Check

```xml
<TaskerData sr="" dvi="1" tv="6.5.3-beta">
    <Profile sr="prof82" ve="2">
        <cdate>1743500042895</cdate>
        <edate>1743501785843</edate>
        <flags>40</flags>
        <id>82</id>
        <mid0>81</mid0>
        <nme>At Home And Display On And Unlocked</nme>
        <Event sr="con0" ve="2"><code>1000</code></Event>
        <State sr="con1" ve="2">
            <code>123</code>
            <Int sr="arg0" val="1"/>
        </State>
        <State sr="con2" ve="2">
            <code>165</code>
            <ConditionList sr="if">
                <Condition sr="c0" ve="3">
                    <lhs>%SchoolTime</lhs>
                    <op>12</op>
                    <rhs></rhs>
                </Condition>
            </ConditionList>
        </State>
    </Profile>
</TaskerData>
```

### Example 4: Standalone Task — Count Out Loud (For Loop)

```xml
<TaskerData sr="" dvi="1" tv="6.5.3-beta">
    <Task sr="task79">
        <cdate>1743686130509</cdate>
        <edate>1743686165007</edate>
        <id>79</id>
        <nme>Count Out loud</nme>
        <pri>100</pri>
        <Action sr="act0" ve="7">
            <code>39</code>
            <Str sr="arg0" ve="3">%index</Str>
            <Str sr="arg1" ve="3">1:5</Str>
            <Int sr="arg2" val="0"/>
        </Action>
        <Action sr="act1" ve="7">
            <code>559</code>
            <Str sr="arg0" ve="3">%index</Str>
            <Str sr="arg1" ve="3">default:default</Str>
            <Int sr="arg2" val="3"/>
            <Int sr="arg3" val="5"/>
            <Int sr="arg4" val="5"/>
            <Int sr="arg5" val="1"/>
            <Int sr="arg6" val="0"/>
            <Int sr="arg7" val="0"/>
        </Action>
        <Action sr="act2" ve="7"><code>40</code></Action>
    </Task>
</TaskerData>
```

### Example 5: Project — Multiple Profiles + Named Tasks (Work/Home Volume)

```xml
<TaskerData sr="" dvi="1" tv="6.5.3-beta">
    <Profile sr="prof80" ve="2">
        <cdate>1743691112434</cdate>
        <edate>1743691139597</edate>
        <flags>40</flags>
        <id>80</id>
        <mid0>89</mid0>
        <nme>At Home Media Volume Low</nme>
        <State sr="con0" ve="2">
            <code>160</code>
            <Str sr="arg0" ve="3">Home Wifi</Str>
            <Str sr="arg1" ve="3"/>
            <Str sr="arg2" ve="3"/>
            <Int sr="arg3" val="2"/>
        </State>
    </Profile>
    <Profile sr="prof90" ve="2">
        <cdate>1743691112434</cdate>
        <edate>1743691164709</edate>
        <flags>40</flags>
        <id>90</id>
        <mid0>91</mid0>
        <nme>At Work Media Volume High</nme>
        <State sr="con0" ve="2">
            <code>160</code>
            <Str sr="arg0" ve="3">Work Wifi</Str>
            <Str sr="arg1" ve="3"/>
            <Str sr="arg2" ve="3"/>
            <Int sr="arg3" val="2"/>
        </State>
    </Profile>
    <Project sr="proj0" ve="2">
        <cdate>1743691098808</cdate>
        <name>Work And Home</name>
        <pids>90,80</pids>
        <tids>91,89</tids>
    </Project>
    <Task sr="task89"><!-- anonymous, linked by mid0 --></Task>
    <Task sr="task91"><!-- anonymous, linked by mid0 --></Task>
</TaskerData>
```

### Example 6: Project with Widget — Reddit Hot Posts

Creates widget showing top 5 r/tasker hot posts:

```xml
<TaskerData sr="" dvi="1" tv="6.5.4-beta">
    <Project sr="proj0" ve="2">
        <cdate>1743695000001</cdate>
        <name>Reddit Widget Project</name>
        <tids>102,100</tids>
    </Project>
    <Task sr="task100">
        <id>100</id>
        <nme>Update Reddit Widget</nme>
        <pri>100</pri>
        <!-- HTTP Request → Array Merge → Widget v2 -->
    </Task>
    <Task sr="task102">
        <id>102</id>
        <nme>Open URL</nme>
        <!-- Called by widget interaction -->
    </Task>
</TaskerData>
```

### Example 7: Time Context Profile (Repeating)

Every 5 minutes between 2-3 PM, flash "Hello":

```xml
<TaskerData sr="" dvi="1" tv="6.5.4-beta">
    <Profile sr="prof103" ve="2">
        <cdate>1744376939725</cdate>
        <edate>1744376975064</edate>
        <flags>8</flags>
        <id>103</id>
        <mid0>104</mid0>
        <nme>Flash Hello Every 5 Minutes From 2 To 3 PM</nme>
        <Time sr="con0">
            <fh>14</fh>
            <fm>0</fm>
            <rep>2</rep>
            <repval>5</repval>
            <th>15</th>
            <tm>0</tm>
        </Time>
    </Profile>
    <Task sr="task104"><!-- Flash Hello --></Task>
</TaskerData>
```

### Example 8: Project with State Tracking + Named Task (Home Status Announcer)

```xml
<TaskerData sr="" dvi="1" tv="6.5.4-beta">
    <Profile sr="prof2" ve="2">
        <cdate>1745394516520</cdate>
        <edate>1745394558962</edate>
        <flags>40</flags>
        <id>2</id>
        <mid0>3</mid0>
        <mid1>4</mid1>
        <nme>Detect Home Wifi</nme>
        <State sr="con0" ve="2">
            <code>160</code>
            <Str sr="arg0" ve="3">Dias Gwifi</Str>
            <Str sr="arg1" ve="3"/>
            <Str sr="arg2" ve="3"/>
            <Int sr="arg3" val="2"/>
        </State>
    </Profile>
    <Project sr="proj0" ve="2">
        <cdate>1745394508831</cdate>
        <name>Home Status Announcer</name>
        <pids>2</pids>
        <tids>5,3,4</tids>
    </Project>
    <Task sr="task3"><!-- Entry: Set %AtHome=1 --></Task>
    <Task sr="task4"><!-- Exit: Clear %AtHome --></Task>
    <Task sr="task5">
        <nme>Announce Home Status</nme>
        <!-- Named task called by widget -->
    </Task>
</TaskerData>
```

---

## 9. Clarification JSON Schema

Used when asking user for missing information instead of generating XML.

```json
{
  "type": "object",
  "properties": {
    "s": {"type": "string", "enum": ["clarification_needed"]},
    "m": {"type": "string", "description": "Message to user"},
    "i": {
      "type": "array", "minItems": 1,
      "items": {
        "type": "object",
        "properties": {
          "d": {"type": "string", "description": "Dialog type identifier from Input Dialog Types list"},
          "t": {"type": "string", "description": "Suggested title (optional)"},
          "x": {"type": "string", "description": "Suggested text/prompt (optional)"},
          "c": {
            "type": "object",
            "properties": {
              "c": {"type": "string"},
              "p": {"type": "string"}
            },
            "required": []
          },
          "o": {"type": "array", "items": {"type": "string"}}
        },
        "required": ["d"]
      }
    }
  },
  "required": ["s", "m", "i"]
}
```

---

## 10. Tasker Input Dialog Types Catalog

```json
{"d":[{"i":"t","n":"Text","nd":"Text"},{"i":"n","n":"Number","nd":"Number"},{"i":"b","n":"True or False","nd":"TrueOrFalse"},{"i":"yn","n":"Yes or No","nd":"YesOrNo"},{"i":"onoff","n":"On or Off","nd":"OnOrOff"},{"i":"f","n":"File","nd":"File"},{"i":"fs","n":"File (System)","nd":"FileSystemPicker"},{"i":"fss","n":"Files (System)","nd":"FilesSystemPicker"},{"i":"i","n":"Image","nd":"Image"},{"i":"is","n":"Images","nd":"Images"},{"i":"d","n":"Directory","nd":"Directory"},{"i":"ds","n":"Directory (System)","nd":"DirectorySystemPicker"},{"i":"ws","n":"Wifi SSID","nd":"WifiSSID"},{"i":"wm","n":"Wifi MAC","nd":"WifiMac"},{"i":"bn","n":"Bluetooth device's name","nd":"BluetoothName"},{"i":"bn","n":"Bluetooth device's MAC address","nd":"BluetoothMac"},{"i":"c","n":"Contact","nd":"Contact"},{"i":"cn","n":"Contact Number","nd":"ContactNumber"},{"i":"cg","n":"Contact or Contact Group","nd":"ContactGroup"},{"i":"ti","n":"Time","nd":"Time"},{"i":"da","n":"Date","nd":"Date","f":"Formatted as yyyy-MM-dd"},{"i":"a","n":"App","nd":"App"},{"i":"as","n":"Apps","nd":"Apps"},{"i":"la","n":"Launcher","nd":"AppLauncher"},{"i":"cl","n":"Colour","nd":"Color"},{"i":"ln","n":"Language","nd":"Language"},{"i":"ttsv","n":"Text To Speech voice","nd":"TTSVoice"},{"i":"can","n":"Calendar","nd":"CalendarName"},{"i":"cae","n":"Calendar Entry","nd":"CalendarEntry"},{"i":"tz","n":"Time Zone","nd":"TimeZone"},{"i":"ta","n":"Task","nd":"Task"},{"i":"prf","n":"Profile","nd":"Profile"},{"i":"prj","n":"Project","nd":"Project"},{"i":"scn","n":"Scene","nd":"Scene"},{"i":"cac","n":"User Certificate","nd":"UsertCertificate"},{"i":"wv2","n":"Widget v2","nd":"WidgetV2"},{"i":"kba","n":"Keyboard App","nd":"KeyboardApp"},{"i":"loc","n":"Location","nd":"Location"}]}
```

**NOTE:** The identifier `'t'` MUST exist and represents basic text input.

---

## 11. Built-in Variable Catalog

```json
{"b":[{"n":"%AIR","d":"Airplane Mode Status"},{"n":"%AIRR","d":"Airplane Radios"},{"n":"%BATT","d":"Battery Level"},{"n":"%BLUE","d":"Bluetooth Status"},{"n":"%CALS","d":"Calendar List"},{"n":"%CALTITLE","d":"Calendar Event Title"},{"n":"%CALDESCR","d":"Calendar Event Descr"},{"n":"%CALLOC","d":"Calendar Event Location"},{"n":"%CDATE","d":"Call Date (In)"},{"n":"%CNAME","d":"Caller Name (In)"},{"n":"%CNUM","d":"Caller Number (In)"},{"n":"%CTIME","d":"Call Time (In)"},{"n":"%CODATE","d":"Call Date (Out)"},{"n":"%CODUR","d":"Call Duration (Out)"},{"n":"%CONAME","d":"Called Name (Out)"},{"n":"%CONUM","d":"Called Number (Out)"},{"n":"%COTIME","d":"Call Time (Out)"},{"n":"%CELLID","d":"Cell ID"},{"n":"%CELLSIG","d":"Cell Signal Strength"},{"n":"%CELLSRV","d":"Cell Service State"},{"n":"%CLIP","d":"Clipboard Contents"},{"n":"%CPUFREQ","d":"CPU Frequency"},{"n":"%CPUGOV","d":"CPU Governor"},{"n":"%DATE","d":"Date"},{"n":"%DAYM","d":"Day Of Month"},{"n":"%DAYW","d":"Day Of Week"},{"n":"%DEVID","d":"Device ID"},{"n":"%DEVMAN","d":"Device Manufacturer"},{"n":"%DEVMOD","d":"Device Model"},{"n":"%DEVPROD","d":"Device Product"},{"n":"%DEVTID","d":"Device Telephony ID"},{"n":"%BRIGHT","d":"Display Brightness"},{"n":"%DTOUT","d":"Display Timeout"},{"n":"%EFROM","d":"Email From"},{"n":"%ECC","d":"Email Cc"},{"n":"%ESUBJ","d":"Email Subject"},{"n":"%EDATE","d":"Email Date"},{"n":"%ETIME","d":"Email Time"},{"n":"%MEMF","d":"Free Memory"},{"n":"%GPS","d":"GPS Status"},{"n":"%HEART","d":"Heart Rate"},{"n":"%HTTPR","d":"HTTP Response Code"},{"n":"%HTTPD","d":"HTTP Data"},{"n":"%HTTPL","d":"HTTP Content Length"},{"n":"%HUMIDITY","d":"Humidity"},{"n":"%IMETHOD","d":"Input Method"},{"n":"%INTERRUPT","d":"Interrupt Mode"},{"n":"%KEYG","d":"Keyguard Status"},{"n":"%LAPP","d":"Last Application"},{"n":"%FOTO","d":"Last Photo"},{"n":"%LIGHT","d":"Light Level"},{"n":"%LOC","d":"Location"},{"n":"%LOCACC","d":"Location Accuracy"},{"n":"%LOCALT","d":"Location Altitude"},{"n":"%LOCSPD","d":"Speed"},{"n":"%MCC","d":"Mobile Country Code"},{"n":"%MNC","d":"Mobile Network Code"},{"n":"%NET","d":"Network Type"},{"n":"%MUSIC","d":"Music Status"},{"n":"%NICK","d":"Nickname"},{"n":"%WIFII","d":"Wifi IP"},{"n":"%WIFIMAC","d":"Wifi MAC"},{"n":"%ROAM","d":"Roaming Status"},{"n":"%TIMEF","d":"Time Format"},{"n":"%TIME","d":"Time"},{"n":"%TIMES","d":"Seconds Since Epoch"},{"n":"%TETH","d":"Tethering Status"},{"n":"%TETHC","d":"Tethering Clients"},{"n":"%TETHN","d":"Tethering Network"},{"n":"%VOLA","d":"Alarm Volume"},{"n":"%VOLM","d":"Music/Media Volume"},{"n":"%VOLR","d":"Ringer Volume"},{"n":"%VOLC","d":"Call Volume"},{"n":"%VOLN","d":"Notification Volume"},{"n":"%WIFII","d":"Wifi IP"},{"n":"%WIFIMAC","d":"Wifi MAC"},{"n":"%WIFI","d":"Wifi Status"},{"n":"%WIFISSID","d":"Wifi SSID"},{"n":"%ZOOM","d":"Zoom Level"}]}
```

**No hallucination:** Use ONLY variables listed here. Do NOT assume existence of `%VOLR_RESTORE`, `%VOLC_RESTORE`, etc.

---

## 12. Variable Types & Structures

### Single-Value Variables

Hold one piece of data (e.g., `%my_variable`, `%HTTPD`, `%TIME`).

### Variable Arrays

Ordered list of values accessed via indices. Base name + numbers (e.g., `%arr1`, `%arr2`, `%arr3` form array `%arr`).

**Base name rules:** At least 3 characters, no digit start, correct case (local `%alllowercase` vs global `%hasUppercase`).

**1-Based Indexing:** Tasker arrays are **1-based**. First element is always index 1.

**Access Syntax:** (Assume `%arr1=alpha`, `%arr2=beta`, `%arr3=cat`, `%arr4=dog`)
- `%arr(#)` — Number of elements (4)
- `%arr(#>)` — Index of first element (1)
- `%arr(#<)` — Index of last element (4)
- `%arr(#?search)` — Comma-separated indices matching search
- `%arr(#?~Rregex)` — Indices matching regex
- `%arr(>)` — First element (alpha)
- `%arr(<)` — Last element (dog)
- `%arr()` or `%arr(:)` — All elements, comma-separated
- `%arr(index)` — Element at index
- `%arr(start:end)` — Slice (e.g., `%arr(2:4)` → beta,cat,dog)
- `%arr(:end)` — Slice from start to end
- `%arr(start:)` — Slice from start to end
- `%arr($?search)` — Values matching search
- `%arr($?~Rregex)` — Values matching regex
- `%arr(*)` — Random element
- `%arr(+=separator)` — Join with separator
- `%arr(+=separator+function)` — Join with function

**Manipulation:**
- `Array Push` (355): Position (arg1) must be 1–999999. Use `1` for start, `999999` for end.
- `Array Pop` — Remove from start/end/index
- `Array Process` — Sort/filter/deduplicate
- `Array Clear` — Delete all

**Array Trimming Strategy:**
1. Check size: `If %array(#) > N`
2. Extract slice: `%temp_slice = %array(1:N)` or `%temp_slice = %array(%start_index:)`
3. Overwrite: `Array Set` with comma splitter

### Structured Variables (JSON, HTML/XML, CSV)

**Prerequisite:** Source action must have "Structured Output" enabled.

**JSON Access:**
- Use square bracket notation: `%json[path.to.key]`
- Array elements: `%variable[path.to.array.property](index)` — path before index, 1-based
- Root JSON array: `%json_array[=:=root=:=]()`
- **MANDATORY Brackets for uppercase/special keys:** Always use `%variable[path.to.KeyWithCaps]` — dot notation is **forbidden** for keys with uppercase letters

**HTML/XML Access:**
- Tag content: `%html[div]`
- All matching: `%html[div]()`
- Attributes: `%html[img=:=src]`
- Full HTML: `%html[body=:=html]`
- CSS selectors: `{}` instead of `[]`, `«»` instead of `()`
- No nested reads: use CSS `query1 > query2`

**CSV Access:**
- Column by header: `%csv[column_name]`
- All values: `%csv[column_name]()`

### Variable Scope

- Context/Action outputs: local to the task run
- Global variables: `%HasCaps` — persist across Tasker
- `Perform Task` passes `%par1`, `%par2` explicitly
- "Local Variable Passthrough" passes all local variables
- `Return` sends values back to caller

---

## 13. Example Success Scenarios

### Incoming Call Announcement

Request: "When I receive a call I want my phone to say out loud that I'm receiving a call"

```xml
<TaskerData sr="" dvi="1" tv="6.5.3-beta">
    <Profile sr="prof84" ve="2">
        <cdate>1743502162548</cdate>
        <edate>1743502194856</edate>
        <flags>40</flags>
        <id>84</id>
        <mid0>85</mid0>
        <nme>Announce Incoming Call</nme>
        <State sr="con0" ve="2">
            <code>40</code>
            <Int sr="arg0" val="0"/>
            <Str sr="arg1" ve="3"/>
        </State>
    </Profile>
    <Task sr="task85">
        <id>85</id>
        <Action sr="act0" ve="7">
            <code>559</code>
            <Str sr="arg0" ve="3">Yo! A call is coming! Get ready!</Str>
            <Str sr="arg1" ve="3">default:default</Str>
            <Int sr="arg2" val="3"/>
            <Int sr="arg3" val="5"/>
            <Int sr="arg4" val="5"/>
            <Int sr="arg5" val="1"/>
            <Int sr="arg6" val="0"/>
            <Int sr="arg7" val="0"/>
        </Action>
    </Task>
</TaskerData>
```

### Screen Recording Shortcut

Request: "When I tap a shortcut I want screen recorded for 3 seconds"

```xml
<TaskerData sr="" dvi="1" tv="6.5.3-beta">
    <Task sr="task19">
        <id>19</id>
        <nme>Capture</nme>
        <pri>100</pri>
        <Action sr="act0" ve="7">
            <code>374</code>
            <Bundle sr="arg0"><Vals sr="val"/></Bundle>
            <Int sr="arg1" val="0"/>
            <Str sr="arg2" ve="3">Tasker/screen.mp4</Str>
            <Int sr="arg3" val="0"/>
            <Str sr="arg4" ve="3"/>
            <Str sr="arg5" ve="3"/>
            <Str sr="arg6" ve="3"/>
            <Str sr="arg7" ve="3"/>
        </Action>
        <Action sr="act1" ve="7">
            <code>30</code>
            <Int sr="arg0" val="0"/>
            <Int sr="arg1" val="3"/>
            <Int sr="arg2" val="0"/>
            <Int sr="arg3" val="0"/>
            <Int sr="arg4" val="0"/>
        </Action>
        <Action sr="act2" ve="7">
            <code>374</code>
            <Bundle sr="arg0"><Vals sr="val"/></Bundle>
            <Int sr="arg1" val="1"/>
            <Str sr="arg2" ve="3">Tasker/screen.mp4</Str>
            <Int sr="arg3" val="0"/>
            <Str sr="arg4" ve="3"/>
            <Str sr="arg5" ve="3"/>
            <Str sr="arg6" ve="3"/>
            <Str sr="arg7" ve="3"/>
        </Action>
    </Task>
</TaskerData>
```

### Gmail + NFC Project

Request: "Read Gmail notifications aloud + tap NFC to open Spotify"

```xml
<TaskerData sr="" dvi="1" tv="6.5.3-beta">
    <Profile sr="prof78" ve="2"><!-- Read Gmail --></Profile>
    <Profile sr="prof76" ve="2"><!-- NFC → Spotify --></Profile>
    <Project sr="proj0" ve="2">
        <name>Read Gmail And Launch Spotify With NFC</name>
        <pids>78,76</pids>
        <tids>79,75,92,77</tids>
    </Project>
    <!-- Tasks: task75 (Launch Spotify), task77 (Speak notification), 
         task79 (Count Out loud — unrelated standalone), 
         task92 (Open Spotify named task) -->
</TaskerData>
```

---

## 14. Example Clarification Scenarios

### Battery Widget

Request → "What battery level is low?" → "20" → Profile with 0-20 battery state + Widget v2 update

### Quick Setting Tile

Request → "What app?" → User selects Spotify → Standalone Task with Launch App

### Work/Home Volume

Request → "Home loud at work quiet" → Multiple clarifications (work wifi, home wifi, low level, high level) → Project with 2 profiles

---

## 15. Widget v2 Custom Layout JSON Schema

**NOTE:** This is a summary. Refer to the original file for the full nested schema with all element types (Box, Column, Row, Grid, Scaffold, Text, Image, Button, IconButton, CheckBox, Switch, Progress, TitleBar, Spacer).

### Key Rules

- **Material You colors only:** Use ONLY names from `colorString` enum: `widgetBackground`, `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`, `secondary`, `onSecondary`, `secondaryContainer`, `onSecondaryContainer`, `tertiary`, `onTertiary`, `tertiaryContainer`, `onTertiaryContainer`, `error`, `onError`, `errorContainer`, `onErrorContainer`, `background`, `onBackground`, `surface`, `onSurface`, `surfaceVariant`, `onSurfaceVariant`, `inverseSurface`, `inverseOnSurface`, `outline`, `inversePrimary`. Or hex codes (#RRGGBB or #AARRGGBB).
- Do NOT include `useMaterialYouColors` property
- `textSize` is NOT supported on Button elements
- Column with >10 children MUST enable `scrolling`
- Row supports max 10 children
- Use shorthand (`padding: 8`, `size: "fill"`) where possible

### Root Structure

Root must be a single `anyStructure` element containing:
- `type` (required): Box, Column, Row, Grid, Scaffold, Spacer, Text, Image, Button, IconButton, CheckBox, Switch, Progress, TitleBar
- Child elements go in `children` array
- Interactive elements use `task` + `taskVariables` (preferred) or `command` (fallback)
- `taskVariables` keys MUST be valid **local** variable names (`%alllowercase`, >= 3 chars)

### Dynamic Lists

**Array Merge method** (preferred when data in parallel arrays):
- Use `Array Merge` action (code 393) with `Merge Type = 1` (Format)
- Format string is JSON template for one item using source array paths as placeholders
- Output to accumulation array (e.g., `%widget_items`)

**For Loop method** (when additional per-item actions needed):
- Use `For %index Items 1:%source_array(#)`
- Build JSON string per item
- `Array Push` (355) to accumulation array

**Final injection:**
- `"children": [ %widget_items() ]` — **MUST be enclosed in square brackets**
- Accumulation array MUST be sole content of the children array
- Mixed static+dynamic: use nested container

### Pre-Widget Variable Setup

MUST use single `Multiple Variables Set` (389) with visual style:
- `Names` (arg1): `%variable_name=value` per line
- `Variable Names Splitter` (arg2): omit
- `Values` (arg3): omit
- `Values Splitter` (arg4): `=`
- **Mandatory color variables:** `%widget_color_background`, `%widget_color_text`, etc.

---

## 16. Widget v2 JSON Examples

### Positional Layout (Box nesting)

```json
{
  "children": [
    {"contentScale": "Crop", "url": "my_image_url", "size": "fill", "type": "Image"},
    {"children": [{"text": "Top", "padding": 16, "type": "Text"}],
     "horizontalAlignment": "Center", "verticalAlignment": "Top",
     "size": "fill", "type": "Box"},
    {"children": [{"text": "Bottom", "padding": 16, "type": "Text"}],
     "horizontalAlignment": "Center", "verticalAlignment": "Bottom",
     "size": "fill", "type": "Box"}
  ],
  "horizontalAlignment": "Center", "verticalAlignment": "Center",
  "fillMaxSize": true, "type": "Box"
}
```

### Task Calling with Variables

```json
{
  "children": [{
    "maxLines": 2, "text": "%http_data.data.children.data.title",
    "isWeighted": true, "paddingEnd": 8, "type": "Text"
  }],
  "padding": 8,
  "task": "Open URL",
  "taskVariables": {
    "%url": "https://www.reddit.com%http_data.data.children.data.permalink"
  },
  "type": "Row"
}
```

---

## 17. Pattern Matching Rules

### Operator Types

| Category | Operators | Description |
|----------|-----------|-------------|
| Simple Matching | `~` (Matches), `!~` (Doesn't Match) | Default text comparison. `*` = anything, `+` = one or more, `/` = OR. Case-insensitive unless RHS has uppercase. `!` at start negates. |
| Regex | `~R`, `!~R` | Java regular expressions |
| String Equality | `eq`, `ne` | Exact case-sensitive comparison |
| Numeric | `<`, `>`, `=`, `!=`, `Even`, `Odd` | For numbers only! Do NOT use for text. |
| Variable State | `Set`, `Not Set` | Checks if variable is defined |

### Operator Codes (for `<op>` tag in XML)

| Code | Operator | Usage |
|------|----------|-------|
| 0 | Equals String (eq) | Case-sensitive text |
| 1 | Not Equals String (ne) | Case-sensitive text |
| 2 | Matches Simple Pattern (`~`) | Glob/wildcard |
| 3 | Doesn't Match Simple Pattern (`!~`) | |
| 4 | Matches Regex (`~R`) | |
| 5 | Doesn't Match Regex (`!~R`) | |
| 6 | Less Than (`<`) | Numeric only |
| 7 | Greater Than (`>`) | Numeric only |
| 8 | Equals (`=`) | Numeric only |
| 9 | Not Equals (`!=`) | Numeric only |
| 10 | Even | Numeric only |
| 11 | Odd | Numeric only |
| 12 | Is Set | Variable defined |
| 13 | Is Not Set | Variable undefined |

### Boolean Logic

- Multiple `<Condition>` tags in `<ConditionList>`: N conditions need N-1 `<boolN>` elements
- `And`, `Or`, `Xor`, `And2` (`&+`), `Or2` (`|+`), `Xor2` (`X|+`)
- Precedence (high to low): `And2` > `Or2` > `Xor2` > `And` > `Or` > `Xor`

### Caller Matching Special Patterns
- `C:ANY` — Any contact
- `C:FAV` — Favorite/starred contact
- `CG:groupmatch` — Contact in group matching pattern

---

## 18. Command System

### Purpose

Flexible system for triggering Profiles based on custom commands from various Tasker actions.

### Syntax

`prefix=:=value1=:=value2=:=...`

### Sending

`Command` action (code 385) or within parameters of other actions (Quick Setting Tile, Widget v2).

### Receiving

Profile using `Command` Event context (code 2091):
- `arg1` (Command): Filter using Pattern Matching — **CANNOT use variables in filter**
- `arg2` (Variables): Comma-separated list of **full local variable names** (e.g., `%app,%type`)
- `arg3` (Last Variable Is Array): If `1`, last variable becomes array of remaining parts

### Implicit Output

Full command string available as `%evtprm1`.

### Use Cases

- Parameterized Quick Settings tiles
- Decoupling widget interactions from specific tasks
- Centralized command handling

**Prefer Task Calling with Variables** over Command System for Widget v2 interactions. Command System requires Project structure.

---

## 19. Handling Modification Requests

When user provides existing XML and requests modifications:

1. **Preserve original IDs**: Profile `<id>`, Task `<id>`, Project `<name>`
2. **Preserve original names**: `<nme>` for Profiles and named Tasks
3. **Preserve anonymity**: Anonymous tasks stay anonymous
4. **Rename exception**: Only if user explicitly asks to rename
5. **Focus modifications**: Only modify components targeted by the request

---

## Strict Rules Summary

1. **No third-party plugins**: Refuse requests involving AutoApps, AutoNotification, Join, AutoInput, etc.
2. **No hallucination of components**: Use ONLY `code` values from provided Event/State/Action catalogs
3. **XML tag type matching**: `"a"` field in catalog is THE SOLE determinant of XML tag type (e.g., `"a":"Img"` → `<Img>`, not `<Str>`)
4. **Variable naming**: Base names ≥ 3 chars, no digit start, correct case — applies to locally generated vars too (use `%index`, never `%i`)
5. **1-Based arrays**: Always — `For` loops start at `1`, `Array Push` position min `1`
6. **Int with `<var>` tag**: Variables in `<Int>` arguments MUST use `<var>` tag, NOT `val` attribute
7. **Flash for errors, Notify for action errors**: Precondition → `Flash` + `Stop`. Action errors → `<se>false</se>` + `Notify %errmsg` + `Stop`
8. **Structured output**: Explicitly enable `bosta` parameter when using JSON/HTML/CSV access
9. **State inversion**: Use `<pin>true</pin>`, NOT by manipulating parameters like Wifi Connected's arg3
10. **Exit Task for State profiles**: `flags=40` disables auto-restore — must manually restore in Exit Task
11. **Widget colors**: ONLY from `colorString` enum in section 15, or hex codes
12. **Widget dynamic lists**: Use `Array Merge` (393) or `For` + `Array Push` — never static repetition
13. **Widget injection**: `[ %widget_items() ]` — brackets REQUIRED
14. **Project `sr="proj0"`**: Must be exactly `"proj0"`
15. **`<nme>` rules**: Anonymous for profile tasks, required for standalone/named tasks
16. **No `While` loops**: Not in Action Catalog — do not generate
17. **`Multiple Variables Set`**: Use single action for 2+ consecutive variable assignments or pre-widget setup
18. **Avoid long `Wait`**: Use timestamp math (`%TIMES`) for delays > 30 seconds
19. **XML escaping**: `&` → `&amp;`, `<` → `&lt;`, etc.
