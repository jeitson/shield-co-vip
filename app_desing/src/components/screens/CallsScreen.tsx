import React, { useState, useMemo } from 'react';
import { InterceptedEvent, ThreatLevel, EventType } from '../../types';

interface CallsScreenProps {
  events: InterceptedEvent[];
  onSelectEvent: (event: InterceptedEvent) => void;
  onToggleTrust: (eventId: string) => void;
  onToggleBlacklist: (eventId: string) => void;
  onExportSicReport: (event: InterceptedEvent) => void;
}

type FilterType = 'all' | 'call' | 'sms' | 'ALTO' | 'MEDIO' | 'BAJO';

export const CallsScreen: React.FC<CallsScreenProps> = ({
  events,
  onSelectEvent,
  onToggleTrust,
  onToggleBlacklist,
  onExportSicReport,
}) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [activeFilter, setActiveFilter] = useState<FilterType>('all');
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 2500);
  };

  const filteredEvents = useMemo(() => {
    return events.filter((ev) => {
      // Filter by chip
      if (activeFilter === 'call' && ev.type !== 'call') return false;
      if (activeFilter === 'sms' && ev.type !== 'sms') return false;
      if (
        (activeFilter === 'ALTO' ||
          activeFilter === 'MEDIO' ||
          activeFilter === 'BAJO') &&
        ev.level !== activeFilter
      ) {
        return false;
      }

      // Search term filter
      if (searchTerm.trim()) {
        const query = searchTerm.toLowerCase();
        const matchSender = ev.sender.toLowerCase().includes(query);
        const matchTitle = ev.threatTitle.toLowerCase().includes(query);
        const matchTag = ev.reputationTag.toLowerCase().includes(query);
        const matchDiagnosis = ev.diagnosis.toLowerCase().includes(query);
        const matchContent = ev.quarantinedContent?.toLowerCase().includes(query) ?? false;
        return matchSender || matchTitle || matchTag || matchDiagnosis || matchContent;
      }

      return true;
    });
  }, [events, activeFilter, searchTerm]);

  return (
    <div className="flex flex-col w-full gap-4 pb-24 max-w-2xl mx-auto animate-fadeIn">
      {/* Toast feedback */}
      {toastMessage && (
        <div className="fixed top-20 left-1/2 transform -translate-x-1/2 z-50 bg-[#1c2027] text-[#dfe2ed] px-4 py-2.5 rounded-xl border border-[#00e5ff]/40 shadow-xl flex items-center gap-2 font-mono text-xs animate-bounce">
          <span className="material-symbols-outlined text-[#7dffa2] text-[18px]">verified</span>
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Resumen de Telemetría Táctica (Bento Micro-Cards) */}
      <div className="grid grid-cols-3 gap-2.5">
        <div className="bg-[#181c23] p-3 rounded-xl flex flex-col justify-between shadow-sm border border-[#3b494c]/20">
          <div className="flex items-center justify-between">
            <span className="font-mono text-[10px] text-[#bac9cc] uppercase tracking-wider">
              Hoy
            </span>
            <span className="w-1.5 h-1.5 rounded-full bg-[#7dffa2] shadow-[0_0_6px_#00e475]"></span>
          </div>
          <div className="mt-1.5">
            <span className="font-headline text-[20px] font-bold text-[#dfe2ed] block tracking-tight">
              48
            </span>
            <span className="font-mono text-[10px] text-[#7dffa2] block font-medium">
              Intercepciones
            </span>
          </div>
        </div>

        <div className="bg-[#181c23] p-3 rounded-xl flex flex-col justify-between shadow-sm border border-[#3b494c]/20">
          <div className="flex items-center justify-between">
            <span className="font-mono text-[10px] text-[#bac9cc] uppercase tracking-wider">
              Ahorro
            </span>
            <span className="material-symbols-outlined text-[14px] text-[#00e5ff]">
              timer
            </span>
          </div>
          <div className="mt-1.5">
            <span className="font-headline text-[20px] font-bold text-[#c3f5ff] block tracking-tight">
              36m
            </span>
            <span className="font-mono text-[10px] text-[#bac9cc] block">
              Tiempo salvado
            </span>
          </div>
        </div>

        <div className="bg-[#181c23] p-3 rounded-xl flex flex-col justify-between shadow-sm border border-[#3b494c]/20">
          <div className="flex items-center justify-between">
            <span className="font-mono text-[10px] text-[#bac9cc] uppercase tracking-wider">
              Críticas
            </span>
            <span className="material-symbols-outlined text-[14px] text-[#ffb4ab]">
              gpp_maybe
            </span>
          </div>
          <div className="mt-1.5">
            <span className="font-headline text-[20px] font-bold text-[#ffb4ab] block tracking-tight">
              7
            </span>
            <span className="font-mono text-[10px] text-[#ffb4ab] block font-medium">
              Riesgo Alto
            </span>
          </div>
        </div>
      </div>

      {/* Buscador Táctico */}
      <div className="relative w-full">
        <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
          <span className="material-symbols-outlined text-[18px] text-[#bac9cc]">search</span>
        </div>
        <input
          type="text"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          placeholder="Buscar número, entidad o fragmento..."
          className="w-full pl-10 pr-10 py-2.5 bg-[#0a0e15] border border-[#3b494c]/30 rounded-xl font-mono text-[12px] text-[#dfe2ed] placeholder:text-[#bac9cc]/60 focus:outline-none focus:border-[#00e5ff]/60 focus:bg-[#181c23] transition-all duration-200"
        />
        {searchTerm ? (
          <button
            onClick={() => setSearchTerm('')}
            className="absolute inset-y-0 right-0 pr-3 flex items-center text-[#bac9cc] hover:text-[#dfe2ed]"
          >
            <span className="material-symbols-outlined text-[16px]">close</span>
          </button>
        ) : (
          <div className="absolute inset-y-0 right-0 pr-3 flex items-center text-[#bac9cc] pointer-events-none">
            <span className="material-symbols-outlined text-[18px]">filter_list</span>
          </div>
        )}
      </div>

      {/* Filtros Rápidos (Horizontal Scrollable Chips) */}
      <div className="flex items-center gap-1.5 overflow-x-auto pb-1 scrollbar-none">
        <button
          onClick={() => setActiveFilter('all')}
          className={`px-3 py-1.5 rounded-full font-mono text-[10px] font-semibold tracking-wider uppercase transition-all duration-150 shrink-0 cursor-pointer ${
            activeFilter === 'all'
              ? 'bg-[#00e5ff] text-[#00363d] shadow-sm'
              : 'bg-[#1c2027] text-[#bac9cc] hover:text-[#dfe2ed]'
          }`}
        >
          Todos ({events.length})
        </button>

        <button
          onClick={() => setActiveFilter('call')}
          className={`px-3 py-1.5 rounded-full font-mono text-[10px] tracking-wider uppercase transition-all duration-150 shrink-0 flex items-center gap-1 cursor-pointer ${
            activeFilter === 'call'
              ? 'bg-[#00e5ff] text-[#00363d] font-semibold'
              : 'bg-[#1c2027] text-[#bac9cc] hover:text-[#dfe2ed]'
          }`}
        >
          <span className="material-symbols-outlined text-[14px]">call</span> Llamadas
        </button>

        <button
          onClick={() => setActiveFilter('sms')}
          className={`px-3 py-1.5 rounded-full font-mono text-[10px] tracking-wider uppercase transition-all duration-150 shrink-0 flex items-center gap-1 cursor-pointer ${
            activeFilter === 'sms'
              ? 'bg-[#00e5ff] text-[#00363d] font-semibold'
              : 'bg-[#1c2027] text-[#bac9cc] hover:text-[#dfe2ed]'
          }`}
        >
          <span className="material-symbols-outlined text-[14px]">sms</span> SMS
        </button>

        <div className="w-px h-4 bg-[#31353d] shrink-0 mx-0.5"></div>

        <button
          onClick={() => setActiveFilter('ALTO')}
          className={`px-2.5 py-1.5 rounded-full font-mono text-[10px] tracking-wider uppercase transition-all duration-150 shrink-0 flex items-center gap-1 cursor-pointer ${
            activeFilter === 'ALTO'
              ? 'bg-[#93000a] text-white font-semibold'
              : 'bg-[#93000a]/25 text-[#ffb4ab] hover:bg-[#93000a]/40'
          }`}
        >
          <span className="w-1.5 h-1.5 rounded-full bg-[#ffb4ab] animate-pulse"></span> Alto
        </button>

        <button
          onClick={() => setActiveFilter('MEDIO')}
          className={`px-2.5 py-1.5 rounded-full font-mono text-[10px] tracking-wider uppercase transition-all duration-150 shrink-0 flex items-center gap-1 cursor-pointer ${
            activeFilter === 'MEDIO'
              ? 'bg-[#f59e0b] text-[#0f131b] font-semibold'
              : 'bg-[#1c2027] text-amber-400 hover:bg-[#262a32]'
          }`}
        >
          <span className="w-1.5 h-1.5 rounded-full bg-amber-400"></span> Medio
        </button>

        <button
          onClick={() => setActiveFilter('BAJO')}
          className={`px-2.5 py-1.5 rounded-full font-mono text-[10px] tracking-wider uppercase transition-all duration-150 shrink-0 flex items-center gap-1 cursor-pointer ${
            activeFilter === 'BAJO'
              ? 'bg-[#7dffa2] text-[#003918] font-semibold'
              : 'bg-[#1c2027] text-[#7dffa2] hover:bg-[#262a32]'
          }`}
        >
          <span className="w-1.5 h-1.5 rounded-full bg-[#7dffa2]"></span> Bajo
        </button>
      </div>

      {/* Encabezado de Lista y Estado de Motor ZK */}
      <div className="flex items-center justify-between pt-1">
        <div className="flex items-center gap-1.5">
          <span className="material-symbols-outlined text-[16px] text-[#00e5ff]">
            history_toggle_off
          </span>
          <span className="font-headline text-[15px] font-semibold text-[#dfe2ed]">
            Registro Criptográfico
          </span>
        </div>
        <div className="flex items-center gap-1.5 bg-[#181c23] px-2.5 py-0.5 rounded-full border border-[#3b494c]/30">
          <span className="w-1.5 h-1.5 rounded-full bg-[#7dffa2] animate-pulse"></span>
          <span className="font-mono text-[9px] text-[#bac9cc]">MOTOR LOCAL v4.1</span>
        </div>
      </div>

      {/* Timeline / Lista de Eventos Neutralizados */}
      <div className="flex flex-col gap-3">
        {filteredEvents.length === 0 ? (
          <div className="p-8 text-center bg-[#181c23] rounded-xl border border-[#3b494c]/20">
            <span className="material-symbols-outlined text-[36px] text-[#bac9cc]/50">
              verified_user
            </span>
            <p className="font-headline text-[15px] text-[#dfe2ed] mt-2 font-semibold">
              No hay eventos con este criterio
            </p>
            <p className="font-body text-[12px] text-[#bac9cc] mt-1">
              Tu terminal se encuentra protegida y en monitoreo constante.
            </p>
          </div>
        ) : (
          filteredEvents.map((ev) => {
            const isHigh = ev.level === 'ALTO';
            const isMed = ev.level === 'MEDIO';
            const isLow = ev.level === 'BAJO';

            return (
              <div
                key={ev.id}
                className="bg-[#181c23] rounded-xl p-4 transition-all duration-200 shadow-sm relative overflow-hidden group border border-[#3b494c]/20 hover:border-[#3b494c]/60"
              >
                {/* Glow lateral de severidad */}
                <div
                  className={`absolute left-0 top-0 bottom-0 w-1 ${
                    isHigh
                      ? 'bg-[#ffb4ab] shadow-[0_0_10px_#ff5449]'
                      : isMed
                      ? 'bg-amber-400 shadow-[0_0_8px_#f59e0b]'
                      : 'bg-[#7dffa2] shadow-[0_0_8px_#00e475]'
                  }`}
                ></div>

                <div className="flex items-start justify-between gap-3 pl-1">
                  <div className="flex items-start gap-3 min-w-0">
                    <div
                      className={`w-10 h-10 rounded-lg flex items-center justify-center shrink-0 border ${
                        isHigh
                          ? 'bg-[#93000a]/20 border-[#ffb4ab]/30 text-[#ffb4ab]'
                          : isMed
                          ? 'bg-[#1c2027] border-amber-400/30 text-amber-400'
                          : 'bg-[#7dffa2]/10 border-[#7dffa2]/30 text-[#7dffa2]'
                      }`}
                    >
                      <span className="material-symbols-outlined text-[20px]">
                        {ev.type === 'sms'
                          ? 'sms_failed'
                          : isHigh
                          ? 'phone_disabled'
                          : isMed
                          ? 'smart_toy'
                          : 'nightlight'}
                      </span>
                    </div>

                    <div className="flex flex-col min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="font-mono text-[13px] text-[#dfe2ed] font-semibold truncate">
                          {ev.sender}
                        </span>
                        <span
                          className={`font-mono text-[9px] px-1.5 py-0.5 rounded font-semibold tracking-wider uppercase ${
                            isHigh
                              ? 'bg-[#93000a]/30 text-[#ffb4ab]'
                              : isMed
                              ? 'bg-amber-400/10 text-amber-400'
                              : 'bg-[#7dffa2]/15 text-[#7dffa2]'
                          }`}
                        >
                          {ev.level}
                        </span>
                        {ev.isTrusted && (
                          <span className="font-mono text-[9px] px-1.5 py-0.5 rounded bg-[#7dffa2]/20 text-[#7dffa2]">
                            CONFIABLE
                          </span>
                        )}
                        {ev.isBlacklisted && (
                          <span className="font-mono text-[9px] px-1.5 py-0.5 rounded bg-[#ffb4ab]/20 text-[#ffb4ab]">
                            BLOQUEADO
                          </span>
                        )}
                      </div>

                      <div className="flex items-center gap-1.5 mt-0.5">
                        <span className="font-mono text-[10px] text-[#bac9cc]">
                          {ev.timestamp}
                        </span>
                        <span className="text-[#bac9cc] text-[10px]">•</span>
                        <span
                          className={`font-mono text-[10px] truncate ${
                            isHigh
                              ? 'text-[#ffb4ab]/90'
                              : isMed
                              ? 'text-amber-400/90'
                              : 'text-[#7dffa2]'
                          }`}
                        >
                          {ev.reputationTag}
                        </span>
                      </div>
                    </div>
                  </div>

                  <button
                    onClick={() => onSelectEvent(ev)}
                    aria-label="Ver detalles"
                    className="w-8 h-8 rounded-lg bg-[#1c2027] hover:bg-[#262a32] flex items-center justify-center text-[#bac9cc] hover:text-[#dfe2ed] transition-colors shrink-0 cursor-pointer"
                  >
                    <span className="material-symbols-outlined text-[18px]">more_vert</span>
                  </button>
                </div>

                {/* Banner de Diagnóstico del Escudo */}
                <div className="mt-2.5 pl-1 flex items-start gap-2 bg-[#1c2027]/70 rounded-lg p-2.5 border border-[#3b494c]/20">
                  <span
                    className={`material-symbols-outlined text-[16px] shrink-0 mt-0.5 ${
                      isHigh
                        ? 'text-[#ffb4ab]'
                        : isMed
                        ? 'text-amber-400'
                        : 'text-[#7dffa2]'
                    }`}
                  >
                    {isHigh ? 'warning' : isMed ? 'headset_off' : 'policy'}
                  </span>
                  <p className="font-body text-[12px] text-[#dfe2ed] leading-relaxed">
                    <strong
                      className={`font-semibold mr-1 ${
                        isHigh
                          ? 'text-[#ffb4ab]'
                          : isMed
                          ? 'text-amber-400'
                          : 'text-[#7dffa2]'
                      }`}
                    >
                      {ev.threatTitle}:
                    </strong>
                    {ev.diagnosis}
                  </p>
                </div>

                {/* Quarantined SMS content preview if applicable */}
                {ev.quarantinedContent && (
                  <div className="mt-2 pl-1">
                    <div className="bg-[#0a0e15] border border-[#3b494c]/30 rounded-lg p-2.5 flex flex-col gap-1">
                      <div className="flex items-center justify-between">
                        <span className="font-mono text-[10px] text-[#bac9cc]">
                          Contenido neutralizado:
                        </span>
                        <span className="font-mono text-[10px] text-[#00daf3] flex items-center gap-0.5">
                          <span className="material-symbols-outlined text-[12px]">lock</span>{' '}
                          Sandbox seguro
                        </span>
                      </div>
                      <p className="font-mono text-[11px] text-[#dfe2ed]/90 italic break-all">
                        "{ev.quarantinedContent}"
                      </p>
                    </div>
                  </div>
                )}

                {/* Acciones Rápidas */}
                <div className="mt-3 pl-1 pt-2 flex flex-wrap items-center gap-2 border-t border-[#31353d]/50">
                  {/* Blacklist toggle */}
                  <button
                    onClick={() => {
                      onToggleBlacklist(ev.id);
                      showToast(
                        ev.isBlacklisted
                          ? `${ev.sender} removido de lista negra`
                          : `${ev.sender} agregado a lista negra`
                      );
                    }}
                    className={`flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg font-mono text-[11px] font-semibold active:scale-[0.98] transition-all shrink-0 cursor-pointer ${
                      ev.isBlacklisted
                        ? 'bg-[#ffb4ab] text-[#00363d]'
                        : 'bg-[#93000a]/20 hover:bg-[#93000a]/35 border border-[#ffb4ab]/30 text-[#ffb4ab]'
                    }`}
                  >
                    <span className="material-symbols-outlined text-[15px]">block</span>
                    <span>{ev.isBlacklisted ? 'En Lista Negra' : 'Lista Negra'}</span>
                  </button>

                  {/* Trust toggle */}
                  <button
                    onClick={() => {
                      onToggleTrust(ev.id);
                      showToast(
                        ev.isTrusted
                          ? `${ev.sender} marcado como no confiable`
                          : `${ev.sender} añadido a lista de confianza`
                      );
                    }}
                    className={`flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg font-mono text-[11px] font-medium active:scale-[0.98] transition-all shrink-0 cursor-pointer ${
                      ev.isTrusted
                        ? 'bg-[#7dffa2] text-[#003918]'
                        : 'bg-[#7dffa2]/10 hover:bg-[#7dffa2]/20 border border-[#7dffa2]/30 text-[#7dffa2]'
                    }`}
                  >
                    <span className="material-symbols-outlined text-[15px]">verified_user</span>
                    <span>{ev.isTrusted ? 'Confiable' : 'De confianza'}</span>
                  </button>

                  {/* Export SIC report button if Ley 2300 */}
                  {ev.threatTitle.includes('Ley') && (
                    <button
                      onClick={() => onExportSicReport(ev)}
                      className="flex items-center gap-1 px-2.5 py-1.5 rounded-lg bg-[#7dffa2]/15 hover:bg-[#7dffa2]/25 border border-[#7dffa2]/40 text-[#7dffa2] font-mono text-[11px] font-semibold active:scale-[0.98] transition-all shrink-0 cursor-pointer"
                    >
                      <span className="material-symbols-outlined text-[14px]">download</span>
                      <span>Exportar SIC</span>
                    </button>
                  )}

                  {/* View Details button */}
                  <button
                    onClick={() => onSelectEvent(ev)}
                    className="flex items-center gap-1 px-2.5 py-1.5 rounded-lg bg-[#1c2027] hover:bg-[#262a32] text-[#bac9cc] hover:text-[#dfe2ed] font-mono text-[11px] transition-all ml-auto shrink-0 cursor-pointer"
                  >
                    <span>Ver detalles</span>
                    <span className="material-symbols-outlined text-[14px]">chevron_right</span>
                  </button>
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* Banner de Blindaje y Privacidad Zero-Knowledge */}
      <div className="bg-[#0a0e15] border border-[#3b494c]/30 p-3.5 rounded-xl flex items-center gap-3 mt-1">
        <div className="w-8 h-8 rounded-full bg-[#05e777]/20 flex items-center justify-center shrink-0 text-[#7dffa2]">
          <span className="material-symbols-outlined text-[18px]">verified</span>
        </div>
        <div className="flex flex-col min-w-0">
          <span className="font-headline text-[13px] text-[#dfe2ed] font-semibold">
            Aislamiento Criptográfico Local
          </span>
          <span className="font-body text-[11px] text-[#bac9cc] leading-relaxed">
            Ningún registro ni número telefónico sale de tu dispositivo. Todo el filtrado corre en hardware aislado.
          </span>
        </div>
      </div>
    </div>
  );
};
