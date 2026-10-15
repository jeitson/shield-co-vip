export type ThreatLevel = 'ALTO' | 'MEDIO' | 'BAJO';

export type EventType = 'call' | 'sms';

export interface InterceptedEvent {
  id: string;
  sender: string;
  type: EventType;
  level: ThreatLevel;
  timestamp: string;
  threatTitle: string;
  reputationTag: string;
  diagnosis: string;
  quarantinedContent?: string;
  isTrusted?: boolean;
  isBlacklisted?: boolean;
  details?: {
    location?: string;
    duration?: string;
    carrier?: string;
    attempts?: number;
  };
}

export interface ShieldConfig {
  extorsion: boolean;
  callcenter: boolean;
  ley: boolean;
}

export type ActiveScreen = 
  | 'shield' 
  | 'calls' 
  | 'report' 
  | 'simulator' 
  | 'advanced' 
  | 'detail' 
  | 'login' 
  | 'register';
