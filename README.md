# sveinnarnorsson.com

Personal site. Plain static HTML, no build step.

- `index.html` – home page
- `training-plan/index.html` – VO₂ max training plan
- `warsaw2026/index.html` – .NET DeveloperDays programme with personal agendas (not linked from the home page)
- `CNAME` – custom domain

Pushing to `main` runs `.github/workflows/deploy.yml`, which copies these files to the `gh-pages` branch that GitHub Pages serves.

Preview locally with `python3 -m http.server`.

## Cloud sync for /warsaw2026/

Picks, ratings and photos are saved on the device first. If `SUPABASE_URL` and `SUPABASE_KEY` are set near the bottom of `warsaw2026/index.html`, people on the allow-list can sign in with an email code to back them up and sync them across devices. `supabase/setup.sql` creates the tables (picks, ratings, photos), the private photo bucket and the access policies; it is not deployed with the site.
