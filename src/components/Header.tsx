"use client";

import { useLabStore } from "@/store/labStore";

export default function Header() {
  const { getTotalScore } = useLabStore();
  const score = getTotalScore();

  return (
    <header className="bg-dark-900 border-b border-dark-700 px-6 py-4">
      <div className="max-w-7xl mx-auto flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-primary-600 rounded-lg flex items-center justify-center">
            <span className="text-white font-bold text-lg">CKS</span>
          </div>
          <div>
            <h1 className="text-xl font-bold text-white">
              CKS Practice Labs
            </h1>
            <p className="text-sm text-dark-400">
              Labs + Mock Exam - CKS Learning Platform
            </p>
          </div>
        </div>

        <div className="flex items-center gap-6">
          <div className="text-center">
            <p className="text-2xl font-bold text-primary-400">
              {score.percentage}%
            </p>
            <p className="text-xs text-dark-400">Overall</p>
          </div>
          <div className="text-center">
            <p className="text-2xl font-bold text-emerald-400">
              {score.completed}/{score.total}
            </p>
            <p className="text-xs text-dark-400">Completed</p>
          </div>
        </div>
      </div>
    </header>
  );
}
