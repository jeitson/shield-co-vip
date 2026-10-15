import React, { useState } from 'react';

interface RegisterScreenProps {
  onSuccess: () => void;
  onGoToLogin: () => void;
}

export const RegisterScreen: React.FC<RegisterScreenProps> = ({
  onSuccess,
  onGoToLogin,
}) => {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [phone, setPhone] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [termsAccepted, setTermsAccepted] = useState(false);
  const [privacyAccepted, setPrivacyAccepted] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isDone, setIsDone] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!termsAccepted || !privacyAccepted) return;

    setIsSubmitting(true);
    setTimeout(() => {
      setIsSubmitting(false);
      setIsDone(true);
      setTimeout(() => {
        onSuccess();
      }, 1200);
    }, 1200);
  };

  return (
    <div className="relative flex flex-col w-full max-w-sm mx-auto pb-8 animate-fadeIn">
      {/* Dynamic Ambient Background with Overlay Scrim */}
      <div className="fixed inset-0 pointer-events-none -z-10 overflow-hidden">
        <div
          className="w-full h-full bg-cover bg-center opacity-30 transform scale-105"
          style={{
            backgroundImage:
              "url('https://lh3.googleusercontent.com/aida/AEtjO1VQ60WcHop7CWnQz4i5nBJAFy3-Vu1itnc1hY-FJB5ouTfHpRgHWUWKVY0xUltvwmSPpz_jr2HOTo_aXTUfz_d7zH5jvKGhdhii60bg-RKD_Z-09hHSAVMzwJH4OmgJ7n7fvKqRxWZfZpoMqvrGEZoNb3mAJ62kwAxN5pgEwihpw0VkI1pY0ESZ1OTaOwaIV0DelQm-uMezoj-w3GLPEC6Girq62ebldZXcXq16wV7TqFId9saEqKUZ7Q')",
          }}
        ></div>
        <div className="absolute inset-0 bg-gradient-to-b from-[#0f131b]/95 via-[#0a0e15]/90 to-[#0f131b]"></div>
      </div>

      {/* Header Section */}
      <header className="flex flex-col items-center text-center mt-2 mb-4 px-1">
        <div className="w-12 h-12 rounded-2xl bg-[#262a32] border border-[#3b494c]/40 flex items-center justify-center mb-2 shadow-md">
          <span
            className="material-symbols-outlined text-[#00e5ff] text-2xl"
            style={{ fontVariationSettings: "'FILL' 1" }}
          >
            security
          </span>
        </div>
        <h1 className="font-headline text-[24px] font-bold text-[#dfe2ed] tracking-tight">
          Crear cuenta
        </h1>
        <p className="font-body text-[12px] text-[#bac9cc] mt-0.5">
          Crea tu cuenta para comenzar tu blindaje
        </p>
      </header>

      {/* Inviolable Privacy Callout Banner */}
      <div className="mb-4 rounded-xl bg-[#181c23] border border-[#3b494c]/30 p-3.5 shadow-sm relative overflow-hidden">
        <div className="absolute left-0 top-0 bottom-0 w-1 bg-[#05e777]"></div>
        <div className="flex items-start gap-3">
          <div className="w-8 h-8 rounded-lg bg-[#1c2027] border border-[#7dffa2]/30 flex-shrink-0 flex items-center justify-center mt-0.5">
            <span
              className="material-symbols-outlined text-[#7dffa2] text-lg"
              style={{ fontVariationSettings: "'FILL' 1" }}
            >
              phonelink_lock
            </span>
          </div>
          <div className="flex-1 min-w-0">
            <div className="flex items-center gap-1.5 mb-0.5">
              <span className="font-mono text-[10px] text-[#7dffa2] font-semibold tracking-wide uppercase">
                Garantía Absoluta
              </span>
              <span className="inline-block w-1.5 h-1.5 rounded-full bg-[#7dffa2] animate-pulse"></span>
            </div>
            <p className="font-body text-[11px] text-[#bac9cc] leading-relaxed">
              Nosotros no recolectamos datos de tu agenda telefónica ni contactos personales. Tus datos viajan cifrados de extremo a extremo.
            </p>
          </div>
        </div>
      </div>

      {/* Registration Form Card */}
      <form
        onSubmit={handleSubmit}
        className="flex flex-col gap-3.5 bg-[#181c23]/90 backdrop-blur-md p-4 rounded-2xl shadow-xl border border-[#3b494c]/40"
      >
        {/* First Name & Last Name (Side by side) */}
        <div className="grid grid-cols-2 gap-2.5">
          <div className="flex flex-col gap-1 min-w-0">
            <label className="font-mono text-[10px] text-[#bac9cc] flex items-center justify-between">
              <span>Nombre <span className="text-[#00e5ff]">*</span></span>
            </label>
            <div className="relative flex items-center rounded-lg bg-[#0a0e15] border border-[#3b494c]/40 focus-within:border-[#00e5ff] transition-colors">
              <span className="material-symbols-outlined text-[#849396] text-lg absolute left-2.5 pointer-events-none">
                person
              </span>
              <input
                type="text"
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
                placeholder="ej. Carlos"
                required
                className="w-full bg-transparent py-2.5 pl-8 pr-2 font-body text-[13px] text-[#dfe2ed] placeholder:text-[#849396]/60 focus:outline-none"
              />
            </div>
          </div>

          <div className="flex flex-col gap-1 min-w-0">
            <label className="font-mono text-[10px] text-[#bac9cc] flex items-center justify-between">
              <span>Apellido <span className="text-[#00e5ff]">*</span></span>
            </label>
            <div className="relative flex items-center rounded-lg bg-[#0a0e15] border border-[#3b494c]/40 focus-within:border-[#00e5ff] transition-colors">
              <input
                type="text"
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
                placeholder="ej. Rodríguez"
                required
                className="w-full bg-transparent py-2.5 px-3 font-body text-[13px] text-[#dfe2ed] placeholder:text-[#849396]/60 focus:outline-none"
              />
            </div>
          </div>
        </div>

        {/* Correo Electrónico */}
        <div className="flex flex-col gap-1">
          <label className="font-mono text-[10px] text-[#bac9cc] flex items-center justify-between">
            <span>Correo Electrónico <span className="text-[#00e5ff]">*</span></span>
          </label>
          <div className="relative flex items-center rounded-lg bg-[#0a0e15] border border-[#3b494c]/40 focus-within:border-[#00e5ff] transition-colors">
            <span className="material-symbols-outlined text-[#849396] text-lg absolute left-2.5 pointer-events-none">
              alternate_email
            </span>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="ej. usuario@proton.me"
              required
              className="w-full bg-transparent py-2.5 pl-8 pr-3 font-body text-[13px] text-[#dfe2ed] placeholder:text-[#849396]/60 focus:outline-none"
            />
          </div>
        </div>

        {/* Contraseña con Mask Toggle */}
        <div className="flex flex-col gap-1">
          <div className="flex items-center justify-between">
            <label className="font-mono text-[10px] text-[#bac9cc]">
              Contraseña <span className="text-[#00e5ff]">*</span>
            </label>
            <span className="font-mono text-[9px] text-[#849396]">Mín. 8 caracteres</span>
          </div>
          <div className="relative flex items-center rounded-lg bg-[#0a0e15] border border-[#3b494c]/40 focus-within:border-[#00e5ff] transition-colors">
            <span className="material-symbols-outlined text-[#849396] text-lg absolute left-2.5 pointer-events-none">
              key
            </span>
            <input
              type={showPassword ? 'text' : 'password'}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              minLength={8}
              placeholder="Mínimo 8 caracteres"
              required
              className="w-full bg-transparent py-2.5 pl-8 pr-10 font-mono text-[12px] text-[#dfe2ed] placeholder:text-[#849396]/60 focus:outline-none"
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              aria-label="Mostrar u ocultar contraseña"
              className="absolute right-2 p-1 text-[#849396] hover:text-[#dfe2ed] cursor-pointer"
            >
              <span className="material-symbols-outlined text-lg">
                {showPassword ? 'visibility_off' : 'visibility'}
              </span>
            </button>
          </div>
        </div>

        {/* Número Celular Compuesto (+57 Colombia lockout) */}
        <div className="flex flex-col gap-1">
          <div className="flex items-center justify-between">
            <label className="font-mono text-[10px] text-[#bac9cc]">
              Número Celular <span className="text-[#00e5ff]">*</span>
            </label>
            <span className="font-mono text-[10px] text-[#7dffa2] flex items-center gap-1 font-semibold">
              <span className="material-symbols-outlined text-xs">verified</span>
              Prefijo bloqueado
            </span>
          </div>

          <div className="flex items-center gap-2">
            {/* Locked Colombia Prefix */}
            <div
              className="flex items-center gap-1 px-2.5 py-2.5 rounded-lg bg-[#262a32] border border-[#3b494c]/50 text-[#dfe2ed] select-none flex-shrink-0 cursor-not-allowed"
              title="Indicativo regional verificado y no modificable (+57 Colombia)"
            >
              <span className="text-sm">🇨🇴</span>
              <span className="font-mono text-[12px] font-bold text-[#dfe2ed]">+57</span>
              <span
                className="material-symbols-outlined text-[#849396] text-xs"
                style={{ fontVariationSettings: "'FILL' 1" }}
              >
                lock
              </span>
            </div>

            {/* Phone Input */}
            <div className="relative flex-1 flex items-center rounded-lg bg-[#0a0e15] border border-[#3b494c]/40 focus-within:border-[#00e5ff] transition-colors min-w-0">
              <span className="material-symbols-outlined text-[#849396] text-lg absolute left-2.5 pointer-events-none">
                phone_iphone
              </span>
              <input
                type="tel"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="ej. 300 123 4567"
                required
                className="w-full bg-transparent py-2.5 pl-8 pr-3 font-mono text-[12px] text-[#dfe2ed] placeholder:text-[#849396]/60 focus:outline-none"
              />
            </div>
          </div>
        </div>

        {/* Obligatory Checkboxes */}
        <div className="flex flex-col gap-2 pt-1">
          <label className="flex items-start gap-2.5 cursor-pointer group">
            <input
              type="checkbox"
              checked={termsAccepted}
              onChange={(e) => setTermsAccepted(e.target.checked)}
              required
              className="mt-0.5 w-4 h-4 rounded border-[#3b494c] bg-[#262a32] text-[#00e5ff] accent-[#00e5ff] cursor-pointer"
            />
            <span className="font-body text-[11px] text-[#bac9cc] group-hover:text-[#dfe2ed] transition-colors leading-snug">
              Acepto los <span className="text-[#00e5ff] underline">Términos y Condiciones</span> y la <span className="text-[#00e5ff] underline">Política de Cero Registros</span> <span className="text-[#00e5ff]">(*)</span>
            </span>
          </label>

          <label className="flex items-start gap-2.5 cursor-pointer group">
            <input
              type="checkbox"
              checked={privacyAccepted}
              onChange={(e) => setPrivacyAccepted(e.target.checked)}
              required
              className="mt-0.5 w-4 h-4 rounded border-[#3b494c] bg-[#262a32] text-[#7dffa2] accent-[#7dffa2] cursor-pointer"
            />
            <span className="font-body text-[11px] text-[#bac9cc] group-hover:text-[#dfe2ed] transition-colors leading-snug">
              Confirmo que he leído que la app <strong className="text-[#dfe2ed] font-semibold">no accederá a mi agenda ni contactos personales</strong> <span className="text-[#00e5ff]">(*)</span>
            </span>
          </label>
        </div>

        {/* Primary Action Button */}
        <button
          type="submit"
          disabled={isSubmitting}
          className={`mt-2 w-full py-3.5 px-4 rounded-xl font-headline text-[15px] font-bold shadow-lg transition-all active:scale-[0.99] flex items-center justify-center gap-2 cursor-pointer ${
            isDone
              ? 'bg-[#05e777] text-[#003918]'
              : isSubmitting
              ? 'bg-[#00daf3] text-[#00363d]'
              : 'bg-[#00e5ff] hover:bg-[#9cf0ff] text-[#00363d]'
          }`}
        >
          {isSubmitting ? (
            <>
              <span className="material-symbols-outlined text-lg animate-spin">progress_activity</span>
              <span>Blindando Identidad...</span>
            </>
          ) : isDone ? (
            <>
              <span
                className="material-symbols-outlined text-lg"
                style={{ fontVariationSettings: "'FILL' 1" }}
              >
                verified_user
              </span>
              <span>Identidad Generada</span>
            </>
          ) : (
            <>
              <span
                className="material-symbols-outlined text-lg"
                style={{ fontVariationSettings: "'FILL' 1" }}
              >
                shield
              </span>
              <span>Crear cuenta</span>
            </>
          )}
        </button>
      </form>

      {/* Bottom Login Link */}
      <footer className="mt-4 text-center">
        <p className="font-body text-[13px] text-[#bac9cc]">
          ¿Ya tienes una cuenta?
          <button
            type="button"
            onClick={onGoToLogin}
            className="text-[#00e5ff] font-semibold ml-1.5 hover:underline transition-colors inline-flex items-center gap-0.5 cursor-pointer"
          >
            <span>Inicia sesión</span>
            <span className="material-symbols-outlined text-sm">arrow_forward</span>
          </button>
        </p>
      </footer>
    </div>
  );
};
