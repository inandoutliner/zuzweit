-- Zu zweit 1006: Kurzbefehl speichert Orte aus Google Maps direkt (ohne Safari).
-- Einmal im Supabase SQL Editor ausführen (nach supabase-google.sql). Kann mehrfach laufen.
create or replace function public.zz_ort_aus_google(p_text text, p_notiz text default null)
returns text language plpgsql volatile security definer set search_path = public, extensions as $$
declare
  t text := coalesce(p_text, '');
  c text; ich text; l uuid; url text; voll text; s text; name text; q text;
  m text[]; lat double precision; lng double precision; r extensions.http_response; j jsonb;
begin
  c := (regexp_match(t, 'k=([A-Za-z0-9_-]{24,})'))[1];
  ich := coalesce((regexp_match(t, 'ich=([ab])'))[1], 'a');
  l := public.zz_liste_id(c);
  if l is null then return 'Zu zweit: Liste unbekannt. Kurzbefehl-Text neu kopieren.'; end if;
  t := regexp_replace(t, '#?k=[A-Za-z0-9_-]+&?(ich=[ab])?', '');
  url := (regexp_match(t, '(https?://[^\s<>"]+)'))[1];
  name := btrim((regexp_match(btrim(replace(t, coalesce(url, ''), '')), '^([^\n]+)'))[1]);

  if url is not null then
    voll := public.zz_link_aufloesen(c, url);
    s := replace(replace(replace(voll, '%2C', ','), '%2c', ','), '+', ' ');
    m := regexp_match(s, '!3d(-?[0-9.]+)!4d(-?[0-9.]+)');
    if m is null then m := regexp_match(s, '[?&](?:q|query|ll|center|daddr|destination)=(-?[0-9.]+),\s*(-?[0-9.]+)'); end if;
    if m is null then m := regexp_match(s, '/(?:search|place)/(-?[0-9.]+),\s*(-?[0-9.]+)'); end if;
    if m is null then m := regexp_match(s, '@(-?[0-9.]+),(-?[0-9.]+)'); end if;
    if m is not null then lat := m[1]::double precision; lng := m[2]::double precision; end if;
    if name is null or name = '' then
      name := btrim(replace((regexp_match(voll, '/place/([^/@?]+)'))[1], '+', ' '));
      begin name := convert_from(decode(replace(replace(name, '%', ''), ' ', '20'), 'hex'), 'UTF8'); exception when others then null; end;
    end if;
    q := btrim((regexp_match(s, '[?&](?:q|query)=([^&]+)'))[1]);
  end if;

  if lat is null then
    q := coalesce(nullif(q, ''), nullif(name, ''), nullif(btrim(t), ''));
    if q is not null then
      begin
        r := extensions.http(('GET', 'https://nominatim.openstreetmap.org/search?format=jsonv2&limit=1&countrycodes=nz&q=' || extensions.urlencode(q),
               array[extensions.http_header('User-Agent', 'zuzweit/1.0 (inandoutliner.github.io/zuzweit)')], null, null)::extensions.http_request);
        j := r.content::jsonb;
        if jsonb_array_length(j) > 0 then
          lat := (j->0->>'lat')::double precision; lng := (j->0->>'lon')::double precision;
          name := coalesce(nullif(name, ''), j->0->>'name', q);
        end if;
      exception when others then null; end;
    end if;
  end if;

  if lat is null then return 'Zu zweit: Ort nicht erkannt. Link in der App ins Suchfeld einfügen.'; end if;
  if not (lat between -53 and -28 and lng between 160 and 185) then return 'Zu zweit: Dieser Ort liegt nicht in Neuseeland.'; end if;
  name := coalesce(nullif(name, ''), 'Ort aus Google Maps');

  insert into public.zz_orte (id, liste, name, notiz, lat, lng, link, von, erstellt, geaendert)
  values (gen_random_uuid(), l, left(name, 120), nullif(left(btrim(coalesce(p_notiz, '')), 1000), ''), lat, lng,
          case when voll ~* '^https://www\.google\.[a-z.]+/maps/' then left(voll, 2000) else url end, ich, now(), now());
  return 'Gespeichert in Zu zweit: ' || name;
end $$;

revoke execute on function public.zz_ort_aus_google(text, text) from public;
grant execute on function public.zz_ort_aus_google(text, text) to anon, authenticated;
notify pgrst, 'reload schema';
