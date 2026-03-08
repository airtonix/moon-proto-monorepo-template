# docs_site

Minimal static docs application scaffold using Vite + React + TanStack Router.

## Local development

```bash
bun --cwd apps/docs_site install
moon run docs-site:build
moon run docs-site:package
```

## Publish contract

- `build`: produces deterministic static output in `dist/`
- `package`: stages Pages artifact at `.artifacts/github-pages/`
- `publish`: runs package and leaves staged artifact for deploy/upload

## GitHub Pages URL

- Expected URL: `https://airtonix.github.io/moon-proto-monorepo-template/`
