# CCR : dossier final

## 1. Base de données (Supabase > SQL Editor, dans cet ordre)
1. `supabase_schema.sql`
2. `supabase/migrations/20261117000000_consolidated.sql`
3. `supabase/migrations/20261120000000_youtube_import.sql`, puis `supabase/migrations/20261121000000_church_features.sql` et `supabase/rls_tests_v3.sql` (doit afficher TESTS V3 OK), puis `supabase/migrations/20261122000000_series_and_english.sql`
4. `supabase/rls_tests_v2.sql` (doit afficher TESTS OK)
5. Admin : `insert into admins (user_id) select id from auth.users where email = 'ton@email.com';`

## 2. Import YouTube automatique
Suis `docs/YOUTUBE_SYNC.md` (secrets, déploiement de la fonction, cron).

## 3. Application
`flutter pub get && flutter analyze && flutter test`
`flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxx`
Android : permissions INTERNET, WAKE_LOCK, FOREGROUND_SERVICE, FOREGROUND_SERVICE_MEDIA_PLAYBACK, `<queries>` https, service et récepteur audio_service, `AudioServiceActivity`, minSdk 23.

## 4. Dans l'app
Plus > Langue ; Plus > Espace administrateur : messages, témoignages, vidéos, directs, annonces, souffle du jour, import YouTube.

Docs : `docs/BACKEND.md`, `docs/DB_CONTRACT.md`, `docs/YOUTUBE_SYNC.md`.

## Tester dans Chrome (avec ton Supabase)
```
flutter config --enable-web
flutter create . --platforms=web        # seulement si le dossier web/ n'existe pas
flutter pub get
flutter run -d chrome --dart-define=SUPABASE_URL=https://TON-PROJET.supabase.co --dart-define=SUPABASE_ANON_KEY=TA-CLE-ANON
```
Version à héberger : `flutter build web --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` (dossier `build/web`).
Sur le web : pas de lecture audio en arrière-plan ni de notification de verrouillage (réservé à Android/iOS). Tout le reste (contenu, admin, directs, Souffle du jour, langues, vidéos) fonctionne.

## Icône de l'app
`dart run flutter_launcher_icons` (utilise `assets/ccr_logo.png`). Pour Android, un logo avec des marges autour rend mieux dans l'icône ronde.
