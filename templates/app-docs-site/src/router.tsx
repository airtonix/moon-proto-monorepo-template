import { Link, Outlet, createRootRoute, createRoute, createRouter } from '@tanstack/react-router'

const rootRoute = createRootRoute({
  component: () => (
    <div className="layout">
      <header>
        <h1>{{ title }}</h1>
        <p>Minimal static docs scaffold.</p>
        <nav>
          <Link to="/">Home</Link>
          <Link to="/getting-started">Getting started</Link>
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
  component: () => <section><h2>Welcome</h2><p>Generated with moon template <code>app-docs-site</code>.</p></section>,
})

const gettingStartedRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: '/getting-started',
  component: () => <section><h2>Getting started</h2><p>Run <code>moon run {{ name }}:build</code>.</p></section>,
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
