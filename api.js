/* ============================================================
   LaSource — Client API + stockage navigateur (localStorage)
   ------------------------------------------------------------
   - Si un backend Flask répond sur /api/sante : tout passe par le
     réseau (vraie base de données, persistance serveur).
   - Sinon (ex. GitHub Pages, hébergement statique) : bascule
     automatiquement en mode navigateur. Les comptes, questions et
     interactions sont stockés dans localStorage et PERSISTENT entre
     les rechargements de page.
   ============================================================ */

const API_BASE = '/api';

/* État de disponibilité du backend (déterminé une fois au démarrage). */
const Backend = { detecte: false, disponible: false };

const API = {
  async _reseau(methode, chemin, corps) {
    const opts = {
      method: methode,
      headers: { 'Accept': 'application/json' },
      credentials: 'same-origin',
    };
    if (corps !== undefined && corps !== null) {
      opts.headers['Content-Type'] = 'application/json';
      opts.body = JSON.stringify(corps);
    }
    let reponse;
    try {
      reponse = await fetch(API_BASE + chemin, opts);
    } catch (err) {
      throw new ApiErreur(0, 'Connexion au serveur impossible.');
    }
    let donnees = null;
    const type = reponse.headers.get('Content-Type') || '';
    if (type.includes('application/json')) {
      try { donnees = await reponse.json(); } catch { donnees = null; }
    }
    if (!reponse.ok) {
      const message = (donnees && donnees.erreur) || `Erreur ${reponse.status}`;
      throw new ApiErreur(reponse.status, message, donnees);
    }
    return donnees;
  },

  get(chemin)          { return this._reseau('GET',    chemin); },
  post(chemin, corps)  { return this._reseau('POST',   chemin, corps); },
  put(chemin, corps)   { return this._reseau('PUT',    chemin, corps); },
  delete(chemin)       { return this._reseau('DELETE', chemin); },
};

class ApiErreur extends Error {
  constructor(statut, message, donnees) {
    super(message);
    this.statut = statut;
    this.donnees = donnees;
  }
}

/* ------------------------------------------------------------
   Détection du backend au démarrage.
   ------------------------------------------------------------ */
async function detecterBackend() {
  try {
    const r = await fetch(API_BASE + '/sante', { credentials: 'same-origin' });
    const j = r.ok ? await r.json() : null;
    Backend.disponible = !!(j && j.statut === 'ok');
  } catch {
    Backend.disponible = false;
  }
  Backend.detecte = true;
  return Backend.disponible;
}

/* ============================================================
   STOCKAGE NAVIGATEUR — comptes et session (mode hors-serveur)
   ============================================================ */

