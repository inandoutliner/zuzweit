# Inhaltskarte

Automatisch erzeugt mit `werkstatt/werkzeuge/karte.py`. Stand: 6eae87d, 2026-11-27: Zu zweit 1004: Kartenhintergrund OpenStreetMap statt CARTO (CARTO verlangt jetzt API-Schlüssel)

Vorgehen: Abschnitt hier finden → `grep -n "<Titel>" index.html` → nur diesen Bereich lesen.

## `index.html` – Zu zweit 1005
1250 Zeilen, 81 KB.

**Bedien-Bereiche (HTML)**

- 274: `<section>` welcome – Willkommen
- 319: `<section>` karte – Karte
- 344: `<nav>` events – Anlässe
- 346: `<section>` hero – Aktueller Anlass
- 384: `<dialog>` dItem – Aufgabe bearbeiten
- 398: `<dialog>` dEv – Anlass
- 411: `<dialog>` dSet – Einstellungen
- 441: `<dialog>` dOrt – Ort
- 455: `<dialog>` dShare – Link teilen
- 706: `<section>` ${label}

**Abschnitte im Code** (Suchbegriff = Titel)

| Zeile | Abschnitt | Funktionen |
|---|---|---|
| 19–52 | Farben und Schriften |  |
| 52–68 | Kopf |  |
| 68–81 | Anlässe |  |
| 81–102 | Bühne: der aktuelle Anlass |  |
| 102–110 | Filter |  |
| 110–150 | Liste |  |
| 150–168 | Eingabe unten |  |
| 168–186 | Knöpfe, Felder |  |
| 186–199 | Blätter (Dialoge von unten) |  |
| 199–216 | Willkommen |  |
| 216–224 | Ansicht wechseln: Liste / Karte |  |
| 224–469 | Karte |  |
| 469–491 | Grundlagen | $, esc, uid, nowIso, makeCode, sha |
| 491–512 | Datum | todayStr, dayDiff, fmtDate, fmtStamp, countText |
| 512–540 | Zustand | other, nameOf, initial, saveLocal, liveEvents, liveTasks, evById, tasksOf, sortedEvents, nextEvent, ensureCur |
| 540–565 | lokale Änderungen | putTask, putEvent, addTasks |
| 565–577 | Server (Supabase-Funktionen) | rpc |
| 577–627 | Abgleich | pendingCount, syncSoon, sync, applyServer, setStatus |
| 627–644 | Live-Signal: „ich habe etwas geändert“ (Supabase Realtime Broadcast) | loadRealtime, ping |
| 644–736 | Zeichnen | avatar, whoLabel, isNew, render, renderEvents, renderHero, renderList, row, renderComposer, cycle |
| 736–805 | Bedienung | stampOn, grow, toast |
| 805–842 | Blatt: Aufgabe | segHtml, bindSeg, segVal, openItem |
| 842–868 | Blatt: Anlass | openEvent |
| 868–902 | Blatt: Einstellungen | shareLink, shareTo, copy |
| 902–968 | Start: Link lesen, anlegen, beitreten | parseLink, keepHash, openList, start, askWho |
| 968–1096 | Karte: Orte mit Kommentar | liveOrte, ortById, isNewOrt, gmapsUrl, mapsUrl, coord, putOrt, setView, renderTabs, loadLeaflet, initMap, pinIcon … +5 |
| 1096–1250 | Eingang aus Google Maps | parseGoogle, inNZ, importShared, renderOrte, openOrt, markSeen |
