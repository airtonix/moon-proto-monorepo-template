import {
  Link,
  Outlet,
  createRootRoute,
  createRoute,
  createRouter,
} from '@tanstack/react-router'

const rootRoute = createRootRoute({
  component: () => (
    <div className="layout">
      <header>
        <h1>docs_site</h1>
        <p>Minimal TanStack static-style docs scaffold.</p>
        <nav>
          <Link to="/" activeProps={{ className: 'active' }}>
            Home
          </Link>
          <Link to="/getting-started" activeProps={{ className: 'active' }}>
            Getting started
          </Link>
        </nav>
      </header>
      <main>
        <Outlet />
      </main>
    </div>
  ),
})

const indexRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/',
  component: () => (
    <section>
      <h2>Welcome</h2>
      <p>
        This static site is built with Vite + React + TanStack Router and emits a
        deterministic <code>dist/</code> directory.
      </p>
    </section>
  ),
})

const gettingStartedRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/getting-started',
  component: () => (
    <section>
      <h2>Getting started</h2>
      <ol>
        <li>Run <code>bun --cwd apps/docs_site install</code>.</li>
        <li>Run <code>moon run docs-site:build</code>.</li>
        <li>Run <code>moon run docs-site:package</code>.</li>
      </ol>
    </section>
  ),
})

const routeTree = rootRoute.addChildren([indexRoute, gettingStartedRoute])

export const router = createRouter({
  routeTree,
  basepath: import.meta.env.BASE_URL,
})

declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router
  }
}