const Comptes = {
  CLE: 'lasource_comptes_v2',
  CLE_SESSION: 'lasource_session_v2',

  _hash(mdp) {
    // Obfuscation simple côté navigateur (le vrai backend utilise bcrypt).
    try { return btoa(unescape(encodeURIComponent('ls.' + mdp))); }
    catch { return 'ls.' + mdp; }
  },

  tous() {
    try { return JSON.parse(localStorage.getItem(this.CLE) || '[]'); }
    catch { return []; }
  },
  _sauver(arr) { localStorage.setItem(this.CLE, JSON.stringify(arr)); },

  seed() {
    if (this.tous().length > 0) return;
    const base = [
      { id: 901, prenom: 'Découverte', nom: 'LaSource', email: 'demo@lasource.io',
        role: 'etudiant', pays: 'Bénin', etudes: 'Licence 2 — UAC',
        bio: 'Compte de découverte.', secteurs: ['Technologie','Finance'],
        estAdmin: false, verifie: false },
      { id: 902, prenom: 'Aïcha', nom: 'KOSSOU', email: 'admin@lasource.io',
        role: 'admin', pays: 'Bénin', etudes: 'Master 2 — UAC',
        bio: 'Coordinatrice de la modération.', secteurs: [],
        estAdmin: true, verifie: false },
      { id: 903, prenom: 'Cyrille', nom: 'ASSOGBA', email: 'c.assogba@lasource.io',
        role: 'mentor', pays: 'France', etudes: 'M2 Informatique — Sorbonne',
        bio: 'Ingénieur logiciel, j\'aide sur les projets informatiques.',
        secteurs: ['Technologie','Éducation'], estAdmin: false, verifie: true },
      { id: 904, prenom: 'Olivier', nom: 'DOSSOU', email: 'o.dossou@lasource.io',
        role: 'mentor', pays: 'Bénin', etudes: 'MBA — INSEAD',
        bio: 'Consultant en éducation financière pour les jeunes.',
        secteurs: ['Finance','Entrepreneuriat'], estAdmin: false, verifie: true },
    ];
    // mot de passe commun : Source2026!
    base.forEach(c => { c.mdp = this._hash('Source2026!'); });
    this._sauver(base);
  },

  trouver(email) {
    email = (email || '').trim().toLowerCase();
    return this.tous().find(c => c.email.toLowerCase() === email) || null;
  },

  creer(data) {
    const arr = this.tous();
    if (arr.some(c => c.email.toLowerCase() === data.email.toLowerCase())) {
      throw new ApiErreur(409, 'Cette adresse e-mail est déjà utilisée.');
    }
    const compte = {
      id: Date.now(),
      prenom: data.prenom, nom: data.nom, email: data.email.toLowerCase(),
      mdp: this._hash(data.mot_de_passe),
      role: data.role || 'etudiant',
      pays: data.pays || '', etudes: data.etudes || '', bio: data.bio || '',
      secteurs: data.secteurs || [],
      estAdmin: false, verifie: false,
    };
    arr.push(compte);
    this._sauver(arr);
    return compte;
  },

  verifier(email, mdp) {
    const c = this.trouver(email);
    if (!c) return null;
    return c.mdp === this._hash(mdp) ? c : null;
  },

  majCourant(modif) {
    const arr = this.tous();
    const i = arr.findIndex(c => c.id === this.sessionId());
    if (i >= 0) { Object.assign(arr[i], modif); this._sauver(arr); return arr[i]; }
    return null;
  },

  sessionId() {
    const v = localStorage.getItem(this.CLE_SESSION);
    return v ? parseInt(v) : null;
  },
  ouvrirSession(id) { localStorage.setItem(this.CLE_SESSION, String(id)); },
  fermerSession()   { localStorage.removeItem(this.CLE_SESSION); },
  courant() {
    const id = this.sessionId();
    return id ? this.tous().find(c => c.id === id) || null : null;
  },
};

/* Session courante en mémoire (compatibilité avec script.js). */
const SESSION = { utilisateur: null };

/* MODE.api : true si backend réseau, false si mode navigateur.
   MODE.utilisateur : utilisateur courant. */
const MODE = {
  get api() { return Backend.disponible; },
  set api(_) { /* déterminé par la détection */ },
  get utilisateur() { return SESSION.utilisateur; },
  set utilisateur(v) { SESSION.utilisateur = v; },
};

/* Initialisation appelée au démarrage par script.js. */
async function initialiserApi() {
  await detecterBackend();
  if (Backend.disponible) {
    // Mode serveur : charge la session via cookie
    try { SESSION.utilisateur = await API.get('/profil/moi'); }
    catch { SESSION.utilisateur = null; }
  } else {
    // Mode navigateur : amorce les comptes de démonstration
    Comptes.seed();
    const c = Comptes.courant();
    SESSION.utilisateur = c ? compteVersProfil(c) : null;
  }
  return MODE;
}

/* Convertit un compte localStorage vers le format /profil/moi attendu. */
function compteVersProfil(c) {
  return {
    id_utilisateur: c.id,
    prenom: c.prenom, nom: c.nom, email: c.email,
    role: c.role, pays: c.pays, etudes: c.etudes, bio: c.bio,
    secteurs: (c.secteurs || []).map(s => ({ libelle: s })),
    est_admin: !!c.estAdmin, photo_url: c.photo || null,
    est_verifie: !!c.verifie,
  };
}

/* Alias rétro-compatible. */
async function initialiserSession() { return initialiserApi(); }
