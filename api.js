/* ============================================================
   LaSource — Client API (wrapper fetch)
   Tous les appels HTTP au backend passent par cet objet API global.
   - Cookies de session HttpOnly transmis automatiquement.
   - JSON sérialisé/parsé automatiquement.
   - Erreurs serveur (4xx/5xx) levées comme exceptions JS exploitables.
   ============================================================ */

const API_BASE = '/api';

const API = {
  /** Appel HTTP générique. Lance une Error si la réponse n'est pas OK. */
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
      // Réseau coupé, backend éteint, etc.
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

  /** Indique si le serveur backend est accessible. Utilisé au boot. */
  async pingSante() {
    try {
      const r = await fetch(API_BASE + '/sante', { credentials: 'same-origin' });
      return r.ok;
    } catch { return false; }
  },
};

/* Exception typée pour distinguer les erreurs API des autres erreurs JS. */
class ApiErreur extends Error {
  constructor(statut, message, donnees) {
    super(message);
    this.statut = statut;
    this.donnees = donnees;
  }
}

/* ------------------------------------------------------------
   MODE — détecte automatiquement si le backend est joignable.
   - Si oui : MODE.api = true, toutes les fonctions appellent le backend
   - Si non : MODE.api = false, fallback sur les données de démo locales
   Cela permet d'ouvrir index.html en local SANS backend pour démo,
   tout en branchant le backend dès qu'il est lancé.
   ------------------------------------------------------------ */
const MODE = {
  api: false,           // bascule à true après ping santé réussi
  utilisateur: null,    // session courante chargée depuis /api/profil/moi
};

/* Initialisation : à appeler une fois au démarrage. */
async function initialiserApi() {
  MODE.api = await API.pingSante();
  if (MODE.api) {
    try {
      MODE.utilisateur = await API.get('/profil/moi');
    } catch (err) {
      // 401 = non connecté, c'est normal au démarrage public
      MODE.utilisateur = null;
    }
  }
  return MODE;
}
