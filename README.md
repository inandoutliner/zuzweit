# Zu zweit

Geteilte To-do-Liste für zwei, als Web-App auf beiden iPhones. Beide tragen ein und haken ab, sortiert nach dem nächsten Anlass (z. B. „Vor dem Abflug“), innerhalb des Anlasses in Erledigen, Besorgen, Einpacken.

Online: https://inandoutliner.github.io/zuzweit/

- `index.html` – die ganze App
- `config.js` – Supabase-Adresse und öffentlicher Schlüssel (dasselbe Projekt wie Weihnachten)
- `supabase.sql` – Tabellen und Funktionen, einmal im Supabase SQL Editor ausführen
- `supabase-orte.sql` – Ergänzung für die Karte (ab 1003), danach einmal ausführen
- `supabase-google.sql` – Ergänzung für Google-Maps-Links (ab 1005), danach einmal ausführen
- `supabase-kurzbefehl.sql` – Speichern direkt aus dem Kurzbefehl (ab 1006), danach einmal ausführen
- `lib/leaflet/` – Kartenbibliothek Leaflet 1.9.4 (BSD-2-Clause, © Vladimir Agafonkin), liegt im Repo, damit sie offline läuft
- `sw.js` – hält die App offline verfügbar (Flugzeug, Camper)

## So funktioniert's

- Jede Aufgabe gehört zu einem Anlass mit Datum oder zu „Irgendwann“. Oben steht der nächste Anlass mit Countdown.
- Zuständig: Ich, Du oder Beide (Kreis rechts antippen wechselt).
- „Neu von …“ markiert, was die andere Person seit dem letzten Öffnen eingetragen hat.
- Abhaken und Löschen lassen sich 5 Sekunden lang rückgängig machen.
- Ist ein Anlass vorbei, bietet die App an, offene Punkte zum nächsten Anlass zu verschieben.
- Ohne Netz werden Änderungen gesammelt und später abgeglichen (Anzeige oben rechts).

## Karte (ab 1003)

- Reiter „Karte“ oben: Neuseeland-Karte, Orte mit Name und Kommentar merken.
- Ort setzen: auf die Karte tippen, oben suchen (OpenStreetMap-Suche Nominatim, nur Neuseeland) oder „Mein Standort“.
- Pins: Blau = von mir, Pink = von der anderen Person, Gelb mit Haken = dort gewesen.
- Liste unter der Karte von Nord nach Süd, mit Abhaken („dort gewesen“) und „Hinfahren“ (öffnet Apple Karten).
- Kartenhintergrund: OpenStreetMap-Standardkarte (ohne Schlüssel; im Dunkelmodus per Filter abgedunkelt). Einmal angesehene Kacheln speichert die App für offline. CARTO (bis 1003) verlangt inzwischen einen API-Schlüssel.

## Google Maps (ab 1006)

Ziel: zwischen Zu zweit und der Google-Maps-App hin- und herspringen.

- **Zu zweit → Google Maps:** „Google Maps“ (Popup) bzw. „In Google Maps ansehen“ öffnen direkt die App (`comgooglemapsurl://` für gespeicherte Google-Links, sonst `comgooglemaps://?q=lat,lng`).
- **Google Maps → Zu zweit (Kurzbefehl, speichert im Hintergrund):** Kurzbefehle-App → + → Name „Zu zweit“ → ⓘ → „Im Share-Sheet anzeigen“. Aktionen:
  1. „Inhalt von URL abrufen“: URL = Wert 1 (Einstellungen → „1 · Adresse“), Methode POST, Header `apikey` = Wert 2, Anfragetext JSON mit Feld `p_text` (Text) = Wert 3 und direkt dahinter die Variable „Kurzbefehleingabe“.
  2. „Mitteilung anzeigen“ mit „Inhalt der URL“.
  Optional davor „Nach Eingabe fragen“ (Kommentar) und im JSON ein zweites Feld `p_notiz` mit „Angegebene Eingabe“.
- **Ohne Kurzbefehl:** Google Maps → Teilen → Kopieren, Link auf der Karte ins Suchfeld einfügen.
- Server: `zz_ort_aus_google` (supabase-kurzbefehl.sql) liest Code + Person aus dem Text, löst Kurzlinks über `zz_link_aufloesen` auf (supabase-google.sql, Erweiterung `http`), fällt sonst auf OpenStreetMap-Suche zurück und speichert nur Orte in Neuseeland.

## Daten und Zugriff

Die Daten liegen in Supabase (Tabellen `zz_listen`, `zz_anlaesse`, `zz_aufgaben`, `zz_orte`), nicht im Repo. Die Tabellen sind direkt nicht lesbar; die App spricht nur über die Funktionen `zz_anlegen`, `zz_laden`, `zz_speichern` und muss dabei den geheimen Listen-Code aus dem Link (`#k=…`) mitschicken. Gespeichert wird nur dessen SHA-256-Wert. Der Code steht im Teil hinter `#` und geht daher nicht an GitHub Pages.

Wer den Link hat, kann die Liste lesen und ändern. Namen stehen nur in der Datenbank, nicht im Repo.

Live-Abgleich: Nach einer Änderung schickt die App ein Signal über Supabase Realtime (Broadcast), das andere iPhone lädt dann neu. Zusätzlich gleicht sie alle 20 Sekunden und beim Öffnen ab.

Inhaltskarte für Änderungen: [KARTE.md](KARTE.md)
