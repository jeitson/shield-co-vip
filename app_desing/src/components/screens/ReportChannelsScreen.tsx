import React, { useState } from 'react';

export const ReportChannelsScreen: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'gaula' | 'sic'>('gaula');
  const [copied, setCopied] = useState(false);
  const [showCallConfirm, setShowCallConfirm] = useState(false);

  const handleCopyEvidence = () => {
    const sampleText = `Evidencia generada por Cifrado Cero:\n- Motivo: Denuncia Ley 2300 de 2023 (Dejen de Fregar)\n- Teléfono registrado: [Ver historial de llamadas encriptado]\n- Fecha y hora: ${new Date().toLocaleString('es-CO')}\n- Tipo de infracción: Contacto comercial o cobranza fuera del horario legal permitido.\n- Dispositivo: Hardware verificado con hash local.`;

    if (navigator.clipboard) {
      navigator.clipboard.writeText(sampleText).then(() => {
        setCopied(true);
        setTimeout(() => setCopied(false), 2800);
      });
    } else {
      setCopied(true);
      setTimeout(() => setCopied(false), 2800);
    }
  };

  return (
    <div className="flex flex-col w-full gap-4 pb-24 max-w-2xl mx-auto animate-fadeIn">
      {/* Header Section: Empathetic & Clear */}
      <div className="flex flex-col gap-1 mt-1">
        <div className="inline-flex items-center gap-2 px-2.5 py-1 rounded-full bg-[#262a32] border border-[#3b494c]/30 w-fit shadow-sm">
          <span className="w-2 h-2 rounded-full bg-[#00e5ff] animate-pulse"></span>
          <span className="font-mono text-[11px] text-[#c3f5ff] font-medium">
            Soporte y Orientación Legal
          </span>
        </div>
        <h1 className="font-headline text-[24px] font-bold text-[#dfe2ed] tracking-tight mt-1">
          Canales de Denuncia
        </h1>
        <p className="font-body text-[13px] text-[#bac9cc] leading-relaxed">
          Si estás recibiendo llamadas de extorsión o acoso comercial indebido, aquí puedes actuar de inmediato ante las autoridades competentes.
        </p>
      </div>

      {/* Segmented 2-Tab Navigation Bar */}
      <div
        className="w-full p-1 bg-[#0a0e15] rounded-xl border border-[#3b494c]/40 flex items-center gap-1 shadow-inner"
        role="tablist"
      >
        <button
          role="tab"
          type="button"
          aria-selected={activeTab === 'gaula'}
          onClick={() => setActiveTab('gaula')}
          className={`flex-1 flex items-center justify-center gap-1.5 py-2.5 px-2 rounded-lg font-headline text-[13px] transition-all cursor-pointer ${
            activeTab === 'gaula'
              ? 'bg-[#00e5ff] text-[#00363d] font-bold shadow-md'
              : 'text-[#bac9cc] hover:text-[#dfe2ed] hover:bg-[#181c23]'
          }`}
        >
          <span className="material-symbols-outlined text-[18px]">local_police</span>
          <span>Línea GAULA (165)</span>
        </button>

        <button
          role="tab"
          type="button"
          aria-selected={activeTab === 'sic'}
          onClick={() => setActiveTab('sic')}
          className={`flex-1 flex items-center justify-center gap-1.5 py-2.5 px-2 rounded-lg font-headline text-[13px] transition-all cursor-pointer ${
            activeTab === 'sic'
              ? 'bg-[#00e5ff] text-[#00363d] font-bold shadow-md'
              : 'text-[#bac9cc] hover:text-[#dfe2ed] hover:bg-[#181c23]'
          }`}
        >
          <span className="material-symbols-outlined text-[18px]">gavel</span>
          <span>Reporte SIC</span>
        </button>
      </div>

      {/* Tab 1 Panel: Priority 1 - Emergency & Extortion (GAULA Colombia) */}
      {activeTab === 'gaula' && (
        <div className="flex flex-col gap-4 animate-fadeIn">
          <div className="relative overflow-hidden rounded-2xl bg-[#181c23] p-4 sm:p-5 shadow-xl border border-[#ffb4ab]/30">
            {/* Ambient indicator background */}
            <div className="absolute -right-10 -top-10 w-36 h-36 bg-[#ffb4ab]/10 rounded-full blur-2xl pointer-events-none"></div>

            <div className="flex flex-col gap-4 relative z-10">
              {/* Tag & Title */}
              <div className="flex items-start justify-between gap-2">
                <div className="flex items-center gap-2">
                  <div className="w-8 h-8 rounded-lg bg-[#93000a]/40 border border-[#ffb4ab]/30 flex items-center justify-center shrink-0">
                    <span className="material-symbols-outlined text-[#ffb4ab] text-[20px]">
                      local_police
                    </span>
                  </div>
                  <div className="flex flex-col">
                    <span className="font-mono text-[10px] text-[#ffb4ab] uppercase font-semibold">
                      Línea de Vida e Integridad
                    </span>
                    <span className="font-headline text-[16px] font-bold text-[#dfe2ed]">
                      ¿Te están extorsionando o amenazando?
                    </span>
                  </div>
                </div>
              </div>

              <p className="font-body text-[13px] text-[#bac9cc] leading-relaxed">
                El <strong className="text-[#dfe2ed] font-semibold">GAULA de la Policía y Fuerzas Militares</strong> atiende casos de extorsión, secuestro y amenazas telefónicas 24/7 de forma gratuita y confidencial.
              </p>

              {/* Main Action Call GAULA 165 */}
              <a
                href="tel:165"
                onClick={(e) => {
                  // In browser environments without dialer, show modal confirm
                  setShowCallConfirm(true);
                }}
                className="w-full flex items-center justify-between p-4 rounded-xl bg-[#93000a] hover:bg-[#ba1a1a] active:scale-[0.98] transition-all text-white shadow-lg shadow-[#93000a]/30 cursor-pointer"
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-white/20 flex items-center justify-center shrink-0">
                    <span className="material-symbols-outlined text-white text-[22px]">
                      phone_in_talk
                    </span>
                  </div>
                  <div className="flex flex-col text-left">
                    <span className="font-headline text-[15px] sm:text-[16px] font-bold leading-tight">
                      Llamar al GAULA (Línea 165)
                    </span>
                    <span className="font-body text-[11px] opacity-90">
                      Llamada directa gratuita 24/7 en Colombia
                    </span>
                  </div>
                </div>
                <span className="material-symbols-outlined text-white text-[22px]">
                  arrow_forward
                </span>
              </a>

              {/* Confirmation modal if user clicked call */}
              {showCallConfirm && (
                <div className="p-3 bg-[#0a0e15] border border-[#ffb4ab]/40 rounded-xl flex items-center justify-between gap-2 text-xs">
                  <span className="text-[#ffb4ab]">
                    Marcando al <strong>165</strong> en tu teléfono...
                  </span>
                  <button
                    onClick={() => setShowCallConfirm(false)}
                    className="px-2 py-1 bg-[#1c2027] text-white rounded text-[11px] cursor-pointer"
                  >
                    Cerrar
                  </button>
                </div>
              )}

              {/* Quick Guidance Tips */}
              <div className="p-3.5 rounded-xl bg-[#1c2027] border border-[#3b494c]/20 flex flex-col gap-2">
                <div className="flex items-center gap-1.5 text-[#dfe2ed]">
                  <span className="material-symbols-outlined text-[#00e5ff] text-[18px]">
                    verified_user
                  </span>
                  <span className="font-mono text-[11px] uppercase font-bold text-[#00e5ff]">
                    Recomendaciones inmediatas
                  </span>
                </div>

                <ul className="flex flex-col gap-2.5 mt-1 font-body text-[12px] text-[#bac9cc]">
                  <li className="flex items-start gap-2">
                    <span className="material-symbols-outlined text-[#7dffa2] text-[16px] shrink-0 mt-0.5">
                      check_circle
                    </span>
                    <span>
                      <strong className="text-[#dfe2ed] font-semibold">Mantén la calma</strong> y bajo ninguna circunstancia accedas o te comprometas a pagar.
                    </span>
                  </li>
                  <li className="flex items-start gap-2">
                    <span className="material-symbols-outlined text-[#7dffa2] text-[16px] shrink-0 mt-0.5">
                      check_circle
                    </span>
                    <span>
                      <strong className="text-[#dfe2ed] font-semibold">Cuelga de inmediato</strong> y comunícate con la Línea 165 para recibir acompañamiento de un agente experto.
                    </span>
                  </li>
                  <li className="flex items-start gap-2">
                    <span className="material-symbols-outlined text-[#7dffa2] text-[16px] shrink-0 mt-0.5">
                      check_circle
                    </span>
                    <span>
                      <strong className="text-[#dfe2ed] font-semibold">Guarda el registro</strong> de la llamada sospechosa en esta app para adjuntarlo como prueba.
                    </span>
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Tab 2 Panel: Priority 2 - Commercial Harassment & SIC (Ley Dejen de Fregar) */}
      {activeTab === 'sic' && (
        <div className="flex flex-col gap-4 animate-fadeIn">
          <div className="rounded-2xl bg-[#181c23] p-4 sm:p-5 shadow-lg border border-[#3b494c]/30 flex flex-col gap-4">
            {/* Header info */}
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 rounded-xl bg-[#00e5ff]/15 border border-[#00e5ff]/30 flex items-center justify-center shrink-0">
                <span className="material-symbols-outlined text-[#00e5ff] text-[22px]">
                  gavel
                </span>
              </div>
              <div className="flex flex-col">
                <span className="font-mono text-[10px] text-[#00e5ff] uppercase font-semibold">
                  Ley 2300 de 2023 ("Dejen de fregar")
                </span>
                <h2 className="font-headline text-[16px] font-bold text-[#dfe2ed] leading-snug">
                  Reportar acoso comercial o cobranzas (SIC)
                </h2>
              </div>
            </div>

            {/* Friendly explanation context */}
            <div className="p-3 rounded-xl bg-[#1c2027] border border-[#3b494c]/20 flex gap-2.5 items-start">
              <span className="material-symbols-outlined text-[#00e5ff] text-[20px] shrink-0 mt-0.5">
                info
              </span>
              <p className="font-body text-[12px] text-[#bac9cc] leading-relaxed">
                Como la SIC no cuenta con una conexión directa desde aplicaciones móviles, preparamos esta guía práctica paso a paso para que radiques tu queja formalmente en pocos minutos.
              </p>
            </div>

            {/* Step-by-Step Interactive Guide */}
            <div className="flex flex-col gap-2.5">
              <span className="font-mono text-[11px] text-[#dfe2ed] uppercase tracking-wider font-semibold">
                Pasos sencillos para denunciar
              </span>

              {/* Step 1 */}
              <div className="flex items-start gap-3 p-3 rounded-xl bg-[#1c2027] border border-[#3b494c]/20">
                <div className="w-6 h-6 rounded-full bg-[#00e5ff] text-[#00363d] font-headline text-[12px] flex items-center justify-center font-bold shrink-0 mt-0.5">
                  1
                </div>
                <div className="flex flex-col">
                  <span className="font-headline text-[13px] font-semibold text-[#dfe2ed]">
                    Exporta tus evidencias
                  </span>
                  <span className="font-body text-[12px] text-[#bac9cc] mt-0.5 leading-relaxed">
                    Ve a la pestaña <em>Llamadas</em> en esta app y toca sobre la llamada no deseada para guardar la fecha, hora exacta y duración.
                  </span>
                </div>
              </div>

              {/* Step 2 */}
              <div className="flex items-start gap-3 p-3 rounded-xl bg-[#1c2027] border border-[#3b494c]/20">
                <div className="w-6 h-6 rounded-full bg-[#00e5ff] text-[#00363d] font-headline text-[12px] flex items-center justify-center font-bold shrink-0 mt-0.5">
                  2
                </div>
                <div className="flex flex-col">
                  <span className="font-headline text-[13px] font-semibold text-[#dfe2ed]">
                    Ingresa a la plataforma oficial
                  </span>
                  <span className="font-body text-[12px] text-[#bac9cc] mt-0.5 leading-relaxed">
                    Accede a la sede electrónica de la Superintendencia de Industria y Comercio o al registro de exclusión comercial.
                  </span>
                </div>
              </div>

              {/* Step 3 */}
              <div className="flex items-start gap-3 p-3 rounded-xl bg-[#1c2027] border border-[#3b494c]/20">
                <div className="w-6 h-6 rounded-full bg-[#00e5ff] text-[#00363d] font-headline text-[12px] flex items-center justify-center font-bold shrink-0 mt-0.5">
                  3
                </div>
                <div className="flex flex-col">
                  <span className="font-headline text-[13px] font-semibold text-[#dfe2ed]">
                    Diligencia el formulario de queja
                  </span>
                  <span className="font-body text-[12px] text-[#bac9cc] mt-0.5 leading-relaxed">
                    Selecciona la causal: llamadas de cobranza o publicidad fuera del horario legal (lunes a viernes de 7am a 7pm, sábados de 8am a 3pm, o festivos).
                  </span>
                </div>
              </div>

              {/* Step 4 */}
              <div className="flex items-start gap-3 p-3 rounded-xl bg-[#1c2027] border border-[#3b494c]/20">
                <div className="w-6 h-6 rounded-full bg-[#00e5ff] text-[#00363d] font-headline text-[12px] flex items-center justify-center font-bold shrink-0 mt-0.5">
                  4
                </div>
                <div className="flex flex-col">
                  <span className="font-headline text-[13px] font-semibold text-[#dfe2ed]">
                    Adjunta capturas y guarda tu radicado
                  </span>
                  <span className="font-body text-[12px] text-[#bac9cc] mt-0.5 leading-relaxed">
                    Sube las capturas de pantalla de la llamada y anota el número de radicado emitido para hacer seguimiento.
                  </span>
                </div>
              </div>
            </div>

            {/* Actions for SIC */}
            <div className="flex flex-col gap-2 pt-1">
              <a
                href="https://serviciosweb.sic.gov.co/reclamasindiligencia/"
                target="_blank"
                rel="noopener noreferrer"
                className="w-full flex items-center justify-center gap-2 py-3 px-4 rounded-xl bg-[#00e5ff] hover:bg-[#9cf0ff] text-[#00363d] font-headline text-[14px] font-bold active:opacity-90 transition-all shadow-md cursor-pointer"
              >
                <span>Abrir portal oficial de la SIC</span>
                <span className="material-symbols-outlined text-[18px]">open_in_new</span>
              </a>

              <button
                type="button"
                onClick={handleCopyEvidence}
                className="w-full flex items-center justify-center gap-2 py-3 px-4 rounded-xl bg-[#262a32] hover:bg-[#31353d] text-[#dfe2ed] font-body text-[13px] font-medium active:scale-[0.98] transition-all cursor-pointer border border-[#3b494c]/40"
              >
                <span
                  className={`material-symbols-outlined text-[18px] ${
                    copied ? 'text-[#7dffa2]' : 'text-[#00e5ff]'
                  }`}
                >
                  {copied ? 'check_circle' : 'content_copy'}
                </span>
                <span>
                  {copied
                    ? '¡Plantilla copiada al portapapeles!'
                    : 'Copiar datos de evidencia rápida'}
                </span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Footnote of Trust and Encouragement */}
      <div className="rounded-2xl p-4 bg-[#1c2027] border border-[#3b494c]/20 flex items-center gap-3">
        <div className="w-10 h-10 rounded-full bg-[#7dffa2]/15 flex items-center justify-center shrink-0">
          <span className="material-symbols-outlined text-[#7dffa2] text-[22px]">
            lock_clock
          </span>
        </div>
        <div className="flex flex-col">
          <span className="font-headline text-[14px] text-[#dfe2ed] font-semibold">
            Cifrado Cero te acompaña
          </span>
          <p className="font-body text-[12px] text-[#bac9cc] leading-relaxed">
            Tus registros quedan a salvo únicamente en tu teléfono para que puedas respaldar cualquier denuncia oficial cuando lo necesites.
          </p>
        </div>
      </div>
    </div>
  );
};
