import { Link, createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/about')({ component: About })

function About() {
  return (
    <main className="page">
      <h1>About {{ title }}</h1>
      <p>This starter is intentionally minimal.</p>
      <p><Link to="/">Back home</Link></p>
    </main>
  )
}
