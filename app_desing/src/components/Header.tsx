import React from 'react';
import { ActiveScreen } from '../types';

interface HeaderProps {
  activeScreen: ActiveScreen;
  onNavigate: (screen: ActiveScreen) => void;
  onBack?: () => void;
  activeCount: number;
}

export const Header: React.FC<HeaderProps> = ({
  activeScreen,
  onNavigate,
  onBack,
  activeCount,
}) => {
  const isProtected = activeCount > 0;
  const isTotal = activeCount === 3;

  if (activeScreen === 'detail') {
    return (
      <header className="sticky top-0 w-full z-40 bg-[#0f131b]/90 backdrop-blur-xl border-b border-[#3b494c]/30 shadow-sm">
        <div className="h-16 px-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <button
              onClick={onBack}
              aria-label="Volver"
              className="min-w-[44px] min-h-[44px] -ml-2 px-2 flex items-center gap-1 text-[#bac9cc] hover:text-[#c3f5ff] active:scale-95 transition-all cursor-pointer"
            >
              <span className="material-symbols-outlined text-[20px]">arrow_back_ios_new</span>
              <span className="font-mono text-[12px] tracking-wide font-medium">Volver</span>
            </button>
            <h1 className="font-headline text-[17px] font-semibold text-[#dfe2ed] tracking-tight truncate max-w-[200px]">
              Detalle De Registro
            </h1>
          </div>
          <button
            onClick={() => onNavigate('login')}
            aria-label="Perfil de usuario"
            className="w-8 h-8 rounded-full bg-[#c3f5ff] flex items-center justify-center hover:opacity-90 active:scale-95 transition-all cursor-pointer"
          >
            <span className="material-symbols-outlined text-[#00363d] text-[18px]">person</span>
          </button>
        </div>
      </header>
    );
  }

  if (activeScreen === 'login' || activeScreen === 'register') {
    return (
      <header className="sticky top-0 w-full z-40 bg-[#0f131b]/80 backdrop-blur-xl border-b border-[#3b494c]/20">
        <div className="h-14 px-4 flex items-center justify-between">
          <button
            onClick={() => onNavigate('shield')}
            className="flex items-center gap-1.5 text-xs text-[#bac9cc] hover:text-[#c3f5ff] active:scale-95 transition-all cursor-pointer py-1.5 px-2.5 rounded-lg bg-[#181c23]/80 border border-[#3b494c]/30"
          >
            <span className="material-symbols-outlined text-[16px]">arrow_back</span>
            <span>Volver al Escudo</span>
          </button>
          <div className="flex items-center gap-2 text-xs font-mono text-[#7dffa2]">
            <span className="w-2 h-2 rounded-full bg-[#7dffa2] animate-pulse"></span>
            <span>ENCLAVE SEGURO</span>
          </div>
        </div>
      </header>
    );
  }

  return (
    <header className="sticky top-0 w-full z-40 bg-[#0f131b]/85 backdrop-blur-xl border-b border-[#3b494c]/20 shadow-[0_1px_8px_rgba(0,0,0,0.15)]">
      <div className="h-16 px-4 flex items-center justify-between max-w-2xl mx-auto">
        <div className="flex items-center gap-2.5">
          <div
            className={`w-2.5 h-2.5 rounded-full transition-colors duration-500 ${
              isTotal
                ? 'bg-[#7dffa2] shadow-[0_0_8px_#00e475]'
                : isProtected
                ? 'bg-[#f59e0b] shadow-[0_0_8px_#f59e0b]'
                : 'bg-[#ffb4ab] shadow-[0_0_8px_#ff5449]'
            }`}
          ></div>
          <div className="flex flex-col">
            <span className="font-headline text-[17px] font-semibold text-[#dfe2ed] leading-tight">
              Shield Dashboard
            </span>
            <span
              className={`font-mono text-[10px] tracking-wider uppercase font-medium transition-colors duration-500 ${
                isTotal
                  ? 'text-[#7dffa2]'
                  : isProtected
                  ? 'text-[#f59e0b]'
                  : 'text-[#ffb4ab]'
              }`}
            >
              {isTotal ? 'Blindaje Activo' : isProtected ? 'Blindaje Parcial' : 'Blindaje Desactivado'}
            </span>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {/* Quick simulator button in header for easy demonstration */}
          <button
            onClick={() => onNavigate('simulator')}
            title="Abrir Simulador de llamadas y SMS en tiempo real"
            className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-[#1c2027] hover:bg-[#262a32] text-[#c3f5ff] text-[11px] font-mono border border-[#00daf3]/30 transition-all cursor-pointer active:scale-95"
          >
            <span className="w-1.5 h-1.5 rounded-full bg-[#00e5ff] animate-ping"></span>
            <span className="material-symbols-outlined text-[14px]">sensors</span>
            <span className="hidden sm:inline">Simulador</span>
          </button>

          <button
            onClick={() => onNavigate('login')}
            aria-label="Abrir Perfil o Acceso Seguro"
            className="w-8 h-8 rounded-full bg-[#c3f5ff] flex items-center justify-center hover:opacity-90 active:scale-95 transition-all cursor-pointer shadow-sm"
          >
            <span className="material-symbols-outlined text-[#00363d] text-[18px]">person</span>
          </button>
        </div>
      </div>
    </header>
  );
};
