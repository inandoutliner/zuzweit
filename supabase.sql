-- Zu zweit: Tabellen und Funktionen für Supabase.
-- Einmal im Supabase-Dashboard unter "SQL Editor" einfügen und "Run" drücken.
-- Kann gefahrlos noch einmal ausgeführt werden (ändert keine Daten).
--
-- Zugriff: Die Tabellen sind für niemanden direkt lesbar (RLS an, keine Regeln).
-- Die App spricht nur über drei Funktionen mit der Datenbank und muss dabei den
-- geheimen Listen-Code mitschicken. Gespeichert wird nur dessen SHA-256-Wert.

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.zz_listen (
  id uuid primary key default gen_random_uuid(),
  code_hash text unique not null,
  namen jsonb not null default '{}'::jsonb,
  erstellt timestamptz not null default now()
);

create table if not exists public.zz_anlaesse (
  id uuid primary key,
  liste uuid not null references public.zz_listen(id) on delete cascade,
  titel text not null,
  datum date,
  geloescht boolean not null default false,
  geaendert timestamptz not null default now()
);

create table if not exists public.zz_aufgaben (
  id uuid primary key,
  liste uuid not null references public.zz_listen(id) on delete cascade,
  anlass uuid,
  text text not null,
  gruppe text not null default 'erledigen',
  wer text not null default 'wir',
  von text,
  erstellt timestamptz not null default now(),
  erledigt_von text,
  erledigt_am timestamptz,
  geloescht boolean not null default false,
  geaendert timestamptz not null default now(),
  sort double precision not null default 0
);

create index if not exists zz_anlaesse_liste on public.zz_anlaesse(liste);
create index if not exists zz_aufgaben_liste on public.zz_aufgaben(liste);

alter table public.zz_listen enable row level security;
alter table public.zz_anlaesse enable row level security;
alter table public.zz_aufgaben enable row level security;
revoke all on table public.zz_listen, public.zz_anlaesse, public.zz_aufgaben from anon, authenticated;

-- intern: Code -> Listen-ID
create or replace function public.zz_liste_id(p_code text)
returns uuid language sql stable security definer set search_path = public, extensions as $$
  select id from public.zz_listen
  where code_hash = encode(extensions.digest(coalesce(p_code, ''), 'sha256'), 'hex')
$$;
revoke execute on function public.zz_liste_id(text) from public, anon, authenticated;

-- neue Liste anlegen
create or replace function public.zz_anlegen(p_code text, p_namen jsonb)
returns boolean language plpgsql volatile security definer set search_path = public, extensions as $$
begin
  if p_code is null or length(p_code) < 24 then
    raise exception 'Code zu kurz';
  end if;
  insert into public.zz_listen(code_hash, namen)
  values (encode(extensions.digest(p_code, 'sha256'), 'hex'), coalesce(p_namen, '{}'::jsonb))
  on conflict (code_hash) do nothing;
  return true;
end $$;

-- alles laden
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
                          where t.liste = l and not t.geloescht), '[]'::jsonb)
  );
end $$;

-- Änderungen speichern (neuere Änderung gewinnt), danach alles zurückgeben
create or replace function public.zz_speichern(p_code text, p_anlaesse jsonb, p_aufgaben jsonb, p_namen jsonb default null)
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

  return public.zz_laden(p_code);
end $$;

revoke execute on function public.zz_anlegen(text, jsonb) from public;
revoke execute on function public.zz_laden(text) from public;
revoke execute on function public.zz_speichern(text, jsonb, jsonb, jsonb) from public;
grant execute on function public.zz_anlegen(text, jsonb) to anon, authenticated;
grant execute on function public.zz_laden(text) to anon, authenticated;
grant execute on function public.zz_speichern(text, jsonb, jsonb, jsonb) to anon, authenticated;
