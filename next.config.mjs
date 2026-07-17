/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "standalone",
  async rewrites() {
    return [
      {
        // Proxy terminal WebSocket + HTTP to workspace pod
        source: "/terminal/:path*",
        destination:
          process.env.WORKSPACE_URL ||
          "http://workspace.cks-workspace.svc.cluster.local:7681/:path*",
      },
    ];
  },
};

export default nextConfig;
