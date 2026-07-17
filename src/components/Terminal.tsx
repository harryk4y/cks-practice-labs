"use client";

import { useState } from "react";

interface TerminalProps {
  isOpen: boolean;
  onToggle: () => void;
}

export default function Terminal({ isOpen, onToggle }: TerminalProps) {
  const [terminalUrl] = useState(
    typeof window !== "undefined" && window.location.port === "3001"
      ? "http://localhost:7681/terminal/"
      : "/terminal/"
  );

  if (!isOpen) {
    return (
      <button
        onClick={onToggle}
        className="fixed bottom-4 right-4 btn-primary shadow-lg z-50 flex items-center gap-2"
      >
        <span className="font-mono text-sm">⌨</span> Terminal
      </button>
    );
  }

  return (
    <div className="fixed bottom-0 left-72 right-0 z-40 flex flex-col bg-dark-950 border-t border-dark-700">
      {/* Terminal Header */}
      <div className="flex items-center justify-between px-4 py-2 bg-dark-900 border-b border-dark-700">
        <div className="flex items-center gap-3">
          <div className="flex gap-1.5">
            <span className="w-3 h-3 rounded-full bg-red-500" />
            <span className="w-3 h-3 rounded-full bg-amber-500" />
            <span className="w-3 h-3 rounded-full bg-emerald-500" />
          </div>
          <span className="text-sm font-mono text-dark-300">
            cks-workspace
          </span>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-xs text-dark-500">
            ttyd • workspace pod
          </span>
          <button
            onClick={onToggle}
            className="text-dark-400 hover:text-white text-sm px-2 py-1 rounded hover:bg-dark-700"
          >
            ✕
          </button>
        </div>
      </div>

      {/* Terminal iframe */}
      <div className="h-80">
        <iframe
          src={terminalUrl}
          className="w-full h-full border-0 bg-black"
          title="CKS Workspace Terminal"
          allow="clipboard-read; clipboard-write"
        />
      </div>
    </div>
  );
}
