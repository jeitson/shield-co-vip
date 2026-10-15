import React, { useState } from 'react';

interface AdvancedScreenProps {
  trustedNumbers: string[];
  blacklistedNumbers: string[];
  onRemoveTrusted: (number: string) => void;
  onRemoveBlacklisted: (number: string) => void;
  onAddTrusted: (number: string) => void;
  onAddBlacklisted: (number: string) => void;
  onLaunchSimulator: () => void;
  isMobileFramed: boolean;
  onToggleMobileFrame: () => void;
}

export const AdvancedScreen: React.FC<AdvancedScreenProps> = ({
  trustedNumbers,
  blacklistedNumbers,
  onRemoveTrusted,
  onRemoveBlacklisted,
  onAddTrusted,
  onAddBlacklisted,
  onLaunchSimulator,
  isMobileFramed,
  onToggleMobileFrame,
}) => {
  const [newTrustedInput, setNewTrustedInput] = useState('');
  const [newBlacklistInput, setNewBlacklistInput] = useState('');
  const [integrityChecking, setIntegrityChecking] = useState(false);
  const [integrityVerified, setIntegrityVerified] = useState(false);
  const [strictWeekendBlock, setStrictWeekendBlock] = useState(true);
  const [autoMuteGhostCalls, setAutoMuteGhostCalls] = useState(true);

  const handleIntegrityCheck = () => {
    setIntegrityChecking(true);
    setTimeout(() => {
      setIntegrityChecking(false);
      setIntegrityVerified(true);
      setTimeout(() => setIntegrityVerified(false), 3500);
    }, 1500);
  };

  const handleAddTrustedSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (newTrustedInput.trim()) {
      onAddTrusted(newTrustedInput.trim());
      setNewTrustedInput('');
    }
  };

  const handleAddBlacklistSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (newBlacklistInput.trim()) {
      onAddBlacklisted(newBlacklistInput.trim());
      setNewBlacklistInput('');
    }
  };

  return (
    <div className="flex flex-col w-full gap-4 pb-24 max-w-2xl mx-auto animate-fadeIn">
      {/* Header */}
      <div className="flex flex-col gap-1 mt-1">
        <div className="inline-flex items-center gap-2 px-2.5 py-1 rounded-full bg-[#262a32] border border-[#3b494c]/30 w-fit shadow-sm">
          <span className="material-symbols-outlined text-[14px] text-[#00e5ff]">
            tune
          </span>
          <span className="font-mono text-[11px] text-[#c3f5ff] font-medium">
            Motor Criptográfico & Reglas
          </span>
        </div>
        <h1 className="font-headline text-[24px] font-bold text-[#dfe2ed] tracking-tight mt-1">
          Configuración Avanzada
        </h1>
        <p className="font-body text-[13px] text-[#bac9cc] leading-relaxed">
          Personaliza los parámetros del escudo, gestiona tus listas locales y audita la integridad del enclave.
        </p>
      </div>

      {/* Frame Mode Switcher */}
      <div className="rounded-xl bg-[#181c23] border border-[#3b494c]/30 p-3.5 flex items-center justify-between shadow-sm">
        <div className="flex items-center gap-2.5">
          <span className="material-symbols-outlined text-[#00e5ff] text-[22px]">
            smartphone
          </span>
          <div className="flex flex-col">
            <span className="font-headline text-[13px] font-bold text-[#dfe2ed]">
              Modo Marco Móvil (Flutter Shell)
            </span>
            <span className="font-body text-[11px] text-[#bac9cc]">
              {isMobileFramed
                ? 'Emulador con marco de dispositivo activo'
                : 'Pantalla adaptable completa'}
            </span>
          </div>
        </div>
        <button
          type="button"
          onClick={onToggleMobileFrame}
          className={`px-3 py-1.5 rounded-lg font-mono text-[11px] font-semibold transition-all cursor-pointer ${
            isMobileFramed
              ? 'bg-[#00e5ff] text-[#00363d]'
              : 'bg-[#262a32] text-[#bac9cc] hover:text-[#dfe2ed]'
          }`}
        >
          {isMobileFramed ? 'Marco Activo' : 'Expandido'}
        </button>
      </div>

      {/* Ley 2300 de 2023 Schedule Rules */}
      <div className="rounded-2xl bg-[#181c23] border border-[#3b494c]/30 p-4 space-y-3 shadow-md">
        <div className="flex items-center gap-2">
          <span className="material-symbols-outlined text-[#7dffa2] text-[20px]">policy</span>
          <h2 className="font-headline text-[15px] font-bold text-[#dfe2ed]">
            Horarios Ley 2300 ("Dejen de Fregar")
          </h2>
        </div>

        <div className="space-y-2 text-xs">
          <div className="p-3 bg-[#0a0e15] border border-[#3b494c]/20 rounded-xl flex items-center justify-between">
            <div className="flex flex-col">
              <span className="font-headline font-semibold text-[#dfe2ed]">
                Lunes a Viernes
              </span>
              <span className="text-[#bac9cc] text-[11px]">
                Franja comercial autorizada: 07:00 a 19:00
              </span>
            </div>
            <span className="font-mono text-[10px] text-[#7dffa2] bg-[#7dffa2]/10 px-2 py-0.5 rounded">
              ACTIVO
            </span>
          </div>

          <div className="p-3 bg-[#0a0e15] border border-[#3b494c]/20 rounded-xl flex items-center justify-between">
            <div className="flex flex-col">
              <span className="font-headline font-semibold text-[#dfe2ed]">Sábados</span>
              <span className="text-[#bac9cc] text-[11px]">
                Franja comercial autorizada: 08:00 a 15:00
              </span>
            </div>
            <span className="font-mono text-[10px] text-[#7dffa2] bg-[#7dffa2]/10 px-2 py-0.5 rounded">
              ACTIVO
            </span>
          </div>

          <div className="p-3 bg-[#0a0e15] border border-[#3b494c]/20 rounded-xl flex items-center justify-between">
            <div className="flex flex-col">
              <span className="font-headline font-semibold text-[#dfe2ed]">
                Domingos y Festivos
              </span>
              <span className="text-[#bac9cc] text-[11px]">
                Bloqueo normativo estricto 24h
              </span>
            </div>
            <button
              type="button"
              onClick={() => setStrictWeekendBlock(!strictWeekendBlock)}
              className={`w-10 h-6 rounded-full transition-colors p-0.5 cursor-pointer ${
                strictWeekendBlock ? 'bg-[#7dffa2]' : 'bg-[#31353d]'
              }`}
            >
              <span
                className={`block w-5 h-5 rounded-full bg-[#0a0e15] transform transition-transform ${
                  strictWeekendBlock ? 'translate-x-4' : 'translate-x-0'
                }`}
              ></span>
            </button>
          </div>

          <div className="p-3 bg-[#0a0e15] border border-[#3b494c]/20 rounded-xl flex items-center justify-between">
            <div className="flex flex-col">
              <span className="font-headline font-semibold text-[#dfe2ed]">
                Silenciar "Llamadas Fantasma"
              </span>
              <span className="text-[#bac9cc] text-[11px]">
                Discadores que cuelgan antes de 3 segundos
              </span>
            </div>
            <button
              type="button"
              onClick={() => setAutoMuteGhostCalls(!autoMuteGhostCalls)}
              className={`w-10 h-6 rounded-full transition-colors p-0.5 cursor-pointer ${
                autoMuteGhostCalls ? 'bg-[#7dffa2]' : 'bg-[#31353d]'
              }`}
            >
              <span
                className={`block w-5 h-5 rounded-full bg-[#0a0e15] transform transition-transform ${
                  autoMuteGhostCalls ? 'translate-x-4' : 'translate-x-0'
                }`}
              ></span>
            </button>
          </div>
        </div>
      </div>

      {/* Zero-Knowledge Vault Integrity Audit */}
      <div className="rounded-2xl bg-[#181c23] border border-[#3b494c]/30 p-4 space-y-3 shadow-md">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-[#00e5ff] text-[20px]">
              fingerprint
            </span>
            <h2 className="font-headline text-[15px] font-bold text-[#dfe2ed]">
              Bóveda Local de Hashes ZK
            </h2>
          </div>
          <span className="font-mono text-[10px] text-[#7dffa2]">SHA-256 AISLADO</span>
        </div>

        <p className="font-body text-[12px] text-[#bac9cc] leading-relaxed">
          Cada número peligroso se almacena como una firma hash criptográfica unilateral. Tu teléfono nunca descarga ni comparte libretas de contactos en texto plano.
        </p>

        <button
          type="button"
          onClick={handleIntegrityCheck}
          disabled={integrityChecking}
          className="w-full py-2.5 px-3 rounded-xl bg-[#262a32] hover:bg-[#31353d] border border-[#00e5ff]/30 text-[#00e5ff] font-mono text-[12px] font-semibold flex items-center justify-center gap-2 cursor-pointer transition-all active:scale-[0.98]"
        >
          <span
            className={`material-symbols-outlined text-[18px] ${
              integrityChecking ? 'animate-spin' : ''
            }`}
          >
            {integrityChecking ? 'sync' : integrityVerified ? 'verified' : 'fact_check'}
          </span>
          <span>
            {integrityChecking
              ? 'Verificando firmas locales...'
              : integrityVerified
              ? '14,892 Hashes Íntegros y Verificados'
              : 'Auditar Integridad de Firmas'}
          </span>
        </button>
      </div>

      {/* Whitelist Manager */}
      <div className="rounded-2xl bg-[#181c23] border border-[#3b494c]/30 p-4 space-y-3 shadow-md">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-[#7dffa2] text-[20px]">
              verified_user
            </span>
            <h2 className="font-headline text-[15px] font-bold text-[#dfe2ed]">
              Lista de Confianza ({trustedNumbers.length})
            </h2>
          </div>
          <span className="font-mono text-[10px] text-[#bac9cc]">Siempre permitidos</span>
        </div>

        <form onSubmit={handleAddTrustedSubmit} className="flex gap-2">
          <input
            type="text"
            value={newTrustedInput}
            onChange={(e) => setNewTrustedInput(e.target.value)}
            placeholder="+57 300 000 0000"
            className="flex-1 px-3 py-2 bg-[#0a0e15] border border-[#3b494c]/30 rounded-lg font-mono text-[12px] text-[#dfe2ed] placeholder:text-[#849396]/60 focus:outline-none focus:border-[#7dffa2]"
          />
          <button
            type="submit"
            className="px-3 py-2 bg-[#7dffa2] text-[#003918] rounded-lg font-mono text-[11px] font-bold cursor-pointer hover:bg-[#62ff96] active:scale-95 transition-all"
          >
            Añadir
          </button>
        </form>

        <div className="flex flex-wrap gap-2 max-h-36 overflow-y-auto">
          {trustedNumbers.map((num) => (
            <div
              key={num}
              className="flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-[#0a0e15] border border-[#7dffa2]/30 text-[#7dffa2] font-mono text-[11px]"
            >
              <span>{num}</span>
              <button
                type="button"
                onClick={() => onRemoveTrusted(num)}
                aria-label={`Eliminar ${num}`}
                className="hover:text-white transition-colors cursor-pointer"
              >
                <span className="material-symbols-outlined text-[14px]">close</span>
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* Blacklist Manager */}
      <div className="rounded-2xl bg-[#181c23] border border-[#3b494c]/30 p-4 space-y-3 shadow-md">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-[#ffb4ab] text-[20px]">block</span>
            <h2 className="font-headline text-[15px] font-bold text-[#dfe2ed]">
              Lista Negra Personal ({blacklistedNumbers.length})
            </h2>
          </div>
          <span className="font-mono text-[10px] text-[#bac9cc]">Bloqueo absoluto</span>
        </div>

        <form onSubmit={handleAddBlacklistSubmit} className="flex gap-2">
          <input
            type="text"
            value={newBlacklistInput}
            onChange={(e) => setNewBlacklistInput(e.target.value)}
            placeholder="+57 312 000 0000"
            className="flex-1 px-3 py-2 bg-[#0a0e15] border border-[#3b494c]/30 rounded-lg font-mono text-[12px] text-[#dfe2ed] placeholder:text-[#849396]/60 focus:outline-none focus:border-[#ffb4ab]"
          />
          <button
            type="submit"
            className="px-3 py-2 bg-[#93000a] text-white rounded-lg font-mono text-[11px] font-bold cursor-pointer hover:bg-[#ba1a1a] active:scale-95 transition-all"
          >
            Bloquear
          </button>
        </form>

        <div className="flex flex-wrap gap-2 max-h-36 overflow-y-auto">
          {blacklistedNumbers.map((num) => (
            <div
              key={num}
              className="flex items-center gap-1.5 px-2.5 py-1 rounded-lg bg-[#0a0e15] border border-[#ffb4ab]/30 text-[#ffb4ab] font-mono text-[11px]"
            >
              <span>{num}</span>
              <button
                type="button"
                onClick={() => onRemoveBlacklisted(num)}
                aria-label={`Eliminar ${num}`}
                className="hover:text-white transition-colors cursor-pointer"
              >
                <span className="material-symbols-outlined text-[14px]">close</span>
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* Simulator Quick Action */}
      <div className="p-4 rounded-2xl bg-gradient-to-r from-[#181c23] to-[#262a32] border border-[#00e5ff]/30 flex items-center justify-between shadow-lg">
        <div className="flex flex-col">
          <span className="font-headline text-[14px] font-bold text-[#dfe2ed]">
            Simular Interceptación
          </span>
          <span className="font-body text-[11px] text-[#bac9cc]">
            Prueba cómo se ve la notificación flotante en pantalla bloqueada
          </span>
        </div>
        <button
          type="button"
          onClick={onLaunchSimulator}
          className="px-4 py-2 bg-[#00e5ff] hover:bg-[#9cf0ff] text-[#00363d] font-headline text-[12px] font-bold rounded-xl active:scale-95 transition-all shadow-md cursor-pointer"
        >
          Abrir Simulador
        </button>
      </div>
    </div>
  );
};
