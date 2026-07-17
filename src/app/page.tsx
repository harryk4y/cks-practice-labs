"use client";

import { useState } from "react";
import Header from "@/components/Header";
import Sidebar from "@/components/Sidebar";
import LabView from "@/components/LabView";
import Terminal from "@/components/Terminal";

export default function Home() {
  const [terminalOpen, setTerminalOpen] = useState(false);

  return (
    <div className="h-screen flex flex-col">
      <Header />
      <div className="flex flex-1 overflow-hidden">
        <Sidebar />
        <div className={`flex-1 flex flex-col ${terminalOpen ? "pb-80" : ""}`}>
          <LabView onOpenTerminal={() => setTerminalOpen(true)} />
        </div>
      </div>
      <Terminal
        isOpen={terminalOpen}
        onToggle={() => setTerminalOpen(!terminalOpen)}
      />
    </div>
  );
}
