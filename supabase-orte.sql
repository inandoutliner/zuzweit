-- Zu zweit 1003: Orte auf der Karte.
-- Einmal im Supabase SQL Editor ausführen (nach supabase.sql). Kann mehrfach laufen.

create table if not exists public.zz_orte (
  id uuid primary key,
  liste uuid not null references public.zz_listen(id) on delete cascade,
  name text not null,
  notiz text,
  lat double precision not null,
  lng double precision not null,
  von text,
  erstellt timestamptz not null default now(),
  besucht_von text,
  besucht_am timestamptz,
  geloescht boolean not null default false,
  geaendert timestamptz not null default now()
);
create index if not exists zz_orte_liste on public.zz_orte(liste);
alter table public.zz_orte enable row level security;
revoke all on table public.zz_orte from anon, authenticated;

create or replace function public.zz_laden(p_code text)
returns jsonb language plpgsql stable security definer set search_path = public, extensions as $$
declare l uuid := public.zz_liste_id(p_code);
begin
  if l is null then
    raise exception 'Liste unbekannt' using errcode = 'P0002';
  end if;
  return jsonb_build_object(
    'namen', (select namen from public.zz_listen where id = l),
    'anlaesse', coalesce((select jsonb_agg(to_jsonb(a) - 'liste') from public.zz_anlaesse a
                          where a.liste = l and not a.geloescht), '[]'::jsonb),
    'aufgaben', coalesce((select jsonb_agg(to_jsonb(t) - 'liste') from public.zz_aufgaben t
                          where t.liste = l and not t.geloescht), '[]'::jsonb),
    'orte', coalesce((select jsonb_agg(to_jsonb(o) - 'liste') from public.zz_orte o
                      where o.liste = l and not o.geloescht), '[]'::jsonb)
  );
end $$;

drop function if exists public.zz_speichern(text, jsonb, jsonb, jsonb);
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

  insert into public.zz_orte as z (id, liste, name, notiz, lat, lng, von, erstellt, besucht_von, besucht_am, geloescht, geaendert)
  select x.id, l, left(x.name, 120), left(x.notiz, 1000), x.lat, x.lng, x.von, coalesce(x.erstellt, now()),
         x.besucht_von, x.besucht_am, coalesce(x.geloescht, false), coalesce(x.geaendert, now())
  from jsonb_to_recordset(coalesce(p_orte, '[]'::jsonb))
       as x(id uuid, name text, notiz text, lat double precision, lng double precision, von text, erstellt timestamptz,
            besucht_von text, besucht_am timestamptz, geloescht boolean, geaendert timestamptz)
  where x.id is not null and x.name is not null and x.lat between -90 and 90 and x.lng between -180 and 180
  on conflict (id) do update set
    name = excluded.name, notiz = excluded.notiz, lat = excluded.lat, lng = excluded.lng,
    besucht_von = excluded.besucht_von, besucht_am = excluded.besucht_am,
    geloescht = excluded.geloescht, geaendert = excluded.geaendert
  where z.liste = l and excluded.geaendert >= z.geaendert;

  return public.zz_laden(p_code);
end $$;

revoke execute on function public.zz_speichern(text, jsonb, jsonb, jsonb, jsonb) from public;
grant execute on function public.zz_laden(text) to anon, authenticated;
grant execute on function public.zz_speichern(text, jsonb, jsonb, jsonb, jsonb) to anon, authenticated;
notify pgrst, 'reload schema';
