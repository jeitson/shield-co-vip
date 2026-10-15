import React, { useState } from 'react';

interface LoginScreenProps {
  onSuccess: () => void;
  onGoToRegister: () => void;
}

export const LoginScreen: React.FC<LoginScreenProps> = ({
  onSuccess,
  onGoToRegister,
}) => {
  const [identifier, setIdentifier] = useState('seguridad@nodo.zero');
  const [password, setPassword] = useState('cifradocero2026');
  const [showPassword, setShowPassword] = useState(false);
  const [termsAccepted, setTermsAccepted] = useState(true);
  const [privacyAccepted, setPrivacyAccepted] = useState(true);
  const [loading, setLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!termsAccepted || !privacyAccepted) return;
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      onSuccess();
    }, 1000);
  };

  return (
    <div className="relative flex flex-col flex-1 justify-between w-full max-w-sm mx-auto px-4 py-4 min-h-[calc(100vh-80px)] animate-fadeIn">
      {/* Background Image with Overlay */}
      <div className="fixed inset-0 z-0 pointer-events-none overflow-hidden">
        <img
          src="https://lh3.googleusercontent.com/aida-public/AB6AXuChDd1IDIr2qjYPcytGXAuMd4-8O1LSurgAazuRNVx0Hmf4UxOfZ-5gDB6Gr2aJ6hVKgEiEwRr47LGSRM_E13dGPej6zGP-OGoRcs0IMChPkWDY4vdLOuGg_ZPQLZxNDvM_8WFiS2HfCvWXyfVFgoGL5JybngcbCsTmG3izKK3iYnc3i6_11BWEn5X7RhoOQuaTQlCAUAzuXjSLU50YtpNpltKyrKgutGLVBonO5lerHFzygrr5h_Ap"
          alt="Fondo Tecnológico de Ciberseguridad Cifrada"
          className="w-full h-full object-cover opacity-35"
        />
        <div className="absolute inset-0 bg-gradient-to-b from-[#0f131b]/85 via-[#0f131b]/92 to-[#0f131b]"></div>
      </div>

      <div className="relative z-10 flex flex-col flex-1 justify-between w-full">
        {/* Header: Compact brand & Minimalist Title */}
        <header className="flex flex-col items-center text-center mt-2 mb-6">
          <div className="w-14 h-14 rounded-2xl bg-[#1c2027]/80 border border-[#3b494c]/50 p-2.5 shadow-xl flex items-center justify-center mb-3 backdrop-blur-md">
            <span className="material-symbols-outlined text-[#00e5ff] text-3xl">
              lock_clock
            </span>
          </div>
          <h1 className="font-headline text-[24px] font-bold text-[#dfe2ed] tracking-tight">
            Acceso Seguro
          </h1>
          <p className="font-body text-[12px] text-[#bac9cc] mt-1">
            Cifrado Cero • Enclave Seguro
          </p>
        </header>

        {/* Minimalist Form */}
        <form onSubmit={handleSubmit} className="flex flex-col gap-4 w-full">
          {/* ID / Email Input */}
          <div className="flex flex-col gap-1.5">
            <label
              htmlFor="user-identifier"
              className="font-mono text-[10px] text-[#bac9cc] uppercase tracking-wider font-semibold"
            >
              Identificador o Correo
            </label>
            <div className="relative flex items-center rounded-xl bg-[#181c23]/80 border border-[#3b494c]/60 focus-within:border-[#00e5ff] focus-within:bg-[#1c2027] transition-all backdrop-blur-sm">
              <span className="material-symbols-outlined text-[#849396] ml-3.5 text-lg select-none">
                alternate_email
              </span>
              <input
                id="user-identifier"
                name="identifier"
                type="text"
                value={identifier}
                onChange={(e) => setIdentifier(e.target.value)}
                placeholder="usuario@nodo.zero"
                autoComplete="off"
                required
                className="w-full bg-transparent py-3 pl-3 pr-4 font-body text-[13px] text-[#dfe2ed] placeholder:text-[#849396]/60 focus:outline-none"
              />
            </div>
          </div>

          {/* Password Input */}
          <div className="flex flex-col gap-1.5">
            <div className="flex justify-between items-center">
              <label
                htmlFor="user-key"
                className="font-mono text-[10px] text-[#bac9cc] uppercase tracking-wider font-semibold"
              >
                Clave Maestra
              </label>
              <button
                type="button"
                onClick={() => alert('Para restablecer tu clave en arquitectura Zero-Knowledge, necesitas tu llave de respaldo local.')}
                className="font-mono text-[10px] text-[#00e5ff] hover:underline transition-colors cursor-pointer"
              >
                ¿Olvidaste tu clave?
              </button>
            </div>
            <div className="relative flex items-center rounded-xl bg-[#181c23]/80 border border-[#3b494c]/60 focus-within:border-[#00e5ff] focus-within:bg-[#1c2027] transition-all backdrop-blur-sm">
              <span className="material-symbols-outlined text-[#849396] ml-3.5 text-lg select-none">
                key
              </span>
              <input
                id="user-key"
                name="password"
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••••••"
                autoComplete="current-password"
                required
                className="w-full bg-transparent py-3 pl-3 pr-11 font-body text-[13px] text-[#dfe2ed] placeholder:text-[#849396]/60 focus:outline-none"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                aria-label="Mostrar u ocultar contraseña"
                className="absolute right-2 p-1.5 rounded-lg text-[#849396] hover:text-[#dfe2ed] transition-colors focus:outline-none flex items-center justify-center cursor-pointer"
              >
                <span className="material-symbols-outlined text-xl">
                  {showPassword ? 'visibility_off' : 'visibility'}
                </span>
              </button>
            </div>
          </div>

          {/* Verification Checkboxes */}
          <div className="flex flex-col gap-2.5 pt-1 pb-1">
            <label className="flex items-start gap-2.5 cursor-pointer group">
              <input
                type="checkbox"
                checked={termsAccepted}
                onChange={(e) => setTermsAccepted(e.target.checked)}
                required
                className="mt-0.5 w-4 h-4 rounded border-[#3b494c] bg-[#262a32] text-[#00e5ff] accent-[#00e5ff] focus:outline-none cursor-pointer"
              />
              <span className="font-body text-[12px] text-[#bac9cc] group-hover:text-[#dfe2ed] transition-colors select-none leading-tight">
                Acepto los Términos y Condiciones
              </span>
            </label>

            <label className="flex items-start gap-2.5 cursor-pointer group">
              <input
                type="checkbox"
                checked={privacyAccepted}
                onChange={(e) => setPrivacyAccepted(e.target.checked)}
                required
                className="mt-0.5 w-4 h-4 rounded border-[#3b494c] bg-[#262a32] text-[#00e5ff] accent-[#00e5ff] focus:outline-none cursor-pointer"
              />
              <span className="font-body text-[12px] text-[#bac9cc] group-hover:text-[#dfe2ed] transition-colors select-none leading-tight">
                Entiendo que no se accede a mi agenda ni datos personales
              </span>
            </label>
          </div>

          {/* Primary Action Button */}
          <button
            type="submit"
            disabled={loading}
            className="w-full mt-2 py-3.5 px-6 rounded-xl bg-[#00e5ff] hover:bg-[#9cf0ff] text-[#00363d] font-headline text-[15px] font-bold flex items-center justify-center gap-2 shadow-lg active:scale-[0.98] transition-all focus:outline-none cursor-pointer"
          >
            {loading ? (
              <>
                <span className="material-symbols-outlined text-xl animate-spin">sync</span>
                <span>Descifrando Enclave...</span>
              </>
            ) : (
              <>
                <span>Iniciar Sesión</span>
                <span className="material-symbols-outlined text-xl font-bold">
                  arrow_forward
                </span>
              </>
            )}
          </button>
        </form>

        {/* Bottom Registration Link */}
        <footer className="text-center pb-2 mt-4">
          <p className="font-body text-[13px] text-[#bac9cc]">
            ¿No tienes cuenta?{' '}
            <button
              type="button"
              onClick={onGoToRegister}
              className="text-[#00e5ff] font-semibold hover:underline transition-colors cursor-pointer ml-1"
            >
              Regístrate
            </button>
          </p>
        </footer>
      </div>
    </div>
  );
};
