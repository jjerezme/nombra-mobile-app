# Gitflow

- `master`: producción. `develop`: integración.
- `feature/*` y `bugfix/*` salen de `develop` y vuelven a `develop`.
- `release/*` sale de `develop` y va a `master`.
- `hotfix/*` sale de `master` y va a `master` y `develop`.
- Commits: Conventional Commits en inglés (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`).
- Un PR pequeño por rama. CI en verde antes de fusionar.
- Protección de ramas: la activa el propietario del repo en GitHub.
