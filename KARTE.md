# Inhaltskarte

Automatisch erzeugt mit `werkstatt/werkzeuge/karte.py`. Stand: 1c6d26f, 2026-11-27: Zu zweit 1003: Karte von Neuseeland mit Orten und Kommentaren

Vorgehen: Abschnitt hier finden → `grep -n "<Titel>" index.html` → nur diesen Bereich lesen.

## `index.html` – Zu zweit 1004
1176 Zeilen, 76 KB.

**Bedien-Bereiche (HTML)**

- 274: `<section>` welcome – Willkommen
- 319: `<section>` karte – Karte
- 344: `<nav>` events – Anlässe
- 346: `<section>` hero – Aktueller Anlass
- 384: `<dialog>` dItem – Aufgabe bearbeiten
- 398: `<dialog>` dEv – Anlass
- 411: `<dialog>` dSet – Einstellungen
- 434: `<dialog>` dOrt – Ort
- 448: `<dialog>` dShare – Link teilen
- 699: `<section>` ${label}

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
| 224–462 | Karte |  |
| 462–484 | Grundlagen | $, esc, uid, nowIso, makeCode, sha |
| 484–505 | Datum | todayStr, dayDiff, fmtDate, fmtStamp, countText |
| 505–533 | Zustand | other, nameOf, initial, saveLocal, liveEvents, liveTasks, evById, tasksOf, sortedEvents, nextEvent, ensureCur |
| 533–558 | lokale Änderungen | putTask, putEvent, addTasks |
| 558–570 | Server (Supabase-Funktionen) | rpc |
| 570–620 | Abgleich | pendingCount, syncSoon, sync, applyServer, setStatus |
| 620–637 | Live-Signal: „ich habe etwas geändert“ (Supabase Realtime Broadcast) | loadRealtime, ping |
| 637–729 | Zeichnen | avatar, whoLabel, isNew, render, renderEvents, renderHero, renderList, row, renderComposer, cycle |
| 729–798 | Bedienung | stampOn, grow, toast |
| 798–835 | Blatt: Aufgabe | segHtml, bindSeg, segVal, openItem |
| 835–861 | Blatt: Anlass | openEvent |
| 861–894 | Blatt: Einstellungen | shareLink, shareTo, copy |
| 894–958 | Start: Link lesen, anlegen, beitreten | parseLink, keepHash, openList, start, askWho |
| 958–1176 | Karte: Orte mit Kommentar | liveOrte, ortById, isNewOrt, mapsUrl, coord, putOrt, setView, renderTabs, loadLeaflet, initMap, pinIcon, popupHtml … +6 |
