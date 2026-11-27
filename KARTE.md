# Inhaltskarte

Automatisch erzeugt mit `werkstatt/werkzeuge/karte.py`. Stand: 267e614, 2026-11-24: Zu zweit 1002: Platzhalter je Gruppe (Was braucht’s? / Was muss mit?)

Vorgehen: Abschnitt hier finden → `grep -n "<Titel>" index.html` → nur diesen Bereich lesen.

## `index.html` – Zu zweit 1003
1176 Zeilen, 76 KB.

**Bedien-Bereiche (HTML)**

- 273: `<section>` welcome – Willkommen
- 318: `<section>` karte – Karte
- 343: `<nav>` events – Anlässe
- 345: `<section>` hero – Aktueller Anlass
- 383: `<dialog>` dItem – Aufgabe bearbeiten
- 397: `<dialog>` dEv – Anlass
- 410: `<dialog>` dSet – Einstellungen
- 433: `<dialog>` dOrt – Ort
- 447: `<dialog>` dShare – Link teilen
- 698: `<section>` ${label}

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
| 224–461 | Karte |  |
| 461–483 | Grundlagen | $, esc, uid, nowIso, makeCode, sha |
| 483–504 | Datum | todayStr, dayDiff, fmtDate, fmtStamp, countText |
| 504–532 | Zustand | other, nameOf, initial, saveLocal, liveEvents, liveTasks, evById, tasksOf, sortedEvents, nextEvent, ensureCur |
| 532–557 | lokale Änderungen | putTask, putEvent, addTasks |
| 557–569 | Server (Supabase-Funktionen) | rpc |
| 569–619 | Abgleich | pendingCount, syncSoon, sync, applyServer, setStatus |
| 619–636 | Live-Signal: „ich habe etwas geändert“ (Supabase Realtime Broadcast) | loadRealtime, ping |
| 636–728 | Zeichnen | avatar, whoLabel, isNew, render, renderEvents, renderHero, renderList, row, renderComposer, cycle |
| 728–797 | Bedienung | stampOn, grow, toast |
| 797–834 | Blatt: Aufgabe | segHtml, bindSeg, segVal, openItem |
| 834–860 | Blatt: Anlass | openEvent |
| 860–893 | Blatt: Einstellungen | shareLink, shareTo, copy |
| 893–957 | Start: Link lesen, anlegen, beitreten | parseLink, keepHash, openList, start, askWho |
| 957–1176 | Karte: Orte mit Kommentar | liveOrte, ortById, isNewOrt, mapsUrl, coord, putOrt, setView, renderTabs, loadLeaflet, initMap, pinIcon, popupHtml … +6 |
