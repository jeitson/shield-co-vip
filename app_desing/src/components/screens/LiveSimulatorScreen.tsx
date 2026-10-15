import React, { useState } from 'react';

export const LiveSimulatorScreen: React.FC = () => {
  const [simulatorTab, setSimulatorTab] = useState<'call' | 'sms'>('call');
  const [toastFeedback, setToastFeedback] = useState<{
    text: string;
    icon: string;
    color: string;
  } | null>(null);
  const [cardDismissed, setCardDismissed] = useState(false);

  const showToast = (action: 'report' | 'trust' | 'dismiss') => {
    if (action === 'report') {
      setToastFeedback({
        text: 'Contacto bloqueado y reportado de forma anónima.',
        icon: 'shield',
        color: 'text-[#ffb4ab]',
      });
    } else if (action === 'trust') {
      setToastFeedback({
        text: 'Número agregado a tu lista de contactos de confianza.',
        icon: 'verified_user',
        color: 'text-[#7dffa2]',
      });
    } else {
      setToastFeedback({
        text: 'Notificación descartada de la vista.',
        icon: 'visibility_off',
        color: 'text-[#bac9cc]',
      });
      setCardDismissed(true);
      setTimeout(() => setCardDismissed(false), 2400);
    }

    setTimeout(() => {
      setToastFeedback(null);
    }, 3200);
  };

  return (
    <div className="flex flex-col w-full gap-4 pb-24 max-w-2xl mx-auto animate-fadeIn">
      {/* Interactive Selector Switch (Simulation Control Panel) */}
      <div className="flex flex-col gap-2">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-[#05e777] animate-pulse"></span>
            <span className="font-mono text-[11px] text-[#7dffa2] font-semibold tracking-wider uppercase">
              MODO EN VIVO · SIMULADOR
            </span>
          </div>
          <span className="font-mono text-[10px] text-[#849396] tracking-widest uppercase">
            TIEMPO REAL
          </span>
        </div>

        {/* Toggle Segmented Control */}
        <div className="grid grid-cols-2 p-1 bg-[#181c23] rounded-xl gap-1 border border-[#3b494c]/30">
          <button
            type="button"
            onClick={() => {
              setSimulatorTab('call');
              setCardDismissed(false);
            }}
            className={`flex items-center justify-center gap-2 py-2 px-3 rounded-lg font-headline text-[13px] transition-all cursor-pointer ${
              simulatorTab === 'call'
                ? 'bg-[#31353d] text-[#dfe2ed] font-semibold shadow-sm border border-[#3b494c]/40'
                : 'text-[#849396] hover:text-[#dfe2ed]'
            }`}
          >
            <span className="material-symbols-outlined text-[16px] text-[#00e5ff]">
              phone_disabled
            </span>
            <span className="font-body text-[12px] font-semibold">Llamada bloqueada</span>
          </button>

          <button
            type="button"
            onClick={() => {
              setSimulatorTab('sms');
              setCardDismissed(false);
            }}
            className={`flex items-center justify-center gap-2 py-2 px-3 rounded-lg font-headline text-[13px] transition-all cursor-pointer ${
              simulatorTab === 'sms'
                ? 'bg-[#31353d] text-[#dfe2ed] font-semibold shadow-sm border border-[#3b494c]/40'
                : 'text-[#849396] hover:text-[#dfe2ed]'
            }`}
          >
            <span className="material-symbols-outlined text-[16px] text-[#00e5ff]">sms</span>
            <span className="font-body text-[12px] font-semibold">SMS interceptado</span>
          </button>
        </div>
      </div>

      {/* Ambient Phone Wallpaper Simulation Canvas */}
      <div className="relative w-full rounded-2xl overflow-hidden bg-[#0a0e15] p-4 sm:p-5 flex flex-col gap-4 shadow-2xl border border-[#3b494c]/40">
        {/* System Status Bar */}
        <div className="flex items-center justify-between text-[#bac9cc] font-mono text-[11px] px-1">
          <span className="font-semibold">09:41</span>
          <div className="flex items-center gap-2 text-[#dfe2ed]">
            <span className="material-symbols-outlined text-[14px]">signal_cellular_alt</span>
            <span className="material-symbols-outlined text-[14px]">wifi</span>
            <span className="material-symbols-outlined text-[14px]">battery_full</span>
          </div>
        </div>

        {/* Lockscreen Wallpaper & Ambient Clock */}
        <div className="relative w-full rounded-xl overflow-hidden py-4 flex flex-col items-center justify-center min-h-[140px] border border-[#3b494c]/20">
          <div
            className="absolute inset-0 bg-cover bg-center opacity-40 filter blur-[2px]"
            style={{
              backgroundImage:
                "url('https://lh3.googleusercontent.com/aida-public/AB6AXuDn6g6GQ8c3pLOI9XYrkfGrsgCyN5hVm77AnoMalYLpUKf8_MkqiL2A8f66s4ewcGdPg2FUWpy-s98cyWcdlIm5JpD-lxecWLkas4qXDNYfduezJllmizk6Og693c1c__IZBOKpZEqp4HB4ScEXyLCtbjWx7soAM8L4WvbRvuSnpmxW6xR9iB804QjnC5MKEGwwwJUdeGkslepCJAV5n_Ete79GutV4bNSQIgVLH_l7zhBdNd3L-NFF')",
            }}
          ></div>
          <div className="absolute inset-0 bg-gradient-to-b from-[#0a0e15]/80 via-[#0a0e15]/40 to-[#0a0e15]/90"></div>

          {/* Clock */}
          <div className="relative z-10 flex flex-col items-center py-1">
            <span className="font-headline text-[38px] font-bold text-[#dfe2ed]/60 tracking-tight leading-none">
              09:41
            </span>
            <span className="font-body text-[12px] text-[#bac9cc]/75 mt-1">
              Jueves, 24 de Octubre
            </span>
          </div>
        </div>

        {/* Heads-Up Banner Notification Container */}
        {!cardDismissed ? (
          <div className="relative z-20 w-full bg-[#262a32] rounded-2xl p-4 shadow-2xl flex flex-col gap-3.5 border border-[#3b494c]/40 animate-slideDown">
            {/* Heads-Up Header */}
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2 min-w-0">
                <div className="relative flex items-center justify-center w-7 h-7 rounded-lg bg-[#0a0e15] text-[#00e5ff] border border-[#00e5ff]/30">
                  <span
                    className="material-symbols-outlined text-[18px]"
                    style={{ fontVariationSettings: "'FILL' 1" }}
                  >
                    shield
                  </span>
                  <span className="absolute -top-0.5 -right-0.5 w-2 h-2 rounded-full bg-[#7dffa2]"></span>
                </div>
                <div className="flex flex-col min-w-0">
                  <span className="font-headline text-[13px] font-bold text-[#dfe2ed] truncate">
                    Cifrado Cero
                  </span>
                  <span className="font-mono text-[10px] text-[#7dffa2] flex items-center gap-1">
                    <span className="w-1.5 h-1.5 rounded-full bg-[#7dffa2] inline-block"></span>
                    Interceptado en silencio
                  </span>
                </div>
              </div>
              <span className="font-mono text-[10px] text-[#849396] shrink-0">Ahora</span>
            </div>

            {/* Dynamic Content: Call vs SMS */}
            {simulatorTab === 'call' ? (
              <div className="flex items-start gap-3 bg-[#0a0e15] p-3 rounded-xl border border-[#3b494c]/30">
                <div className="w-10 h-10 rounded-lg bg-[#93000a]/30 text-[#ffb4ab] border border-[#ffb4ab]/30 flex items-center justify-center shrink-0">
                  <span className="material-symbols-outlined text-[20px]">phone_disabled</span>
                </div>
                <div className="flex flex-col min-w-0 flex-1">
                  <div className="flex items-center gap-2">
                    <span className="font-mono text-[13px] font-bold text-[#dfe2ed] truncate">
                      +57 312 849 2011
                    </span>
                    <span className="px-1.5 py-0.5 rounded font-mono text-[9px] uppercase font-bold text-white bg-[#b91c1c]">
                      Peligro
                    </span>
                  </div>
                  <span className="font-body text-[12px] text-[#ffb4ab] font-medium mt-0.5">
                    Sospecha de estafa telefónica
                  </span>
                  <p className="font-body text-[11px] text-[#bac9cc] mt-1 leading-snug">
                    Llamada rechazada automáticamente para proteger tu tranquilidad y seguridad.
                  </p>
                </div>
              </div>
            ) : (
              <div className="flex items-start gap-3 bg-[#0a0e15] p-3 rounded-xl border border-[#3b494c]/30">
                <div className="w-10 h-10 rounded-lg bg-[#93000a]/30 text-[#ffb4ab] border border-[#ffb4ab]/30 flex items-center justify-center shrink-0">
                  <span className="material-symbols-outlined text-[20px]">sms_failed</span>
                </div>
                <div className="flex flex-col min-w-0 flex-1">
                  <div className="flex items-center gap-2">
                    <span className="font-mono text-[13px] font-bold text-[#dfe2ed] truncate">
                      SMS: 890123
                    </span>
                    <span className="px-1.5 py-0.5 rounded font-mono text-[9px] uppercase font-bold text-white bg-[#b91c1c]">
                      Engaño
                    </span>
                  </div>
                  <span className="font-body text-[12px] text-[#ffb4ab] font-medium mt-0.5">
                    Enlace potencialmente fraudulento bloqueado
                  </span>
                  <div className="mt-1.5 p-2 bg-[#0f131b] border border-[#3b494c]/40 rounded-lg text-[#dfe2ed] font-mono text-[11px] italic">
                    “Su cuenta ha sido bloqueada temporalmente. Ingrese a enlace-bancario-falso.com para reactivar”
                  </div>
                  <p className="font-body text-[11px] text-[#bac9cc] mt-1 leading-snug">
                    El remitente intentaba suplantar una entidad bancaria para robar credenciales.
                  </p>
                </div>
              </div>
            )}

            {/* Action Buttons */}
            <div className="flex flex-col gap-2">
              <div className="grid grid-cols-2 gap-2">
                <button
                  type="button"
                  onClick={() => showToast('report')}
                  className="flex items-center justify-center gap-1.5 py-2.5 px-3 rounded-xl font-headline text-[13px] font-bold text-white bg-[#dc2626] hover:bg-[#b91c1c] active:scale-[0.98] transition-all cursor-pointer shadow-md"
                >
                  <span className="material-symbols-outlined text-[18px]">block</span>
                  <span>Reportar</span>
                </button>

                <button
                  type="button"
                  onClick={() => showToast('trust')}
                  className="flex items-center justify-center gap-1.5 py-2.5 px-3 bg-[#31353d] hover:bg-[#353941] text-[#dfe2ed] rounded-xl font-headline text-[13px] font-bold border border-[#7dffa2]/50 active:scale-[0.98] transition-all cursor-pointer shadow-sm"
                >
                  <span className="material-symbols-outlined text-[18px] text-[#7dffa2]">
                    verified_user
                  </span>
                  <span>De confianza</span>
                </button>
              </div>

              <button
                type="button"
                onClick={() => showToast('dismiss')}
                className="w-full py-1 text-center text-[#849396] hover:text-[#dfe2ed] font-body text-[12px] transition-colors cursor-pointer"
              >
                Descartar notificación
              </button>
            </div>
          </div>
        ) : (
          <div className="p-4 bg-[#181c23] rounded-xl border border-[#3b494c]/30 text-center animate-fadeIn">
            <span className="font-mono text-xs text-[#bac9cc]">
              Notificación descartada del protector
            </span>
            <button
              onClick={() => setCardDismissed(false)}
              className="mt-2 block mx-auto px-3 py-1 bg-[#00e5ff] text-[#00363d] rounded-lg font-mono text-[11px] font-semibold cursor-pointer"
            >
              Simular otra interceptación
            </button>
          </div>
        )}

        {/* Feedback Toast Banner */}
        {toastFeedback && (
          <div className="p-3 bg-[#1c2027] rounded-xl border border-[#00e5ff]/30 flex items-center gap-2.5 animate-fadeIn">
            <span className={`material-symbols-outlined text-[20px] ${toastFeedback.color}`}>
              {toastFeedback.icon}
            </span>
            <span className="font-body text-[12px] text-[#dfe2ed] flex-1">
              {toastFeedback.text}
            </span>
          </div>
        )}
      </div>

      {/* Educational & Reassurance Explanatory Card */}
      <div className="w-full bg-[#1c2027] rounded-2xl p-4 sm:p-5 flex flex-col gap-4 shadow-md border border-[#3b494c]/20">
        <div className="flex items-center gap-2">
          <span className="material-symbols-outlined text-[#00e5ff] text-[22px]">
            help_outline
          </span>
          <h3 className="font-headline text-[16px] font-bold text-[#dfe2ed]">
            ¿Qué hace cada opción?
          </h3>
        </div>

        {/* Comparison Rows */}
        <div className="flex flex-col gap-3">
          {/* Explanation: Report */}
          <div className="flex items-start gap-3 p-3.5 rounded-xl bg-[#181c23] border border-[#ffb4ab]/20">
            <div className="w-8 h-8 rounded-lg bg-[#93000a]/30 text-[#ffb4ab] border border-[#ffb4ab]/30 flex items-center justify-center shrink-0 mt-0.5">
              <span className="material-symbols-outlined text-[18px]">block</span>
            </div>
            <div className="flex flex-col">
              <span className="font-headline text-[13px] font-bold text-[#dfe2ed]">
                Si tocas Reportar
              </span>
              <span className="font-body text-[12px] text-[#bac9cc] mt-0.5 leading-relaxed">
                Este número nunca más sonará en tu teléfono y sumas tu voto anónimo para advertir a otros miembros de la comunidad.
              </span>
            </div>
          </div>

          {/* Explanation: Trust */}
          <div className="flex items-start gap-3 p-3.5 rounded-xl bg-[#181c23] border border-[#7dffa2]/20">
            <div className="w-8 h-8 rounded-lg bg-[#7dffa2]/15 text-[#7dffa2] border border-[#7dffa2]/30 flex items-center justify-center shrink-0 mt-0.5">
              <span className="material-symbols-outlined text-[18px]">verified_user</span>
            </div>
            <div className="flex flex-col">
              <span className="font-headline text-[13px] font-bold text-[#dfe2ed]">
                Número de confianza (Lista permitida)
              </span>
              <span className="font-body text-[12px] text-[#bac9cc] mt-0.5 leading-relaxed">
                Agrega este número a tu lista permitida exclusiva en este dispositivo. Sus llamadas y mensajes entrarán siempre con normalidad y nunca más serán interceptados ni bloqueados.
              </span>
            </div>
          </div>
        </div>

        {/* Zero-Knowledge & Privacy Assurance Footer */}
        <div className="flex items-start gap-2 pt-1 text-[#bac9cc] border-t border-[#31353d]/50">
          <span className="material-symbols-outlined text-[#00e5ff] text-[18px] shrink-0 mt-0.5">
            lock
          </span>
          <p className="font-body text-[11px] leading-relaxed">
            <strong className="text-[#dfe2ed] font-medium mr-1">
              Tu elección es 100% privada.
            </strong>
            No compartimos tus contactos, tu identidad ni ninguna información personal con terceros o servidores centrales.
          </p>
        </div>
      </div>
    </div>
  );
};
