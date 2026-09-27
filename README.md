# TreePaint Client

Advanced local PostgreSQL Query Plan visualizer running on Love2D/LuaJIT.

This project aims to provide smooth browsing experience, statistics and insights into PostgreSQL query plans and more.\
All while being lightweight, fast, easily modifiable, portable, platform-agnostic, and running locally on your device.

Consider checking out a helper extension [pg_treepaint](https://github.com/REUSS-dev/pg_treepaint) that collects query parsing, planning & execution data from the server and sends it to a TreePaint Client via a TCP Socket. It enables such functionality as Query structure browsing. 

This project is made for LOVE 11.5. It will be adapted to LOVE 12.0 once it would be released officially.

<img width="999" height="522" alt="image" src="https://github.com/user-attachments/assets/59dde486-8a2a-4e47-9405-2feb3ffaefc4" />

# Running
## Windows
1. [Get LOVE](https://love2d.org). Download and install either 64-bit (recommended) or 32-bit version of a runtime.
2. Get the latest pg_treepaint_client.zip from [Releases](https://github.com/REUSS-dev/pg_treepaint_client/releases) and unzip it somewhere.
   * Or clone this repository `git clone --recurse-submodules https://github.com/REUSS-dev/pg_treepaint_client/`\
(Do not use "Code" > "Download ZIP" as it will not include the required submodule files.)
3. Double-click `start.bat` to launch an application.

## Linux
1. [Get LOVE](https://love2d.org).
   * apt users can get it both from Debain and Ubuntu repositories with `sudo apt-get install love`.\
     Make sure version you get is at least 11.0
   * pacman users can get it from extra with `sudo pacman -S love`.
2. Clone this repository `git clone --recurse-submodules https://github.com/REUSS-dev/pg_treepaint_client/`
   * Or get the latest pg_treepaint_client.zip from [Releases](https://github.com/REUSS-dev/pg_treepaint_client/releases) and unzip it somewhere.
3. Run `love .` inside the source code root.

## Android
1. [Get LOVE](https://love2d.org). Download Android APK in section "Other Downloads" and install it on your device.
2. Get the latest pg_treepaint_client.zip from [Releases](https://github.com/REUSS-dev/pg_treepaint_client/releases) and change its extension to read `.love` instead of `.zip`. Launch the `.love` file with installed LOVE app.
   * Or create a folder in your sdcard root called "lovegame" and unzip the contents of downloaded zip into "/sdcard/lovegame". Then launch LOVE app from your launcher.  (May noy work in later android versions. You may have to put program source code into `/sdcard/Android/data/org.love2d.android/files/games/lovegame` instead.)


# Usage
TreePaint Client can be either used as a receiver for plans [pg_treepaint extension](https://github.com/REUSS-dev/pg_treepaint) sends or as a standalone visualizer.\
pg_treepaint receiver functionality is enabled using a TCP Listener applet on top-right of the screen. This is described in [pg_treepaint's readme](https://github.com/REUSS-dev/pg_treepaint/tree/master#configuration). 

Currently program supports JSON-formatted input, and parsing for Text-formatted EXPLAIN output is very limited.

You can try TreePaint out with the provided example Query Plans in directory `examples`.

TreePaint Client includes different color themes and locales, as well as other configuration parameters defined in conf.lua. See [conf.lua](https://github.com/REUSS-dev/pg_treepaint_client/blob/master/conf.lua) for explanations.

<img width="1282" height="721" alt="image" src="https://github.com/user-attachments/assets/0661e917-e17f-49e1-b339-3465a64d50d1" />

TreePaint Client currently implements:
* Processing of a full range of EXPLAIN options including: ANALYZE, VERBOSE, BUFFERS, SETTINGS, WAL & "SET track_io_timing = TRUE;".
* Query plan tree traversal, subtree folding, CTE, Subplan, Subquery and parallel sections folding.
* Advanced parallel sections processing and visualization. Full per-worker statistics (including the master process separately).
* Plan summary with combined info on the whole plan and stats that include resources used by subqueries and CTEs.
* Separate per-node and subtree planning & execution stats. Stats pertaining to common categories are combined into individual sections like "Buffer Stats",  "Filter Stats", "Worker Stats" and etc. 
* 4 Buffer Info view modes: buffer count, percentage within category, bytes read/written, I/O time 
* Query plan mini-map. Can be zoomed-in, zoomed-out, hidden. Size can be changed in conf.lua.
* Plan navigation buttons. Shortcuts to parent node, children nodes, associated CTE subplan (for CTE Scan nodes).
* Minimal TEXT-format parsing.
* Retained-mode rendering, minimal load on CPU and GPU.
* Configurable color themes. Predefined themes: light, dark. Can be changed in conf.lua
* Rich localization engine. Included locales: en_US, ru_RU. Can be changed in conf.lua
* Pure Lua implementation, zero platform-dependent code.

## Basic Manual

<img width="1398" height="721" alt="image" src="https://github.com/user-attachments/assets/d652d96f-0954-4f7a-a54e-79ec5e489af1" />
<br><br>

* Check out example plans in the directory "examples".
* Copy plan JSON and click the button "Plot from Clipboard". A plan diagram and its summary will appear.
* Summary can be hidden using the chevron button to its top-right.
* Diagram can be panned with the mouse, dragging it with left click, or with the mouse wheel (and laptop precision touchpads' gestures respectively).
* Click on any node on the diagram to see its data. Node itself will be highlighted and paths to its parent and children will light up.
   * Buttons that send you to a Node's parent, each of Node's children and corresponding CTE (for CTE scans) will appear.
* Minimap can be hidden ('#' button), zoomed-in ('+' button) or zoomed-out ('-' button).
* View mode of Buffers Table can be changed by clicking light-blue button on the top-left of a table.

# Misc screenshots
<img width="1425" height="721" alt="image" src="https://github.com/user-attachments/assets/e0aee8c6-ebe4-4164-8b0e-fec489998260" />
<img width="1282" height="721" alt="image" src="https://github.com/user-attachments/assets/44adac29-6abd-4232-bf91-c7ec5e58540a" />