# EduTutors visual refresh

This update introduces a shared violet/lavender visual system across the app:
- Deep plum and violet primary palette
- Soft lavender page backgrounds and selected states
- Consistent rounded cards, buttons, inputs, chips, dialogs and navigation
- Updated shared hero/auth headers and reusable widgets
- Admin dashboard and all role-based screens inherit the same theme
- Existing repositories, Supabase calls, view models, routes and approval workflows are preserved

No backend schema or Supabase policy changes are included.

After extracting, run:
  flutter pub get
  flutter analyze
  flutter run -d edge

This is a shared visual-system pass. Individual page layouts and role navigation can be refined further after you review the refreshed app.
