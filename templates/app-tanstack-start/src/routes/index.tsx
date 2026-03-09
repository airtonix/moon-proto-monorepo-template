import { Link, createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/')({ component: Home })

function Home() {
  return (
    <main className="page">
      <h1>{{ title }}</h1>
      <p>Generated with moon template <code>app-tanstack-start</code>.</p>
      <p><Link to="/about">About</Link></p>
    </main>
  )
}
