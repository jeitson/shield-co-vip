import React, { useState } from 'react';
import { ActiveScreen, ShieldConfig, InterceptedEvent } from './types';
import { INITIAL_EVENTS, DEFAULT_INSPECTION_TARGET } from './data/mockData';
import { Header } from './components/Header';
import { BottomNav } from './components/BottomNav';
import { ShieldScreen } from './components/screens/ShieldScreen';
import { CallsScreen } from './components/screens/CallsScreen';
import { RecordDetailScreen } from './components/screens/RecordDetailScreen';
import { ReportChannelsScreen } from './components/screens/ReportChannelsScreen';
import { LiveSimulatorScreen } from './components/screens/LiveSimulatorScreen';
import { LoginScreen } from './components/screens/LoginScreen';
import { RegisterScreen } from './components/screens/RegisterScreen';
import { AdvancedScreen } from './components/screens/AdvancedScreen';

export default function App() {
  const [activeScreen, setActiveScreen] = useState<ActiveScreen>('shield');
  const [shieldConfig, setShieldConfig] = useState<ShieldConfig>({
    extorsion: true,
    callcenter: true,
    ley: true,
  });
  const [events, setEvents] = useState<InterceptedEvent[]>(INITIAL_EVENTS);
  const [selectedEvent, setSelectedEvent] = useState<InterceptedEvent | null>(null);
  const [trustedNumbers, setTrustedNumbers] = useState<string[]>([
    '+57 300 123 4567',
    '+57 310 999 0000',
  ]);
  const [blacklistedNumbers, setBlacklistedNumbers] = useState<string[]>([
    '+57 312 849 2011',
    '+57 601 789 4433',
  ]);
  const [isMobileFramed, setIsMobileFramed] = useState<boolean>(true);
  const [sicExportEvent, setSicExportEvent] = useState<InterceptedEvent | null>(null);
  const [sicCopied, setSicCopied] = useState<boolean>(false);

  const activeShieldCount = Object.values(shieldConfig).filter(Boolean).length;

  const handleToggleShield = (key: keyof ShieldConfig) => {
    setShieldConfig((prev) => ({
      ...prev,
      [key]: !prev[key],
    }));
  };

  const handleSelectEvent = (event: InterceptedEvent) => {
    setSelectedEvent(event);
    setActiveScreen('detail');
  };

  const handleToggleTrust = (eventId: string) => {
    setEvents((prev) =>
      prev.map((ev) => {
        if (ev.id === eventId) {
          const nextVal = !ev.isTrusted;
          if (nextVal) {
            setTrustedNumbers((curr) =>
              curr.includes(ev.sender) ? curr : [...curr, ev.sender]
            );
            setBlacklistedNumbers((curr) => curr.filter((n) => n !== ev.sender));
          } else {
            setTrustedNumbers((curr) => curr.filter((n) => n !== ev.sender));
          }
          return { ...ev, isTrusted: nextVal, isBlacklisted: false };
        }
        return ev;
      })
    );
  };

  const handleToggleBlacklist = (eventId: string) => {
    setEvents((prev) =>
      prev.map((ev) => {
        if (ev.id === eventId) {
          const nextVal = !ev.isBlacklisted;
          if (nextVal) {
            setBlacklistedNumbers((curr) =>
              curr.includes(ev.sender) ? curr : [...curr, ev.sender]
            );
            setTrustedNumbers((curr) => curr.filter((n) => n !== ev.sender));
          } else {
            setBlacklistedNumbers((curr) => curr.filter((n) => n !== ev.sender));
          }
          return { ...ev, isBlacklisted: nextVal, isTrusted: false };
        }
        return ev;
      })
    );
  };

  const handleBlockAndReport = (
    sender: string,
    category: string,
    note: string
  ) => {
    setBlacklistedNumbers((prev) =>
      prev.includes(sender) ? prev : [...prev, sender]
    );
    setEvents((prev) =>
      prev.map((ev) =>
        ev.sender === sender ? { ...ev, isBlacklisted: true, isTrusted: false } : ev
      )
    );
  };

  const handleBlockLocal = (sender: string) => {
    setBlacklistedNumbers((prev) =>
      prev.includes(sender) ? prev : [...prev, sender]
    );
    setEvents((prev) =>
      prev.map((ev) =>
        ev.sender === sender ? { ...ev, isBlacklisted: true } : ev
      )
    );
  };

  const handleExportSicReport = (event: InterceptedEvent) => {
    setSicExportEvent(event);
    setSicCopied(false);
  };

  const copySicEvidence = () => {
    if (!sicExportEvent) return;
    const text = `EVIDENCIA DE DENUNCIA LEY 2300 DE 2023 (DEJEN DE FREGAR)\nSuperintendencia de Industria y Comercio (SIC)\n-------------------------------------------------\nNúmero Infractor: ${sicExportEvent.sender}\nFecha y Hora: ${sicExportEvent.timestamp}\nTipo de Acoso: ${sicExportEvent.threatTitle}\nDetalles: ${sicExportEvent.diagnosis}\nID de Registro Local: ${sicExportEvent.id}\nFirma Criptográfica: HASH_ZK_${Math.random().toString(36).substring(2, 10).toUpperCase()}\nGenerado por Cifrado Cero`;

    if (navigator.clipboard) {
      navigator.clipboard.writeText(text);
      setSicCopied(true);
      setTimeout(() => setSicCopied(false), 2500);
    }
  };

  return (
    <div className="min-h-screen bg-[#0a0e15] text-[#dfe2ed] flex flex-col items-center justify-start antialiased selection:bg-[#00e5ff] selection:text-[#00363d]">
      {/* Top Quick Screen Switcher Toolbar (Allows instantly demonstrating all Flutter screens) */}
      <aside aria-label="Navegación de pantallas" className="w-full bg-[#111622] border-b border-[#212c42] px-3 py-2 z-50 flex items-center justify-between overflow-x-auto gap-2 text-xs">
        <div className="flex items-center gap-2 shrink-0">
          <div className="w-2 h-2 rounded-full bg-[#7dffa2] animate-pulse"></div>
          <span className="font-headline font-bold text-[#c3f5ff] text-[13px] tracking-wide">
            Cifrado Cero
          </span>
          <span className="font-mono text-[10px] text-[#849396] hidden sm:inline">
            • Flutter Screens
          </span>
        </div>

        {/* Quick jump buttons */}
        <div className="flex items-center gap-1 shrink-0 overflow-x-auto">
          {[
            { id: 'shield', label: 'Escudo' },
            { id: 'calls', label: 'Llamadas' },
            { id: 'detail', label: 'Detalle' },
            { id: 'report', label: 'Denunciar' },
            { id: 'simulator', label: 'Simulador' },
            { id: 'advanced', label: 'Avanzados' },
            { id: 'login', label: 'Acceso' },
            { id: 'register', label: 'Registro' },
          ].map((screen) => (
            <button
              key={screen.id}
              onClick={() => {
                if (screen.id === 'detail' && !selectedEvent) {
                  setSelectedEvent(INITIAL_EVENTS[0]);
                }
                setActiveScreen(screen.id as ActiveScreen);
              }}
              className={`px-2.5 py-1 rounded-md font-mono text-[11px] transition-all cursor-pointer ${
                activeScreen === screen.id
                  ? 'bg-[#00e5ff] text-[#00363d] font-bold shadow-sm'
                  : 'bg-[#182030] text-[#bac9cc] hover:text-white hover:bg-[#212c42]'
              }`}
            >
              {screen.label}
            </button>
          ))}
        </div>

        {/* Frame Toggle */}
        <div className="flex items-center gap-1.5 shrink-0 pl-2 border-l border-[#212c42]">
          <button
            onClick={() => setIsMobileFramed(!isMobileFramed)}
            title="Alternar entre vista de emulador móvil o vista adaptada"
            className="flex items-center gap-1 px-2.5 py-1 rounded-md bg-[#182030] hover:bg-[#212c42] text-[#c3f5ff] font-mono text-[11px] border border-[#3b494c]/40 cursor-pointer transition-all"
          >
            <span className="material-symbols-outlined text-[15px]">
              {isMobileFramed ? 'fullscreen' : 'smartphone'}
            </span>
            <span className="hidden md:inline">
              {isMobileFramed ? 'Pantalla Completa' : 'Marco Móvil'}
            </span>
          </button>
        </div>
      </aside>

      {/* Main Container: Mobile Frame vs Fluid Canvas */}
      <div
        className={`w-full transition-all duration-300 flex justify-center ${
          isMobileFramed ? 'py-4 px-2 sm:py-8' : 'p-0 max-w-4xl'
        }`}
      >
        <div
          className={`w-full transition-all duration-300 relative flex flex-col ${
            isMobileFramed
              ? 'max-w-[420px] min-h-[840px] bg-[#0f131b] rounded-[40px] border-[8px] border-[#1c2027] shadow-[0_20px_60px_rgba(0,0,0,0.8)] overflow-hidden ring-1 ring-[#3b494c]/40'
              : 'min-h-screen bg-[#0f131b]'
          }`}
        >
          {/* Simulated Mobile Status Bar (Inside mobile frame) */}
          {isMobileFramed && (
            <div className="w-full bg-[#0f131b] h-8 px-6 pt-2 flex items-center justify-between text-xs font-mono text-[#bac9cc] select-none z-50">
              <span className="font-semibold text-[11px] text-[#dfe2ed]">09:41</span>
              {/* Dynamic Island / Notch */}
              <div className="w-24 h-4 bg-[#05070a] rounded-full flex items-center justify-center">
                <span className="w-2 h-2 rounded-full bg-[#181c23]"></span>
              </div>
              <div className="flex items-center gap-1.5 text-[#dfe2ed]">
                <span className="material-symbols-outlined text-[13px]">signal_cellular_alt</span>
                <span className="material-symbols-outlined text-[13px]">wifi</span>
                <span className="material-symbols-outlined text-[13px]">battery_full</span>
              </div>
            </div>
          )}

          {/* Screen Content Wrapper */}
          <div className="flex-1 flex flex-col relative w-full overflow-y-auto">
            {/* Header */}
            <Header
              activeScreen={activeScreen}
              onNavigate={(s) => setActiveScreen(s)}
              onBack={() => setActiveScreen('calls')}
              activeCount={activeShieldCount}
            />

            {/* Screen Body */}
            <main className="flex-1 px-4 pt-3 pb-8">
              {activeScreen === 'shield' && (
                <ShieldScreen
                  config={shieldConfig}
                  onToggle={handleToggleShield}
                  onNavigateToSimulator={() => setActiveScreen('simulator')}
                />
              )}

              {activeScreen === 'calls' && (
                <CallsScreen
                  events={events}
                  onSelectEvent={handleSelectEvent}
                  onToggleTrust={handleToggleTrust}
                  onToggleBlacklist={handleToggleBlacklist}
                  onExportSicReport={handleExportSicReport}
                />
              )}

              {activeScreen === 'detail' && (
                <RecordDetailScreen
                  event={selectedEvent}
                  onBack={() => setActiveScreen('calls')}
                  onBlockAndReport={handleBlockAndReport}
                  onBlockLocal={handleBlockLocal}
                />
              )}

              {activeScreen === 'report' && <ReportChannelsScreen />}

              {activeScreen === 'simulator' && <LiveSimulatorScreen />}

              {activeScreen === 'login' && (
                <LoginScreen
                  onSuccess={() => setActiveScreen('shield')}
                  onGoToRegister={() => setActiveScreen('register')}
                />
              )}

              {activeScreen === 'register' && (
                <RegisterScreen
                  onSuccess={() => setActiveScreen('shield')}
                  onGoToLogin={() => setActiveScreen('login')}
                />
              )}

              {activeScreen === 'advanced' && (
                <AdvancedScreen
                  trustedNumbers={trustedNumbers}
                  blacklistedNumbers={blacklistedNumbers}
                  onRemoveTrusted={(num) =>
                    setTrustedNumbers((prev) => prev.filter((n) => n !== num))
                  }
                  onRemoveBlacklisted={(num) =>
                    setBlacklistedNumbers((prev) => prev.filter((n) => n !== num))
                  }
                  onAddTrusted={(num) =>
                    setTrustedNumbers((prev) =>
                      prev.includes(num) ? prev : [...prev, num]
                    )
                  }
                  onAddBlacklisted={(num) =>
                    setBlacklistedNumbers((prev) =>
                      prev.includes(num) ? prev : [...prev, num]
                    )
                  }
                  onLaunchSimulator={() => setActiveScreen('simulator')}
                  isMobileFramed={isMobileFramed}
                  onToggleMobileFrame={() => setIsMobileFramed(!isMobileFramed)}
                />
              )}
            </main>

            {/* Bottom Navigation */}
            <BottomNav
              activeScreen={activeScreen}
              onNavigate={(s) => setActiveScreen(s)}
            />
          </div>

          {/* Bottom Home Indicator Bar (Inside mobile frame) */}
          {isMobileFramed && (
            <div className="w-full bg-[#0f131b] h-5 flex items-center justify-center pointer-events-none pb-1 z-50">
              <div className="w-32 h-1 bg-[#3b494c]/60 rounded-full"></div>
            </div>
          )}
        </div>
      </div>

      {/* SIC Report Export Modal */}
      {sicExportEvent && (
        <div className="fixed inset-0 z-50 bg-black/70 backdrop-blur-sm flex items-center justify-center p-4 animate-fadeIn">
          <div className="bg-[#181c23] border border-[#00e5ff]/40 rounded-2xl max-w-md w-full p-5 shadow-2xl flex flex-col gap-4">
            <div className="flex items-center justify-between border-b border-[#3b494c]/30 pb-3">
              <div className="flex items-center gap-2">
                <span className="material-symbols-outlined text-[#7dffa2] text-[22px]">
                  policy
                </span>
                <span className="font-headline font-bold text-[16px] text-[#dfe2ed]">
                  Reporte de Evidencia SIC
                </span>
              </div>
              <button
                onClick={() => setSicExportEvent(null)}
                className="text-[#bac9cc] hover:text-white cursor-pointer"
              >
                <span className="material-symbols-outlined text-[20px]">close</span>
              </button>
            </div>

            <p className="font-body text-[12px] text-[#bac9cc] leading-relaxed">
              Este resumen extrae los metadatos forenses de la llamada para que puedas adjuntarlos directamente en la queja ante la Superintendencia de Industria y Comercio.
            </p>

            <div className="bg-[#0a0e15] border border-[#3b494c]/40 rounded-xl p-3 font-mono text-[11px] text-[#dfe2ed] leading-relaxed space-y-1">
              <div><strong className="text-[#00e5ff]">Número Infractor:</strong> {sicExportEvent.sender}</div>
              <div><strong className="text-[#00e5ff]">Fecha y Hora:</strong> {sicExportEvent.timestamp}</div>
              <div><strong className="text-[#00e5ff]">Causal:</strong> Violación franja Ley 2300 de 2023</div>
              <div><strong className="text-[#00e5ff]">Diagnóstico:</strong> {sicExportEvent.diagnosis}</div>
              <div><strong className="text-[#00e5ff]">Hash de Integridad:</strong> 7c9a9f24b8109d...</div>
            </div>

            <div className="flex gap-2">
              <button
                type="button"
                onClick={copySicEvidence}
                className="flex-1 py-2.5 px-3 rounded-xl bg-[#00e5ff] text-[#00363d] font-headline text-[13px] font-bold flex items-center justify-center gap-1.5 cursor-pointer hover:bg-[#9cf0ff] active:scale-95 transition-all"
              >
                <span className="material-symbols-outlined text-[16px]">
                  {sicCopied ? 'check' : 'content_copy'}
                </span>
                <span>{sicCopied ? '¡Copiado con Éxito!' : 'Copiar Evidencia'}</span>
              </button>

              <a
                href="https://serviciosweb.sic.gov.co/reclamasindiligencia/"
                target="_blank"
                rel="noopener noreferrer"
                className="py-2.5 px-3 rounded-xl bg-[#262a32] text-[#dfe2ed] font-headline text-[13px] font-semibold flex items-center justify-center gap-1 cursor-pointer hover:bg-[#31353d]"
              >
                <span>Ir a la SIC</span>
                <span className="material-symbols-outlined text-[16px]">open_in_new</span>
              </a>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
