/* ============================================================
   LaSource — Client API (wrapper fetch)
   Tous les appels HTTP au backend passent par l'objet API global.
   - Cookies de session HttpOnly transmis automatiquement
   - JSON sérialisé/parsé automatiquement
   - Erreurs serveur (4xx/5xx) levées comme exceptions JS exploitables
   ============================================================ */

const API_BASE = '/api';

const API = {
  async _appel(methode, chemin, corps) {
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
      throw new ApiErreur(0, 'Connexion au serveur impossible. Vérifiez votre réseau.');
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

  get(chemin)          { return this._appel('GET',    chemin); },
  post(chemin, corps)  { return this._appel('POST',   chemin, corps); },
  put(chemin, corps)   { return this._appel('PUT',    chemin, corps); },
  delete(chemin)       { return this._appel('DELETE', chemin); },
};

class ApiErreur extends Error {
  constructor(statut, message, donnees) {
    super(message);
    this.statut = statut;
    this.donnees = donnees;
  }
}

/* Session courante (chargée au boot via /api/profil/moi).
   null si pas encore connecté. */
const SESSION = { utilisateur: null };

async function initialiserSession() {
  try {
    SESSION.utilisateur = await API.get('/profil/moi');
  } catch (err) {
    SESSION.utilisateur = null;   // 401 = pas connecté, normal au démarrage
  }
  return SESSION;
}

/* Compatibilité avec l'ancienne API (mode démo retiré).
   MODE.api est toujours true ; MODE.utilisateur est lié à SESSION. */
const MODE = {
  get api() { return true; },
  set api(_) { /* no-op : il n'y a plus de mode démo */ },
  get utilisateur() { return SESSION.utilisateur; },
  set utilisateur(v) { SESSION.utilisateur = v; },
};

/* Alias pour conserver l'ancien nom d'init.
   Toujours appelable, ne fait plus de fallback démo. */
async function initialiserApi() {
  await initialiserSession();
  return MODE;
}
