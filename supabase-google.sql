-- Zu zweit 1005: Google-Maps-Links (Ein- und Ausgang).
-- Einmal im Supabase SQL Editor ausführen (nach supabase.sql und supabase-orte.sql). Kann mehrfach laufen.

-- 1) Orte merken sich den Original-Link aus Google Maps
alter table public.zz_orte add column if not exists link text;

-- 2) zz_speichern speichert den Link mit
create or replace function public.zz_speichern(p_code text, p_anlaesse jsonb, p_aufgaben jsonb, p_namen jsonb default null, p_orte jsonb default null)
returns jsonb language plpgsql volatile security definer set search_path = public, extensions as $$
declare l uuid := public.zz_liste_id(p_code);
begin
  if l is null then
    raise exception 'Liste unbekannt' using errcode = 'P0002';
  end if;

  if p_namen is not null then
    update public.zz_listen set namen = p_namen where id = l;
  end if;

  insert into public.zz_anlaesse as z (id, liste, titel, datum, geloescht, geaendert)
  select x.id, l, left(x.titel, 120), x.datum, coalesce(x.geloescht, false), coalesce(x.geaendert, now())
  from jsonb_to_recordset(coalesce(p_anlaesse, '[]'::jsonb))
       as x(id uuid, titel text, datum date, geloescht boolean, geaendert timestamptz)
  where x.id is not null and x.titel is not null
  on conflict (id) do update set
    titel = excluded.titel, datum = excluded.datum, geloescht = excluded.geloescht, geaendert = excluded.geaendert
  where z.liste = l and excluded.geaendert >= z.geaendert;

  insert into public.zz_aufgaben as z (id, liste, anlass, text, gruppe, wer, von, erstellt, erledigt_von, erledigt_am, geloescht, geaendert, sort)
  select x.id, l, x.anlass, left(x.text, 500), coalesce(x.gruppe, 'erledigen'), coalesce(x.wer, 'wir'), x.von,
         coalesce(x.erstellt, now()), x.erledigt_von, x.erledigt_am, coalesce(x.geloescht, false),
         coalesce(x.geaendert, now()), coalesce(x.sort, 0)
  from jsonb_to_recordset(coalesce(p_aufgaben, '[]'::jsonb))
       as x(id uuid, anlass uuid, text text, gruppe text, wer text, von text, erstellt timestamptz,
            erledigt_von text, erledigt_am timestamptz, geloescht boolean, geaendert timestamptz, sort double precision)
  where x.id is not null and x.text is not null
  on conflict (id) do update set
    anlass = excluded.anlass, text = excluded.text, gruppe = excluded.gruppe, wer = excluded.wer,
    erledigt_von = excluded.erledigt_von, erledigt_am = excluded.erledigt_am,
    geloescht = excluded.geloescht, geaendert = excluded.geaendert, sort = excluded.sort
  where z.liste = l and excluded.geaendert >= z.geaendert;

  insert into public.zz_orte as z (id, liste, name, notiz, lat, lng, link, von, erstellt, besucht_von, besucht_am, geloescht, geaendert)
  select x.id, l, left(x.name, 120), left(x.notiz, 1000), x.lat, x.lng,
         case when x.link ~* '^https://' then left(x.link, 2000) end,
         x.von, coalesce(x.erstellt, now()), x.besucht_von, x.besucht_am, coalesce(x.geloescht, false), coalesce(x.geaendert, now())
  from jsonb_to_recordset(coalesce(p_orte, '[]'::jsonb))
       as x(id uuid, name text, notiz text, lat double precision, lng double precision, link text, von text, erstellt timestamptz,
            besucht_von text, besucht_am timestamptz, geloescht boolean, geaendert timestamptz)
  where x.id is not null and x.name is not null and x.lat between -90 and 90 and x.lng between -180 and 180
  on conflict (id) do update set
    name = excluded.name, notiz = excluded.notiz, lat = excluded.lat, lng = excluded.lng, link = excluded.link,
    besucht_von = excluded.besucht_von, besucht_am = excluded.besucht_am,
    geloescht = excluded.geloescht, geaendert = excluded.geaendert
  where z.liste = l and excluded.geaendert >= z.geaendert;

  return public.zz_laden(p_code);
end $$;

-- 3) Kurzlinks (maps.app.goo.gl) auflösen. Der Browser darf das nicht, die Datenbank schon.
--    Nur für Google-Kurzlinks und nur mit gültigem Listen-Code.
create extension if not exists http with schema extensions;

create or replace function public.zz_link_aufloesen(p_code text, p_url text)
returns text language plpgsql volatile security definer set search_path = public, extensions as $$
declare
  u text := btrim(p_url);
  r extensions.http_response;
  loc text;
  body text;
  found text[];
  i int;
begin
  if public.zz_liste_id(p_code) is null then
    raise exception 'Liste unbekannt' using errcode = 'P0002';
  end if;
  begin perform extensions.http_set_curlopt('CURLOPT_TIMEOUT', '6'); exception when others then null; end;
  begin perform extensions.http_set_curlopt('CURLOPT_FOLLOWLOCATION', '0'); exception when others then null; end;
  for i in 1..4 loop
    if u !~* '^https://(maps\.app\.goo\.gl|goo\.gl/maps|g\.co/kgs)/' then
      return u;                                   -- schon ein langer Link: fertig
    end if;
    r := extensions.http(('GET', u, array[extensions.http_header('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X)')], null, null)::extensions.http_request);
    select h.value into loc from unnest(r.headers) h where lower(h.field) = 'location' limit 1;
    if loc is not null then
      u := loc;                                   -- Weiterleitung: nächste Runde
      continue;
    end if;
    -- Weiterleitung wurde schon verfolgt: Ziel-Link aus der Seite fischen
    body := replace(replace(replace(coalesce(r.content, ''), '&amp;', '&'), '=', '='), '&', '&');
    found := regexp_match(body, '(https://www\.google\.[a-z.]+/maps/[^"''\s<>\\]+)');
    if found is not null then return found[1]; end if;
    found := regexp_match(body, 'center=(-?[0-9.]+)(?:%2C|,)(-?[0-9.]+)');
    if found is not null then return 'https://www.google.com/maps/search/?api=1&query=' || found[1] || ',' || found[2]; end if;
    found := regexp_match(body, 'continue=([^"&]+)');
    if found is not null then return found[1]; end if;
    return u;
  end loop;
  return u;
end $$;

revoke execute on function public.zz_link_aufloesen(text, text) from public;
grant execute on function public.zz_link_aufloesen(text, text) to anon, authenticated;
notify pgrst, 'reload schema';
