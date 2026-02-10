import type { Metadata } from "next"
import Sidebar from "@/components/Sidebar"
import "./globals.css"

export const metadata: Metadata = {
  title: "Beacon Dashboard",
  description: "Analytics dashboard for Beacon event tracking",
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="en">
      <body>
        <Sidebar />
        <main className="ml-56 min-h-screen p-8">{children}</main>
      </body>
    </html>
  )
}
