# Moon generators

Templates in this folder:

## Apps
- `app-cloudflare-worker`
- `app-tanstack-start`
- `app-docs-site`

## Packages
- `pkg-go-cli`
- `pkg-ts-lib`
- `pkg-ts-lib-internal`

## Usage

```bash
moon templates
moon generate app-cloudflare-worker -- --name api_service --serviceName api-service
moon generate app-tanstack-start -- --name dashboard2 --title "Dashboard"
moon generate app-docs-site -- --name docs_site --title "Docs"
moon generate pkg-go-cli -- --name something2 --modulePath github.com/example/something2
moon generate pkg-ts-lib -- --name hello2 --npmScope @template --exportName hello
moon generate pkg-ts-lib-internal -- --name counter2 --npmScope @template --exportName inc
```
