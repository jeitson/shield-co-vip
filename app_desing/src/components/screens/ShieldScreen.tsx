import React, { useState } from 'react';
import { ShieldConfig } from '../../types';

interface ShieldScreenProps {
  config: ShieldConfig;
  onToggle: (key: keyof ShieldConfig) => void;
  onNavigateToSimulator: () => void;
}

export const ShieldScreen: React.FC<ShieldScreenProps> = ({
  config,
  onToggle,
  onNavigateToSimulator,
}) => {
  const [syncing, setSyncing] = useState(false);
  const [lastSyncTime, setLastSyncTime] = useState('Hoy, 04:12');
  const [hashCount, setHashCount] = useState(14892);

  const activeCount = Object.values(config).filter(Boolean).length;
  const isTotal = activeCount === 3;
  const isPartial = activeCount > 0 && activeCount < 3;
  const isRisk = activeCount === 0;

  const handleManualSync = () => {
    setSyncing(true);
    setTimeout(() => {
      setSyncing(false);
      const now = new Date();
      const timeStr = `Hoy, ${now.getHours().toString().padStart(2, '0')}:${now
        .getMinutes()
        .toString()
        .padStart(2, '0')}`;
      setLastSyncTime(timeStr);
      setHashCount((prev) => prev + Math.floor(Math.random() * 15) + 3);
    }, 1200);
  };

  return (
    <div className="flex flex-col w-full gap-4 pb-24 max-w-2xl mx-auto animate-fadeIn">
      {/* Status Header Bar */}
      <div className="flex items-center justify-between px-4 py-2.5 rounded-xl bg-[#1c2027] shadow-sm border border-[#3b494c]/20">
        <div className="flex items-center gap-2.5">
          <div
            className={`w-2.5 h-2.5 rounded-full transition-colors duration-500 ${
              isTotal
                ? 'bg-[#7dffa2] shadow-[0_0_10px_#7dffa2]'
                : isPartial
                ? 'bg-[#f59e0b] shadow-[0_0_10px_#f59e0b]'
                : 'bg-[#ffb4ab] shadow-[0_0_10px_#ffb4ab]'
            }`}
          ></div>
          <span className="font-mono text-[11px] tracking-wider uppercase text-[#bac9cc] font-medium">
            Filtro Zero-Knowledge
          </span>
        </div>

        <div className="flex items-center gap-1.5 bg-[#262a32] px-2.5 py-1 rounded-full border border-[#3b494c]/40">
          <span
            className={`material-symbols-outlined text-[14px] transition-colors duration-500 ${
              isTotal
                ? 'text-[#7dffa2]'
                : isPartial
                ? 'text-[#f59e0b]'
                : 'text-[#ffb4ab]'
            }`}
          >
            {isTotal ? 'lock' : isPartial ? 'shield_with_heart' : 'warning'}
          </span>
          <span
            className={`font-mono text-[10px] font-semibold tracking-wide transition-colors duration-500 ${
              isTotal
                ? 'text-[#7dffa2]'
                : isPartial
                ? 'text-[#f59e0b]'
                : 'text-[#ffb4ab]'
            }`}
          >
            {activeCount} / 3 ACTIVOS
          </span>
        </div>
      </div>

      {/* Hero Shield Section with Ambient Glow and Rings */}
      <div className="relative flex flex-col items-center justify-center py-6 px-4 overflow-hidden rounded-2xl bg-gradient-to-b from-[#181c23] to-[#1c2027] border border-[#3b494c]/25 shadow-lg">
        {/* Ambient Radial Glow */}
        <div
          className={`absolute w-64 h-64 rounded-full blur-3xl pointer-events-none transition-all duration-700 ease-out ${
            isTotal
              ? 'bg-[#7dffa2]/20'
              : isPartial
              ? 'bg-[#f59e0b]/20'
              : 'bg-[#ffb4ab]/25'
          }`}
        ></div>

        {/* Pulsing Radar Circles */}
        <div className="relative w-48 h-48 flex items-center justify-center my-2">
          {/* Animated ping ring */}
          <div
            className={`absolute inset-0 rounded-full border transition-colors duration-500 pointer-events-none ${
              isTotal
                ? 'border-[#7dffa2]/20 animate-ping'
                : isPartial
                ? 'border-[#f59e0b]/20 animate-ping'
                : 'border-[#ffb4ab]/20 animate-ping'
            }`}
            style={{ animationDuration: '3.5s' }}
          ></div>

          {/* Inner ring */}
          <div
            className={`absolute inset-3 rounded-full border transition-colors duration-500 pointer-events-none ${
              isTotal
                ? 'border-[#7dffa2]/30'
                : isPartial
                ? 'border-[#f59e0b]/30'
                : 'border-[#ffb4ab]/30'
            }`}
          ></div>

          {/* Core circular background */}
          <div className="absolute inset-7 rounded-full bg-[#31353d]/80 backdrop-blur-md flex items-center justify-center shadow-xl transition-all duration-500 border border-[#3b494c]/50"></div>

          {/* Shield Dynamic SVG */}
          <div className="relative z-10 flex items-center justify-center transform transition-transform duration-300 hover:scale-105 active:scale-95 cursor-pointer">
            <svg
              className="w-24 h-24 transition-all duration-500"
              style={{
                filter: isTotal
                  ? 'drop-shadow(0 0 16px rgba(125, 255, 162, 0.5))'
                  : isPartial
                  ? 'drop-shadow(0 0 16px rgba(245, 158, 11, 0.5))'
                  : 'drop-shadow(0 0 18px rgba(255, 180, 171, 0.6))',
              }}
              fill="none"
              viewBox="0 0 24 24"
            >
              <path
                className="transition-colors duration-500"
                d="M12 2L4 5V11.09C4 16.14 7.41 20.85 12 22C16.59 20.85 20 16.14 20 11.09V5L12 2Z"
                fill={isTotal ? '#7dffa2' : isPartial ? '#f59e0b' : '#ffb4ab'}
                fillOpacity={isRisk ? 0.22 : 0.18}
              />
              <path
                className="transition-colors duration-500"
                d="M12 2L4 5V11.09C4 16.14 7.41 20.85 12 22C16.59 20.85 20 16.14 20 11.09V5L12 2Z"
                stroke={isTotal ? '#7dffa2' : isPartial ? '#f59e0b' : '#ffb4ab'}
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth="1.8"
              />
              {!isRisk ? (
                <path
                  className="transition-all duration-500"
                  d="M9 11.5L11 13.5L15 9.5"
                  stroke={isTotal ? '#7dffa2' : '#f59e0b'}
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2.2"
                />
              ) : (
                <path
                  className="transition-all duration-500"
                  d="M12 8V12M12 15.5V16"
                  stroke="#ffb4ab"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2.4"
                />
              )}
            </svg>
          </div>
        </div>

        {/* Shield State Label */}
        <div className="flex flex-col items-center mt-2 z-10 text-center px-4">
          <div
            className={`px-3.5 py-1 rounded-full transition-all duration-500 flex items-center gap-2 mb-1.5 ${
              isTotal
                ? 'bg-[#7dffa2]/15 text-[#7dffa2] border border-[#7dffa2]/30'
                : isPartial
                ? 'bg-[#f59e0b]/15 text-[#f59e0b] border border-[#f59e0b]/30'
                : 'bg-[#ffb4ab]/15 text-[#ffb4ab] border border-[#ffb4ab]/30'
            }`}
          >
            <span className="w-2 h-2 rounded-full bg-current animate-pulse"></span>
            <span className="font-headline text-[15px] sm:text-[17px] font-semibold tracking-tight">
              {isTotal
                ? 'Protección Total Activa'
                : isPartial
                ? 'Protección Parcial'
                : 'Protección Desactivada - En Riesgo'}
            </span>
          </div>

          <p className="font-body text-[13px] text-[#bac9cc] max-w-sm transition-colors duration-300 leading-relaxed">
            {isTotal
              ? 'Tu línea se encuentra blindada contra fraudes, acoso y violaciones a la privacidad horaria.'
              : isPartial
              ? 'Has desactivado capas clave de defensa. Tu terminal tiene brechas operativas abiertas.'
              : 'Atención: Tu línea telefónica está totalmente indefensa ante estafas y tráfico no deseado.'}
          </p>
        </div>
      </div>

      {/* Interactive Protection Modules List */}
      <div className="flex flex-col gap-3 w-full">
        {/* Card 1: Llamadas extorsivas */}
        <div
          className={`relative rounded-xl p-4 transition-all duration-300 shadow-sm flex flex-col gap-3 border ${
            config.extorsion
              ? 'bg-[#1c2027] border-[#3b494c]/30'
              : 'bg-[#262a32] border-[#ffb4ab]/40'
          }`}
        >
          <div className="flex items-start justify-between gap-3">
            <div className="flex items-start gap-3 flex-1 min-w-0">
              <div className="w-10 h-10 rounded-lg bg-[#262a32] border border-[#3b494c]/40 flex items-center justify-center shrink-0 text-[#c3f5ff]">
                <span className="material-symbols-outlined text-[22px]">gavel</span>
              </div>
              <div className="flex flex-col min-w-0">
                <div className="flex items-center gap-2">
                  <span className="font-headline text-[16px] leading-tight text-[#dfe2ed] font-semibold">
                    Llamadas extorsivas
                  </span>
                  <span className="font-mono text-[10px] px-1.5 py-0.5 rounded bg-[#c3f5ff]/10 text-[#c3f5ff] uppercase font-semibold">
                    Crítico
                  </span>
                </div>
                <span className="font-body text-[12px] text-[#bac9cc] mt-1 leading-snug">
                  Bloqueo automático de números carcelarios y redes criminales
                </span>
              </div>
            </div>

            {/* Custom Tactile Switch */}
            <button
              role="switch"
              type="button"
              aria-checked={config.extorsion}
              onClick={() => onToggle('extorsion')}
              className={`relative inline-flex h-7 w-12 shrink-0 cursor-pointer rounded-full transition-colors duration-300 ease-in-out focus:outline-none shadow-inner p-1 ${
                config.extorsion ? 'bg-[#7dffa2]' : 'bg-[#31353d]'
              }`}
            >
              <span className="sr-only">Activar protección contra extorsión</span>
              <span
                className={`inline-block h-5 w-5 transform rounded-full bg-[#0a0e15] shadow-md transition duration-300 ease-in-out ${
                  config.extorsion ? 'translate-x-5' : 'translate-x-0'
                }`}
              ></span>
            </button>
          </div>

          {/* Consequence / Alert Panel */}
          {!config.extorsion && (
            <div className="rounded-lg bg-[#93000a]/25 border border-[#ffb4ab]/30 p-3 text-[#ffb4ab] transition-all duration-300 animate-fadeIn">
              <div className="flex items-start gap-2.5">
                <span className="material-symbols-outlined text-[18px] shrink-0 mt-0.5">
                  warning
                </span>
                <div className="flex flex-col">
                  <span className="font-mono text-[11px] font-semibold tracking-wide uppercase">
                    Advertencia de riesgo alto
                  </span>
                  <span className="font-body text-[12px] text-[#bac9cc] mt-1 leading-relaxed">
                    Al desactivar, quedarás expuesto a llamadas procedentes de cárceles, números reportados por extorsión y fraudes telefónicos.
                  </span>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Card 2: Call center molestos */}
        <div
          className={`relative rounded-xl p-4 transition-all duration-300 shadow-sm flex flex-col gap-3 border ${
            config.callcenter
              ? 'bg-[#1c2027] border-[#3b494c]/30'
              : 'bg-[#262a32] border-[#f59e0b]/40'
          }`}
        >
          <div className="flex items-start justify-between gap-3">
            <div className="flex items-start gap-3 flex-1 min-w-0">
              <div className="w-10 h-10 rounded-lg bg-[#262a32] border border-[#3b494c]/40 flex items-center justify-center shrink-0 text-[#c3f5ff]">
                <span className="material-symbols-outlined text-[22px]">ring_volume</span>
              </div>
              <div className="flex flex-col min-w-0">
                <div className="flex items-center gap-2">
                  <span className="font-headline text-[16px] leading-tight text-[#dfe2ed] font-semibold">
                    Call center molestos
                  </span>
                  <span className="font-mono text-[10px] px-1.5 py-0.5 rounded bg-[#31353d] text-[#bac9cc] uppercase font-semibold">
                    Spam
                  </span>
                </div>
                <span className="font-body text-[12px] text-[#bac9cc] mt-1 leading-snug">
                  Filtro de discadores robóticos y rastreadores de disponibilidad
                </span>
              </div>
            </div>

            {/* Custom Tactile Switch */}
            <button
              role="switch"
              type="button"
              aria-checked={config.callcenter}
              onClick={() => onToggle('callcenter')}
              className={`relative inline-flex h-7 w-12 shrink-0 cursor-pointer rounded-full transition-colors duration-300 ease-in-out focus:outline-none shadow-inner p-1 ${
                config.callcenter ? 'bg-[#7dffa2]' : 'bg-[#31353d]'
              }`}
            >
              <span className="sr-only">Activar bloqueo de call centers</span>
              <span
                className={`inline-block h-5 w-5 transform rounded-full bg-[#0a0e15] shadow-md transition duration-300 ease-in-out ${
                  config.callcenter ? 'translate-x-5' : 'translate-x-0'
                }`}
              ></span>
            </button>
          </div>

          {/* Consequence / Alert Panel */}
          {!config.callcenter && (
            <div className="rounded-lg bg-[#f59e0b]/15 border border-[#f59e0b]/30 p-3 text-[#f59e0b] transition-all duration-300 animate-fadeIn">
              <div className="flex items-start gap-2.5">
                <span className="material-symbols-outlined text-[18px] shrink-0 mt-0.5">
                  report_problem
                </span>
                <div className="flex flex-col">
                  <span className="font-mono text-[11px] font-semibold tracking-wide uppercase">
                    Advertencia de exposición
                  </span>
                  <span className="font-body text-[12px] text-[#bac9cc] mt-1 leading-relaxed">
                    Al desactivar, entrarán llamadas automatizadas spam y "llamadas fantasma" donde cuelgan para validar si tu línea está activa.
                  </span>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Card 3: Ley dejen de fregar */}
        <div
          className={`relative rounded-xl p-4 transition-all duration-300 shadow-sm flex flex-col gap-3 border ${
            config.ley
              ? 'bg-[#1c2027] border-[#3b494c]/30'
              : 'bg-[#262a32] border-[#f59e0b]/40'
          }`}
        >
          <div className="flex items-start justify-between gap-3">
            <div className="flex items-start gap-3 flex-1 min-w-0">
              <div className="w-10 h-10 rounded-lg bg-[#262a32] border border-[#3b494c]/40 flex items-center justify-center shrink-0 text-[#c3f5ff]">
                <span className="material-symbols-outlined text-[22px]">policy</span>
              </div>
              <div className="flex flex-col min-w-0">
                <div className="flex items-center gap-2">
                  <span className="font-headline text-[16px] leading-tight text-[#dfe2ed] font-semibold">
                    Ley dejen de fregar
                  </span>
                  <span className="font-mono text-[10px] px-1.5 py-0.5 rounded bg-[#31353d] text-[#bac9cc] uppercase font-semibold">
                    Legal
                  </span>
                </div>
                <span className="font-body text-[12px] text-[#bac9cc] mt-1 leading-snug">
                  Cumplimiento estricto de horarios y canales comerciales no autorizados
                </span>
              </div>
            </div>

            {/* Custom Tactile Switch */}
            <button
              role="switch"
              type="button"
              aria-checked={config.ley}
              onClick={() => onToggle('ley')}
              className={`relative inline-flex h-7 w-12 shrink-0 cursor-pointer rounded-full transition-colors duration-300 ease-in-out focus:outline-none shadow-inner p-1 ${
                config.ley ? 'bg-[#7dffa2]' : 'bg-[#31353d]'
              }`}
            >
              <span className="sr-only">Activar ley dejen de fregar</span>
              <span
                className={`inline-block h-5 w-5 transform rounded-full bg-[#0a0e15] shadow-md transition duration-300 ease-in-out ${
                  config.ley ? 'translate-x-5' : 'translate-x-0'
                }`}
              ></span>
            </button>
          </div>

          {/* Consequence / Alert Panel */}
          {!config.ley && (
            <div className="rounded-lg bg-[#f59e0b]/15 border border-[#f59e0b]/30 p-3 text-[#f59e0b] transition-all duration-300 animate-fadeIn">
              <div className="flex items-start gap-2.5">
                <span className="material-symbols-outlined text-[18px] shrink-0 mt-0.5">
                  schedule
                </span>
                <div className="flex flex-col">
                  <span className="font-mono text-[11px] font-semibold tracking-wide uppercase">
                    Invasión horaria habilitada
                  </span>
                  <span className="font-body text-[12px] text-[#bac9cc] mt-1 leading-relaxed">
                    Al desactivar, los bancos y entidades comerciales podrán llamarte en horarios no hábiles, fines de semana o fuera de lo legal.
                  </span>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Operational Metric & Integrity Snapshot */}
      <div className="grid grid-cols-2 gap-3 pt-1">
        <div className="p-3 rounded-xl bg-[#181c23] border border-[#3b494c]/20 flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#1c2027] border border-[#3b494c]/40 flex items-center justify-center text-[#00daf3]">
            <span className="material-symbols-outlined text-[18px]">verified_user</span>
          </div>
          <div className="flex flex-col min-w-0">
            <span className="font-mono text-[10px] text-[#bac9cc] uppercase tracking-wider">
              LISTA LOCAL
            </span>
            <span className="font-mono text-[12px] text-[#dfe2ed] font-semibold truncate">
              {hashCount.toLocaleString()} hashes
            </span>
          </div>
        </div>

        <button
          onClick={handleManualSync}
          disabled={syncing}
          className="p-3 rounded-xl bg-[#181c23] border border-[#3b494c]/20 hover:border-[#7dffa2]/40 flex items-center gap-3 text-left transition-all active:scale-95 cursor-pointer"
        >
          <div className="w-8 h-8 rounded-lg bg-[#1c2027] border border-[#3b494c]/40 flex items-center justify-center text-[#7dffa2]">
            <span
              className={`material-symbols-outlined text-[18px] ${
                syncing ? 'animate-spin' : ''
              }`}
            >
              sync_saved_locally
            </span>
          </div>
          <div className="flex flex-col min-w-0">
            <span className="font-mono text-[10px] text-[#bac9cc] uppercase tracking-wider flex items-center gap-1">
              ACTUALIZACIÓN
              {syncing && <span className="text-[#00e5ff] text-[9px]">Sincronizando...</span>}
            </span>
            <span className="font-mono text-[12px] text-[#dfe2ed] font-semibold truncate">
              {syncing ? 'Verificando firmas...' : lastSyncTime}
            </span>
          </div>
        </button>
      </div>

      {/* Interactive Simulator Shortcut Card */}
      <div className="p-3.5 rounded-xl bg-gradient-to-r from-[#181c23] to-[#1c2027] border border-[#00e5ff]/20 flex items-center justify-between gap-3 shadow-sm">
        <div className="flex items-center gap-3 min-w-0">
          <div className="w-8 h-8 rounded-lg bg-[#00e5ff]/10 text-[#00e5ff] flex items-center justify-center shrink-0">
            <span className="material-symbols-outlined text-[18px]">notification_important</span>
          </div>
          <div className="flex flex-col min-w-0">
            <span className="font-headline text-[13px] text-[#dfe2ed] font-semibold">
              Simulador de Tiempo Real
            </span>
            <span className="font-body text-[11px] text-[#bac9cc] truncate">
              Prueba la experiencia de interceptación en pantalla bloqueada
            </span>
          </div>
        </div>
        <button
          onClick={onNavigateToSimulator}
          className="px-3 py-1.5 rounded-lg bg-[#00e5ff] text-[#00363d] font-headline text-[12px] font-bold hover:bg-[#9cf0ff] active:scale-95 transition-all shrink-0 cursor-pointer shadow-sm"
        >
          Probar
        </button>
      </div>
    </div>
  );
};
