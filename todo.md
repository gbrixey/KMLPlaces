TODO list:
==========

Match functionality of old app
------------------------------
- List
    - All places button?
    - Nearby search
- Map
    - Button to show user's current location

New functionality
-----------------
- Show paths/polygons in list and on details page
    - Figure out how to calculate distance for nearby search
- Parse Styles from KML
    - Display icons specified in KML on map and list
        - SDWebImage
    - Use a different icon in list for folders, paths, and polylines
    - Use a default icon (SF Symbols pin in list)
- Ensure app looks OK in dark mode
- Update text search to search for folders as well
    - Maybe opening a folder from text search should open the whole folder hierarchy
- Render HTML descriptions in details page?
    - https://developers.google.com/kml/documentation/kml_tut
- Camera angle?
- Allow users to show/hide places and folders on map and/or list
- Map settings
    - Layers (satellite)
    - Turn clustering on/off
    - Maximum number of annotations to show?
- Settings screen
    - Option to clear all data
    - HTML on/off
    - Restore hidden places
    - See error log from importing KML data
- Data import screen
    - Select whether to replace existing data or add to it
        - If adding, select whether to update existing entries with the same name or add duplicates
    - Add a loading modal view
    - Keep a copy of the KML on device to re-parse when app is updated?
- Tutorial
    - Prompt user to import data when first launching the app 
    - Use sample data as a default?
- Accessibility
- Add README

Things that are not currently supported by SwiftUI
--------------------------------------------------
- List
    - Text search (will be available in iOS 15)
- Map
    - Tap annotation to show name and navigate to details page
    - Display paths and areas on map as polylines and overlays
        - Can the color of a path/overlay be specified in KML? If not, make it customizable in app?
    - Map annotation clustering
