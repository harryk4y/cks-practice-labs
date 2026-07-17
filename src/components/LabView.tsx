"use client";

import { useLabStore } from "@/store/labStore";

interface LabViewProps {
  onOpenTerminal?: () => void;
}

export default function LabView({ onOpenTerminal }: LabViewProps) {
  const {
    currentLabIndex,
    nextLab,
    prevLab,
    markLabStatus,
    toggleSolution,
    toggleHints,
    showSolution,
    showHints,
    results,
    getFilteredLabs,
  } = useLabStore();

  const filteredLabs = getFilteredLabs();
  const lab = filteredLabs[currentLabIndex];

  if (!lab) {
    return (
      <div className="flex-1 flex items-center justify-center">
        <p className="text-dark-400">
          No labs available for this category.
        </p>
      </div>
    );
  }

  const result = results[lab.id];
  const solutionVisible = showSolution[lab.id] || false;
  const hintsVisible = showHints[lab.id] || false;

  const difficultyColor = {
    Easy: "bg-emerald-600/20 text-emerald-400 border-emerald-600/30",
    Medium: "bg-amber-600/20 text-amber-400 border-amber-600/30",
    Hard: "bg-red-600/20 text-red-400 border-red-600/30",
  };

  return (
    <main className="flex-1 overflow-y-auto">
      <div className="max-w-4xl mx-auto p-6 space-y-6">
        {/* Lab Header */}
        <div className="card">
          <div className="flex items-start justify-between mb-4">
            <div>
              <div className="flex items-center gap-3 mb-2">
                <span className="text-sm font-mono text-dark-400">
                  Q{lab.id} of {filteredLabs.length}
                </span>
                <span
                  className={`px-2 py-0.5 text-xs rounded-full border ${
                    difficultyColor[lab.difficulty]
                  }`}
                >
                  {lab.difficulty}
                </span>
                <span className="px-2 py-0.5 text-xs rounded-full bg-primary-600/20 text-primary-400 border border-primary-600/30">
                  {lab.category}
                </span>
              </div>
              <h2 className="text-2xl font-bold text-white">
                {lab.title}
              </h2>
            </div>
            {result && (
              <span
                className={`px-3 py-1 text-sm rounded-full font-medium ${
                  result.status === "completed"
                    ? "bg-emerald-600/20 text-emerald-400"
                    : result.status === "failed"
                    ? "bg-red-600/20 text-red-400"
                    : "bg-amber-600/20 text-amber-400"
                }`}
              >
                {result.status === "completed"
                  ? "✓ Passed"
                  : result.status === "failed"
                  ? "✗ Failed"
                  : "◐ In Progress"}
              </span>
            )}
          </div>
          <p className="text-dark-300">{lab.description}</p>
          <div className="mt-3 flex gap-4 text-xs">
            <span className="code-block py-1 px-2">
              <span className="text-primary-400">weight:</span> {lab.weight}
            </span>
            <span className="code-block py-1 px-2">
              <span className="text-primary-400">cluster:</span> {lab.cluster}
            </span>
            <span className="code-block py-1 px-2">
              <span className="text-primary-400">type:</span> {lab.section}
            </span>
          </div>
          {/* Start Lab Button */}
          <div className="mt-4 flex gap-3">
            <button
              onClick={() => {
                onOpenTerminal?.();
                // The terminal will show — user runs setup-lab command
              }}
              className="btn-primary flex items-center gap-2"
            >
              <span className="font-mono text-sm">▶</span> Start Lab (Open
              Terminal)
            </button>
            <span className="text-xs text-dark-500 self-center">
              Run <code className="text-primary-400">setup-lab {lab.id}</code>{" "}
              in terminal to initialize
            </span>
          </div>
        </div>

        {/* Requirements */}
        <div className="card">
          <h3 className="text-lg font-semibold text-white mb-3">
            🎯 Requirements
          </h3>
          <ol className="space-y-2">
            {lab.requirements.map((req, i) => (
              <li key={i} className="flex items-start gap-3">
                <span className="mt-0.5 w-6 h-6 rounded-full bg-primary-600/20 border border-primary-600/40 flex items-center justify-center text-xs text-primary-400 shrink-0 font-mono">
                  {i + 1}
                </span>
                <span className="text-dark-200 text-sm">{req}</span>
              </li>
            ))}
          </ol>
        </div>

        {/* Hints (collapsible) */}
        <div className="card">
          <button
            onClick={() => toggleHints(lab.id)}
            className="w-full flex items-center justify-between"
          >
            <h3 className="text-lg font-semibold text-white">
              💡 Hints
            </h3>
            <span className="text-sm text-dark-400">
              {hintsVisible ? "Hide" : "Show"}
            </span>
          </button>
          {hintsVisible && (
            <ul className="mt-4 space-y-2">
              {lab.hints.map((hint, i) => (
                <li
                  key={i}
                  className="flex items-start gap-2 text-sm text-dark-300"
                >
                  <span className="text-amber-400">→</span>
                  {hint}
                </li>
              ))}
            </ul>
          )}
        </div>

        {/* Verification Checks */}
        <div className="card">
          <h3 className="text-lg font-semibold text-white mb-3">
            ✅ Verification Checks
          </h3>
          <p className="text-xs text-dark-400 mb-3">
            These checks are run by <code>verify.sh</code> to validate
            your solution:
          </p>
          <ul className="space-y-2">
            {lab.verificationChecks.map((check, i) => (
              <li
                key={i}
                className="flex items-center gap-2 text-sm text-dark-300"
              >
                <span
                  className={`w-4 h-4 rounded-sm border flex items-center justify-center text-xs ${
                    result?.status === "completed"
                      ? "bg-emerald-600/30 border-emerald-500 text-emerald-400"
                      : result?.status === "failed"
                      ? "bg-red-600/30 border-red-500 text-red-400"
                      : "border-dark-600 text-dark-500"
                  }`}
                >
                  {result?.status === "completed"
                    ? "✓"
                    : result?.status === "failed"
                    ? "✗"
                    : ""}
                </span>
                {check}
              </li>
            ))}
          </ul>
        </div>

        {/* Solution (collapsible) */}
        <div className="card">
          <button
            onClick={() => toggleSolution(lab.id)}
            className="w-full flex items-center justify-between"
          >
            <h3 className="text-lg font-semibold text-white">
              {solutionVisible ? "🔓" : "🔒"} Answer / Solution
            </h3>
            <span className="text-sm text-dark-400">
              {solutionVisible ? "Hide" : "Reveal"}
            </span>
          </button>
          {solutionVisible && (
            <div className="mt-4">
              <pre className="code-block whitespace-pre-wrap text-emerald-300 text-xs leading-relaxed">
                {lab.solution}
              </pre>
            </div>
          )}
        </div>

        {/* Navigation & Action Buttons */}
        <div className="flex items-center justify-between pt-4 border-t border-dark-700">
          <button
            onClick={prevLab}
            disabled={currentLabIndex === 0}
            className="btn-secondary flex items-center gap-2"
          >
            ← Previous
          </button>

          <div className="flex gap-3">
            <button
              onClick={() => markLabStatus(lab.id, "in-progress")}
              className="btn-warning"
            >
              ◐ In Progress
            </button>
            <button
              onClick={() => markLabStatus(lab.id, "completed", 100)}
              className="btn-success"
            >
              ✓ Mark Passed
            </button>
            <button
              onClick={() => markLabStatus(lab.id, "failed")}
              className="btn-secondary border-red-600/50 text-red-400 hover:bg-red-600/10"
            >
              ✗ Mark Failed
            </button>
          </div>

          <button
            onClick={nextLab}
            disabled={currentLabIndex === filteredLabs.length - 1}
            className="btn-primary flex items-center gap-2"
          >
            Next →
          </button>
        </div>
      </div>
    </main>
  );
}
