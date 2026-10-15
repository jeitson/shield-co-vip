import React from 'react';
import { ActiveScreen } from '../types';

interface BottomNavProps {
  activeScreen: ActiveScreen;
  onNavigate: (screen: ActiveScreen) => void;
}

export const BottomNav: React.FC<BottomNavProps> = ({ activeScreen, onNavigate }) => {
  // If in login, register, or detail view, we can either hide or keep accessible.
  // In the mockups, detail has back button and no bottom nav, login/register has no bottom nav.
  if (activeScreen === 'login' || activeScreen === 'register' || activeScreen === 'detail') {
    return null;
  }

  const navItems: { id: ActiveScreen; label: string; icon: string }[] = [
    { id: 'shield', label: 'Escudo', icon: 'shield' },
    { id: 'calls', label: 'Llamadas', icon: 'call' },
    { id: 'report', label: 'Denunciar', icon: 'report' },
    { id: 'advanced', label: 'Avanzados', icon: 'tune' },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-40 bg-[#0f131b]/90 backdrop-blur-xl border-t border-[#3b494c]/20 shadow-[0_-1px_12px_rgba(0,0,0,0.3)]">
      <div className="flex justify-around items-center h-16 max-w-2xl mx-auto px-4">
        {navItems.map((item) => {
          const isActive = activeScreen === item.id;
          return (
            <button
              key={item.id}
              onClick={() => onNavigate(item.id)}
              className={`flex flex-col items-center justify-center min-w-[54px] min-h-[48px] py-1 px-2 rounded-xl transition-all duration-200 cursor-pointer active:scale-95 ${
                isActive
                  ? 'text-[#00e5ff] font-semibold'
                  : 'text-[#bac9cc] hover:text-[#dfe2ed]'
              }`}
            >
              <span
                className="material-symbols-outlined text-[22px] transition-transform duration-200"
                style={isActive ? { fontVariationSettings: "'FILL' 1" } : undefined}
              >
                {item.icon}
              </span>
              <span className="font-mono text-[10px] tracking-wide mt-0.5">
                {item.label}
              </span>
              {isActive && (
                <span className="w-1 h-1 rounded-full bg-[#00e5ff] shadow-[0_0_6px_#00e5ff] mt-0.5"></span>
              )}
            </button>
          );
        })}
      </div>
    </nav>
  );
};
