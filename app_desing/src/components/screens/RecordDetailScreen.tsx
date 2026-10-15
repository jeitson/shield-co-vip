import React, { useState } from 'react';
import { InterceptedEvent } from '../../types';

interface RecordDetailScreenProps {
  event?: InterceptedEvent | null;
  onBack: () => void;
  onBlockAndReport: (sender: string, category: string, note: string) => void;
  onBlockLocal: (sender: string) => void;
}

export const RecordDetailScreen: React.FC<RecordDetailScreenProps> = ({
  event,
  onBack,
  onBlockAndReport,
  onBlockLocal,
}) => {
  const [activeVector, setActiveVector] = useState<'call' | 'sms'>(
    event?.type === 'sms' ? 'sms' : 'call'
  );
  const [selectedCategory, setSelectedCategory] = useState('Estafa por mensaje (Link)');
  const [extraDetails, setExtraDetails] = useState('');
  const [dualActionStatus, setDualActionStatus] = useState<
    'idle' | 'generating' | 'success'
  >('idle');
  const [localActionDone, setLocalActionDone] = useState(false);

  const senderNumber = event?.sender || '+57 318 492 8810';
  const timestamp = event?.timestamp || 'Hoy, 3:42 PM';
  const location = event?.details?.location || 'Colombia (Línea virtual sospechosa)';
  const activityType = event?.threatTitle || 'Posible estafa o llamada falsa';
  const smsPayload =
    event?.quarantinedContent ||
    'Estimado cliente, su entrega #94821 presenta novedad de dirección. Verifique urgente en: https://envio-track.secure-link.co/alert';

  const categories = [
    { id: 'Extorsión o amenaza', label: 'Extorsión o amenaza', icon: 'gavel', color: 'text-[#ffb4ab]' },
    { id: 'Estafa por mensaje (Link)', label: 'Estafa por mensaje (Link)', icon: 'link_off', color: 'text-[#00e5ff]' },
    { id: 'Call center molesto', label: 'Call center molesto', icon: 'support_agent', color: 'text-[#bac9cc]' },
    { id: 'Llamada silenciosa', label: 'Llamada silenciosa', icon: 'phone_paused', color: 'text-[#bac9cc]' },
  ];

  const handleDualAction = () => {
    setDualActionStatus('generating');
    setTimeout(() => {
      setDualActionStatus('success');
      onBlockAndReport(senderNumber, selectedCategory, extraDetails);
    }, 1200);
  };

  const handleLocalAction = () => {
    setLocalActionDone(true);
    onBlockLocal(senderNumber);
  };

  return (
    <div className="flex flex-col w-full gap-4 pb-12 max-w-2xl mx-auto animate-fadeIn">
      {/* Floating Telemetry Indicator */}
      <div className="flex items-center justify-between px-1 text-[#bac9cc]">
        <div className="flex items-center gap-2">
          <span className="w-2 h-2 rounded-full bg-[#ffb4ab] animate-pulse"></span>
          <span className="font-mono text-[11px] tracking-wider uppercase text-[#ffb4ab] font-semibold">
            Número Sospechoso
          </span>
        </div>
        <span className="font-body text-[12px] text-[#849396]">
          Identificado por la comunidad
        </span>
      </div>

      {/* Primary Target Inspection Card */}
      <div className="rounded-2xl bg-[#181c23] p-4 shadow-lg border border-[#3b494c]/30 relative overflow-hidden">
        <div className="absolute -right-12 -top-12 w-32 h-32 bg-[#c3f5ff]/5 rounded-full blur-2xl pointer-events-none"></div>

        <div className="flex items-start justify-between gap-3 mb-3">
          <div className="flex flex-col">
            <span className="font-mono text-[10px] uppercase tracking-widest text-[#849396]">
              Número Desconocido
            </span>
            <div className="flex items-center gap-2 mt-0.5">
              <span className="material-symbols-outlined text-[#c3f5ff] text-[22px]">call</span>
              <h2 className="font-headline text-[22px] font-bold text-[#dfe2ed] tracking-tight select-all">
                {senderNumber}
              </h2>
            </div>
          </div>

          <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-[#93000a]/30 text-[#ffb4ab] border border-[#ffb4ab]/30">
            <span className="w-1.5 h-1.5 rounded-full bg-[#ffb4ab] animate-ping"></span>
            <span className="font-mono text-[10px] uppercase font-semibold tracking-wider">
              Peligro Alto
            </span>
          </div>
        </div>

        {/* Vector Tabs */}
        <div className="grid grid-cols-2 gap-1 p-1 rounded-xl bg-[#0a0e15] my-3 border border-[#3b494c]/20">
          <button
            onClick={() => setActiveVector('call')}
            className={`flex items-center justify-center gap-1.5 py-2 px-3 rounded-lg font-mono text-[11px] transition-all cursor-pointer ${
              activeVector === 'call'
                ? 'bg-[#262a32] text-[#00e5ff] font-semibold shadow-sm'
                : 'text-[#bac9cc] hover:text-[#dfe2ed]'
            }`}
          >
            <span className="material-symbols-outlined text-[16px]">call_missed</span>
            <span>Llamada recibida (4s)</span>
          </button>
          <button
            onClick={() => setActiveVector('sms')}
            className={`flex items-center justify-center gap-1.5 py-2 px-3 rounded-lg font-mono text-[11px] transition-all cursor-pointer ${
              activeVector === 'sms'
                ? 'bg-[#262a32] text-[#00e5ff] font-semibold shadow-sm'
                : 'text-[#bac9cc] hover:text-[#dfe2ed]'
            }`}
          >
            <span className="material-symbols-outlined text-[16px]">sms</span>
            <span>SMS Recibido (1)</span>
          </button>
        </div>

        {/* Forensic Metadata rows */}
        <div className="space-y-1.5 pt-1 text-xs">
          <div className="flex items-center justify-between py-1.5 border-b border-[#1c2027]">
            <span className="text-[#bac9cc] flex items-center gap-1.5">
              <span className="material-symbols-outlined text-[15px] text-[#849396]">schedule</span>
              Fecha y hora
            </span>
            <span className="font-mono text-[#dfe2ed]">{timestamp}</span>
          </div>

          <div className="flex items-center justify-between py-1.5 border-b border-[#1c2027]">
            <span className="text-[#bac9cc] flex items-center gap-1.5">
              <span className="material-symbols-outlined text-[15px] text-[#849396]">location_on</span>
              Ubicación reportada
            </span>
            <span className="font-mono text-[#dfe2ed]">{location}</span>
          </div>

          <div className="flex items-center justify-between py-1.5">
            <span className="text-[#bac9cc] flex items-center gap-1.5">
              <span className="material-symbols-outlined text-[15px] text-[#849396]">warning</span>
              Tipo de actividad
            </span>
            <span className="font-mono text-[#ffb4ab] font-medium">{activityType}</span>
          </div>
        </div>
      </div>

      {/* Payload Sandbox / Evidence Analysis */}
      <div className="rounded-2xl bg-[#181c23] p-4 space-y-3 shadow-md border border-[#3b494c]/30">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-[#00e5ff] text-[20px]">sms</span>
            <h3 className="font-headline text-[15px] text-[#dfe2ed] font-semibold">
              Mensaje de texto sospechoso
            </h3>
          </div>
          <span className="px-2 py-0.5 rounded bg-[#93000a]/25 text-[#ffb4ab] font-mono text-[10px] font-semibold border border-[#ffb4ab]/30">
            Peligroso
          </span>
        </div>

        <div className="p-3 rounded-xl bg-[#0a0e15] border border-[#3b494c]/30 font-mono text-[12px] text-[#dfe2ed]/90 leading-relaxed break-words">
          <p className="select-all">
            "{smsPayload.split('https')[0]}
            <span className="text-[#ffb4ab] font-medium underline decoration-[#ffb4ab]/50 break-all">
              https{smsPayload.split('https')[1] || ''}
            </span>
            "
          </p>
        </div>

        <div className="p-3 rounded-xl bg-[#1c2027] border border-[#ffb4ab]/25 flex items-start gap-2.5">
          <span className="material-symbols-outlined text-[#ffb4ab] text-[20px] shrink-0 mt-0.5">
            report
          </span>
          <div className="flex flex-col gap-0.5">
            <span className="font-headline text-[13px] font-semibold text-[#ffb4ab]">
              Alerta de enlace peligroso
            </span>
            <p className="font-body text-[12px] text-[#bac9cc] leading-relaxed">
              El enlace intenta hacerse pasar por una empresa de envíos conocida para robar tus datos bancarios y personales. No abras este enlace.
            </p>
          </div>
        </div>
      </div>

      {/* Core Module: Dual Protection & Community Hash Shield */}
      <div className="rounded-2xl bg-[#262a32] p-4 space-y-4 shadow-xl relative overflow-hidden border border-[#00e5ff]/25">
        <div className="absolute -left-16 bottom-0 w-40 h-40 bg-[#00e5ff]/10 rounded-full blur-3xl pointer-events-none"></div>

        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-[#00e5ff]/20 text-[#00e5ff] flex items-center justify-center">
              <span className="material-symbols-outlined text-[20px]">shield</span>
            </div>
            <div>
              <h3 className="font-headline text-[15px] text-[#dfe2ed] font-bold">
                Opciones de bloqueo
              </h3>
              <p className="font-body text-[12px] text-[#bac9cc]">
                Elige cómo quieres responder a este número
              </p>
            </div>
          </div>
        </div>

        <div className="space-y-2">
          <div className="p-3 rounded-xl bg-[#181c23] border border-[#3b494c]/20 flex gap-2.5 items-start">
            <div className="w-6 h-6 rounded bg-[#31353d] flex items-center justify-center text-[#c3f5ff] shrink-0 mt-0.5">
              <span className="material-symbols-outlined text-[15px]">phone_disabled</span>
            </div>
            <div className="flex flex-col">
              <span className="font-headline text-[13px] font-bold text-[#dfe2ed]">
                1. Bloquear en tu teléfono
              </span>
              <p className="font-body text-[11px] text-[#bac9cc] mt-0.5 leading-relaxed">
                No volverás a recibir llamadas ni mensajes de este número en tu dispositivo.
              </p>
            </div>
          </div>

          <div className="p-3 rounded-xl bg-[#181c23] border border-[#3b494c]/20 flex gap-2.5 items-start">
            <div className="w-6 h-6 rounded bg-[#31353d] flex items-center justify-center text-[#7dffa2] shrink-0 mt-0.5">
              <span className="material-symbols-outlined text-[15px]">group</span>
            </div>
            <div className="flex flex-col">
              <span className="font-headline text-[13px] font-bold text-[#dfe2ed]">
                2. Ayudar a proteger a otros
              </span>
              <p className="font-body text-[11px] text-[#bac9cc] mt-0.5 leading-relaxed">
                Reportamos este número a la comunidad para que también se bloquee y alerte a otros usuarios.
              </p>
            </div>
          </div>
        </div>

        {/* Category Chips */}
        <div className="space-y-1.5 pt-1">
          <label className="font-mono text-[10px] uppercase tracking-wider text-[#849396] block">
            ¿Qué tipo de problema fue?
          </label>
          <div className="grid grid-cols-2 gap-2">
            {categories.map((cat) => {
              const isSelected = selectedCategory === cat.id;
              return (
                <button
                  key={cat.id}
                  type="button"
                  onClick={() => setSelectedCategory(cat.id)}
                  className={`py-2 px-2.5 rounded-lg text-left flex items-center gap-2 transition-all cursor-pointer border ${
                    isSelected
                      ? 'bg-[#1c2027] text-[#00e5ff] font-semibold border-[#00e5ff]/50 shadow-sm'
                      : 'bg-[#0a0e15] text-[#bac9cc] border-[#3b494c]/30 hover:bg-[#1c2027]'
                  }`}
                >
                  <span className={`material-symbols-outlined text-[16px] ${cat.color}`}>
                    {cat.icon}
                  </span>
                  <span className="font-mono text-[11px] truncate">{cat.label}</span>
                </button>
              );
            })}
          </div>
        </div>

        {/* Notes input */}
        <div className="space-y-1">
          <label className="font-mono text-[10px] uppercase tracking-wider text-[#849396] block">
            Detalles adicionales (opcional)
          </label>
          <input
            type="text"
            value={extraDetails}
            onChange={(e) => setExtraDetails(e.target.value)}
            placeholder="Ej: Dicen ser de una empresa de envíos para pedir contraseñas"
            className="w-full px-3 py-2.5 rounded-xl bg-[#0a0e15] border border-[#3b494c]/30 text-[#dfe2ed] font-body text-[12px] placeholder:text-[#849396]/60 focus:outline-none focus:border-[#00e5ff] transition-all"
          />
        </div>

        {/* Action Buttons */}
        <div className="pt-2 space-y-2">
          <button
            type="button"
            disabled={dualActionStatus === 'generating'}
            onClick={handleDualAction}
            className={`w-full py-3.5 px-4 rounded-xl font-headline text-[15px] font-bold flex items-center justify-center gap-2 shadow-lg active:scale-[0.98] transition-all cursor-pointer ${
              dualActionStatus === 'success'
                ? 'bg-[#05e777] text-[#003918]'
                : dualActionStatus === 'generating'
                ? 'bg-[#00daf3] text-[#00363d]'
                : 'bg-[#00e5ff] hover:bg-[#9cf0ff] text-[#00363d]'
            }`}
          >
            {dualActionStatus === 'generating' ? (
              <>
                <span className="material-symbols-outlined text-[20px] animate-spin">sync</span>
                <span>Generando Prueba ZK & Inmunizando...</span>
              </>
            ) : dualActionStatus === 'success' ? (
              <>
                <span className="material-symbols-outlined text-[20px]">check_circle</span>
                <span>¡Bloqueado y Sincronizado con Éxito!</span>
              </>
            ) : (
              <>
                <span className="material-symbols-outlined text-[20px]">shield</span>
                <span>Reportar y bloquear</span>
              </>
            )}
          </button>

          <button
            type="button"
            onClick={handleLocalAction}
            className="w-full py-2.5 px-4 rounded-xl bg-[#181c23] hover:bg-[#1c2027] border border-[#3b494c]/30 text-[#bac9cc] hover:text-[#dfe2ed] font-mono text-[12px] flex items-center justify-center gap-1.5 active:scale-[0.99] transition-all cursor-pointer"
          >
            <span
              className={`material-symbols-outlined text-[18px] ${
                localActionDone ? 'text-[#7dffa2]' : 'text-[#849396]'
              }`}
            >
              {localActionDone ? 'check' : 'person_off'}
            </span>
            <span className={localActionDone ? 'text-[#7dffa2] font-semibold' : ''}>
              {localActionDone ? 'Número Silenciado Localmente' : 'Bloquear solo para mí'}
            </span>
          </button>
        </div>
      </div>

      {/* Technical Forensics & Zero-Knowledge Attestation */}
      <div className="rounded-2xl bg-[#181c23] p-4 shadow-sm border border-[#3b494c]/20">
        <div className="flex items-start gap-3">
          <div className="w-8 h-8 rounded-full bg-[#262a32] border border-[#3b494c]/40 flex items-center justify-center text-[#00e5ff] shrink-0 mt-0.5">
            <span className="material-symbols-outlined text-[18px]">verified_user</span>
          </div>
          <div className="flex flex-col gap-1">
            <span className="font-headline text-[14px] text-[#dfe2ed] font-semibold">
              Tu privacidad está protegida
            </span>
            <p className="font-body text-[12px] text-[#bac9cc] leading-relaxed">
              Al reportar un número, tus contactos, mensajes e información personal nunca son compartidos con nadie. Tu reporte es 100% anónimo.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};
