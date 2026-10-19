# sveinnarnorsson.com

Personal site. Plain static HTML, no build step.

- `index.html` – home page
- `training-plan/index.html` – VO₂ max training plan
- `agenda/index.html` – conference session plan (not linked from the home page)
- `CNAME` – custom domain

Pushing to `main` runs `.github/workflows/deploy.yml`, which copies these files to the `gh-pages` branch that GitHub Pages serves.

Preview locally with `python3 -m http.server`.
