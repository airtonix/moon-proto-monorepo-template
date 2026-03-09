export interface Env {
  SERVICE_NAME?: string;
  DEPLOY_ENV?: string;
  BUILD_TAG?: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (url.pathname === "/health") {
      return Response.json({
        ok: true,
        service: env.SERVICE_NAME ?? "{{ serviceName }}",
        environment: env.DEPLOY_ENV ?? "unknown",
        tag: env.BUILD_TAG ?? "dev",
        timestamp: new Date().toISOString(),
      });
    }

    return new Response("Not Found", { status: 404 });
  },
};
