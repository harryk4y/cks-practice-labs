"use client";

import { useLabStore } from "@/store/labStore";
import { categories } from "@/data/labs";

const sectionLabels: Record<string, string> = {
  All: "All",
  lab: "Labs",
  mock: "Mock Exam",
};

export default function Sidebar() {
  const {
    currentLabIndex,
    setCurrentLabIndex,
    results,
    filterCategory,
    setFilterCategory,
    filterSection,
    setFilterSection,
    getFilteredLabs,
  } = useLabStore();

  const filteredLabs = getFilteredLabs();

  const getStatusIcon = (labId: number) => {
    const result = results[labId];
    if (!result) return "○";
    switch (result.status) {
      case "completed": return "✓";
      case "failed": return "✗";
      case "in-progress": return "◐";
      default: return "○";
    }
  };

  const getStatusColor = (labId: number) => {
    const result = results[labId];
    if (!result) return "text-dark-500";
    switch (result.status) {
      case "completed": return "text-emerald-400";
      case "failed": return "text-red-400";
      case "in-progress": return "text-amber-400";
      default: return "text-dark-500";
    }
  };

  return (
    <aside className="w-72 bg-dark-900 border-r border-dark-700 overflow-y-auto">
      <div className="p-4">
        {/* Section Filter */}
        <h2 className="text-sm font-semibold text-dark-300 uppercase tracking-wider mb-2">
          Section
        </h2>
        <div className="flex gap-2 mb-4">
          {Object.entries(sectionLabels).map(([key, label]) => (
            <button
              key={key}
              onClick={() => setFilterSection(key)}
              className={`px-3 py-1 text-xs rounded-full font-medium transition-colors ${
                filterSection === key
                  ? "bg-emerald-600 text-white"
                  : "bg-dark-800 text-dark-300 hover:bg-dark-700"
              }`}
            >
              {label}
            </button>
          ))}
        </div>

        {/* Category Filter */}
        <h2 className="text-sm font-semibold text-dark-300 uppercase tracking-wider mb-2">
          Category
        </h2>
        <div className="flex flex-wrap gap-2 mb-6">
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setFilterCategory(cat)}
              className={`px-3 py-1 text-xs rounded-full font-medium transition-colors ${
                filterCategory === cat
                  ? "bg-primary-600 text-white"
                  : "bg-dark-800 text-dark-300 hover:bg-dark-700"
              }`}
            >
              {cat}
            </button>
          ))}
        </div>

        {/* Lab List */}
        <h2 className="text-sm font-semibold text-dark-300 uppercase tracking-wider mb-3">
          Questions ({filteredLabs.length})
        </h2>
        <nav className="space-y-1">
          {filteredLabs.map((lab, index) => (
            <button
              key={lab.id}
              onClick={() => setCurrentLabIndex(index)}
              className={`w-full text-left px-3 py-2 rounded-lg transition-colors flex items-center gap-2 ${
                index === currentLabIndex
                  ? "bg-primary-600/20 border border-primary-600/50 text-white"
                  : "hover:bg-dark-800 text-dark-300"
              }`}
            >
              <span className={`text-lg ${getStatusColor(lab.id)}`}>
                {getStatusIcon(lab.id)}
              </span>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium truncate">
                  {lab.title}
                </p>
                <p className="text-xs text-dark-500">
                  {lab.weight} · {lab.difficulty}
                </p>
              </div>
            </button>
          ))}
        </nav>
      </div>
    </aside>
  );
}
