import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "CKS Practice Labs",
  description:
    "Hands-on practice labs for Certified Kubernetes Security Specialist (CKS) exam preparation",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased min-h-screen">{children}</body>
    </html>
  );
}
