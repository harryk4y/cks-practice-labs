import { create } from "zustand";
import { labs, Lab } from "@/data/labs";

export type LabStatus = "not-started" | "in-progress" | "completed" | "failed";

interface LabResult {
  labId: number;
  status: LabStatus;
  score: number;
  completedAt?: string;
  attempts: number;
}

interface LabStore {
  currentLabIndex: number;
  results: Record<number, LabResult>;
  showSolution: Record<number, boolean>;
  showHints: Record<number, boolean>;
  filterCategory: string;
  filterSection: string;

  setCurrentLabIndex: (index: number) => void;
  nextLab: () => void;
  prevLab: () => void;
  markLabStatus: (labId: number, status: LabStatus, score?: number) => void;
  toggleSolution: (labId: number) => void;
  toggleHints: (labId: number) => void;
  setFilterCategory: (category: string) => void;
  setFilterSection: (section: string) => void;
  getFilteredLabs: () => Lab[];
  getTotalScore: () => { completed: number; total: number; percentage: number };
  resetAll: () => void;
}

export const useLabStore = create<LabStore>((set, get) => ({
  currentLabIndex: 0,
  results: {},
  showSolution: {},
  showHints: {},
  filterCategory: "All",
  filterSection: "All",

  setCurrentLabIndex: (index) => set({ currentLabIndex: index }),

  nextLab: () => {
    const filtered = get().getFilteredLabs();
    const current = get().currentLabIndex;
    if (current < filtered.length - 1) {
      set({ currentLabIndex: current + 1 });
    }
  },

  prevLab: () => {
    const current = get().currentLabIndex;
    if (current > 0) {
      set({ currentLabIndex: current - 1 });
    }
  },

  markLabStatus: (labId, status, score = 0) =>
    set((state) => ({
      results: {
        ...state.results,
        [labId]: {
          labId,
          status,
          score,
          completedAt:
            status === "completed" ? new Date().toISOString() : undefined,
          attempts: (state.results[labId]?.attempts || 0) + 1,
        },
      },
    })),

  toggleSolution: (labId) =>
    set((state) => ({
      showSolution: {
        ...state.showSolution,
        [labId]: !state.showSolution[labId],
      },
    })),

  toggleHints: (labId) =>
    set((state) => ({
      showHints: {
        ...state.showHints,
        [labId]: !state.showHints[labId],
      },
    })),

  setFilterCategory: (category) =>
    set({ filterCategory: category, currentLabIndex: 0 }),

  setFilterSection: (section) =>
    set({ filterSection: section, currentLabIndex: 0 }),

  getFilteredLabs: () => {
    const { filterCategory, filterSection } = get();
    let filtered = labs;
    if (filterSection !== "All") {
      filtered = filtered.filter((lab) => lab.section === filterSection);
    }
    if (filterCategory !== "All") {
      filtered = filtered.filter((lab) => lab.category === filterCategory);
    }
    return filtered;
  },

  getTotalScore: () => {
    const { results } = get();
    const completed = Object.values(results).filter(
      (r) => r.status === "completed"
    ).length;
    const total = labs.length;
    const percentage =
      total > 0 ? Math.round((completed / total) * 100) : 0;
    return { completed, total, percentage };
  },

  resetAll: () =>
    set({
      results: {},
      showSolution: {},
      showHints: {},
      currentLabIndex: 0,
    }),
}));
