-- =====================================================================
-- LaSource — Données de démonstration réalistes
-- À charger APRÈS schema.sql :  mysql -u root -p lasource < database/seed.sql
--
-- Mots de passe : tous hashés avec bcrypt (12 tours), mot de passe en
-- clair = "Source2026!" pour TOUS les comptes de démonstration.
-- =====================================================================

USE lasource;

-- ----- COMPTE DE DÉMONSTRATION PUBLIC -----
-- Email : demo@lasource.io
-- Mdp   : Source2026!
-- Rôle  : étudiant (avec quelques sauvegardes pour montrer l'app vivante)

-- Hash bcrypt pré-calculé pour "Source2026!" (rounds=12) — vérifié
SET @MDP_DEMO = '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6';

-- ----- UTILISATEURS -----

INSERT INTO utilisateur (prenom, nom, email, telephone, mot_de_passe, role, bio,
                         etudes, id_pays, ville, est_admin, est_actif) VALUES
-- Compte démo public (étudiant)
('Découverte', 'LaSource', 'demo@lasource.io',          '+22900000000', @MDP_DEMO, 'etudiant',
 'Compte de démonstration publique. Connectez-vous pour explorer.',
 'Licence 2 — Université d''Abomey-Calavi', 8, 'Cotonou', FALSE, TRUE),

-- Administrateur de démonstration
('Aïcha', 'KOSSOU', 'admin@lasource.io',               '+22901020304', @MDP_DEMO, 'etudiant',
 'Coordinatrice de la modération LaSource.',
 'Master 2 — UAC', 8, 'Cotonou', TRUE, TRUE),

-- Étudiants
('Fadel',  'AGBO',    'fadel.agbo@etu.uac.bj',       '+22996010101', @MDP_DEMO, 'etudiant',
 'L2 Mathématiques appliquées. Curieux de tout, surtout des bases de données.',
 'L2 Maths-Info — UAC', 8, 'Cotonou', FALSE, TRUE),

('Aïssa',  'DIOP',    'aissa.diop@ucad.sn',          '+221770202020', @MDP_DEMO, 'etudiant',
 'Étudiante en gestion, je prépare un projet de microentreprise.',
 'L3 Gestion — UCAD', 5, 'Dakar', FALSE, TRUE),

('Souley', 'TRAORÉ',  'souley.traore@um6p.ma',       '+212600030303', @MDP_DEMO, 'etudiant',
 'Passionné de data science et d''agriculture intelligente.',
 'M1 Data — UM6P', 6, 'Benguérir', FALSE, TRUE),

('Marielle','HOUNDJI','marielle.h@etu.uac.bj',       '+22995040404', @MDP_DEMO, 'etudiant',
 'Future médecin, beaucoup de questions sur la suite après la 1re année.',
 'PASS — UAC', 8, 'Cotonou', FALSE, TRUE),

-- Mentors confirmés (Africains francophones, profils crédibles)
('Cyrille','ASSOGBA', 'c.assogba@upmc.fr',           '+33612345001', @MDP_DEMO, 'mentor',
 'Ingénieur logiciel à Paris, ex-stagiaire à Cotonou. J''aide les étudiants en informatique sur leurs projets de fin d''études.',
 'M2 Informatique — Sorbonne Université', 1, 'Paris', FALSE, TRUE),

('Léa',    'KAKPO',   'lea.kakpo@bj-finance.com',     '+22997010111', @MDP_DEMO, 'mentor',
 'Analyste financière en banque de financement à Cotonou. Disponible pour parler stages et premiers postes en finance.',
 'M2 Finance — IAE Paris', 8, 'Cotonou', FALSE, TRUE),

('Moustapha','DIALLO','m.diallo@sante-conakry.gn',   '+224622020303', @MDP_DEMO, 'mentor',
 'Médecin généraliste à Conakry, 7 ans d''exercice. Conseil pour les concours de l''internat et la pratique en Afrique de l''Ouest.',
 'Doctorat de médecine — UGAN', 17, 'Conakry', FALSE, TRUE),

('Awa',    'NDIAYE',  'awa.ndiaye@avocat.sn',         '+221771030505', @MDP_DEMO, 'mentor',
 'Avocate au barreau de Dakar, droit des affaires. Je réponds aux questions sur le parcours juridique en Afrique francophone.',
 'Master 2 Droit — UCAD', 5, 'Dakar', FALSE, TRUE),

('Boubacar','SOW',     'b.sow@yebanj.com',             '+22997020202', @MDP_DEMO, 'mentor',
 'Entrepreneur dans la fintech (mobile money), 3 levées de fonds réussies. Je parle volontiers business model et premiers clients.',
 'École de commerce — ESSEC', 8, 'Cotonou', FALSE, TRUE),

('Marie',  'GBESSEMÉHLAN','marie.gbe@scientifique.fr','+33612050606', @MDP_DEMO, 'mentor',
 'Doctorante en mathématiques appliquées à Lyon. Originaire de Lomé. Je conseille sur les bourses de master et les thèses en Europe.',
 'Doctorat — ENS Lyon', 14, 'Lyon', FALSE, TRUE),

('Olivier','DOSSOU',   'o.dossou@invest-coach.com',    '+22997070707', @MDP_DEMO, 'mentor',
 'Consultant en éducation financière et investissement responsable. Spécialisé dans l''accompagnement des jeunes professionnels africains.',
 'CFA + MBA — INSEAD', 8, 'Cotonou', FALSE, TRUE),

('Fatou',  'CISSÉ',    'fatou.cisse@artconcept.ml',    '+22376080808', @MDP_DEMO, 'mentor',
 'Designer graphique et directrice artistique à Bamako. Conseils créatifs et carrière dans les industries culturelles.',
 'Master Arts — INA', 12, 'Bamako', FALSE, TRUE),

('Aristide','EHUI',    'aristide.ehui@dev-ci.com',     '+22501010101', @MDP_DEMO, 'mentor',
 'Développeur full-stack et formateur à Abidjan. J''aime aider les autodidactes à structurer leur apprentissage.',
 'Licence Info — INPHB', 7, 'Abidjan', FALSE, TRUE);

-- ----- DÉTAILS MENTORS -----

INSERT INTO mentor_details (id_utilisateur, est_verifie, dispo, anciennete,
                            delai_reponse, note_moyenne, nb_reponses) VALUES
((SELECT id_utilisateur FROM utilisateur WHERE email='c.assogba@upmc.fr'),
   TRUE,  'disponible', '2 ans',   'sous 24 h', 4.80, 28),
((SELECT id_utilisateur FROM utilisateur WHERE email='lea.kakpo@bj-finance.com'),
   TRUE,  'disponible', '1 an',    'sous 48 h', 4.70, 19),
((SELECT id_utilisateur FROM utilisateur WHERE email='m.diallo@sante-conakry.gn'),
   TRUE,  'occupe',     '3 ans',   'sous 72 h', 4.90, 41),
((SELECT id_utilisateur FROM utilisateur WHERE email='awa.ndiaye@avocat.sn'),
   TRUE,  'disponible', '2 ans',   'sous 24 h', 4.60, 22),
((SELECT id_utilisateur FROM utilisateur WHERE email='b.sow@yebanj.com'),
   FALSE, 'absent',     '1 an',    'sous 1 semaine', 4.40, 12),
((SELECT id_utilisateur FROM utilisateur WHERE email='marie.gbe@scientifique.fr'),
   TRUE,  'disponible', '4 ans',   'sous 48 h', 4.90, 56),
((SELECT id_utilisateur FROM utilisateur WHERE email='o.dossou@invest-coach.com'),
   TRUE,  'disponible', '2 ans',   'sous 24 h', 4.85, 33),
((SELECT id_utilisateur FROM utilisateur WHERE email='fatou.cisse@artconcept.ml'),
   FALSE, 'disponible', '6 mois',  'sous 72 h', 4.50, 8),
((SELECT id_utilisateur FROM utilisateur WHERE email='aristide.ehui@dev-ci.com'),
   TRUE,  'disponible', '3 ans',   'sous 24 h', 4.75, 47);

-- ----- EXPÉRIENCES DES MENTORS -----

INSERT INTO experience (id_utilisateur, type_experience, intitule, periode, ordre) VALUES
((SELECT id_utilisateur FROM utilisateur WHERE email='c.assogba@upmc.fr'),
   'poste',   'Ingénieur logiciel — Doctolib',                       '2022 à aujourd''hui', 1),
((SELECT id_utilisateur FROM utilisateur WHERE email='c.assogba@upmc.fr'),
   'diplome', 'Master 2 Informatique — Sorbonne Université',         '2020-2022',           2),

((SELECT id_utilisateur FROM utilisateur WHERE email='lea.kakpo@bj-finance.com'),
   'poste',   'Analyste financière — Bank of Africa',                '2023 à aujourd''hui', 1),
((SELECT id_utilisateur FROM utilisateur WHERE email='lea.kakpo@bj-finance.com'),
   'diplome', 'Master 2 Finance — IAE Paris',                        '2021-2023',           2),

((SELECT id_utilisateur FROM utilisateur WHERE email='m.diallo@sante-conakry.gn'),
   'poste',   'Médecin généraliste — Cabinet privé Conakry',         '2019 à aujourd''hui', 1),
((SELECT id_utilisateur FROM utilisateur WHERE email='m.diallo@sante-conakry.gn'),
   'diplome', 'Doctorat de médecine — Université Gamal Abdel Nasser','2012-2019',           2),

((SELECT id_utilisateur FROM utilisateur WHERE email='awa.ndiaye@avocat.sn'),
   'poste',   'Avocate associée — Cabinet Ndiaye & Partners',        '2022 à aujourd''hui', 1),
((SELECT id_utilisateur FROM utilisateur WHERE email='awa.ndiaye@avocat.sn'),
   'diplome', 'Master 2 Droit des affaires — UCAD',                  '2018-2020',           2),

((SELECT id_utilisateur FROM utilisateur WHERE email='b.sow@yebanj.com'),
   'poste',   'Co-fondateur & CEO — YeBanj (fintech)',               '2023 à aujourd''hui', 1),
((SELECT id_utilisateur FROM utilisateur WHERE email='b.sow@yebanj.com'),
   'diplome', 'Master Grande École — ESSEC',                         '2019-2022',           2),

((SELECT id_utilisateur FROM utilisateur WHERE email='marie.gbe@scientifique.fr'),
   'poste',   'Doctorante — ENS Lyon (mathématiques appliquées)',    '2022 à aujourd''hui', 1),
((SELECT id_utilisateur FROM utilisateur WHERE email='marie.gbe@scientifique.fr'),
   'diplome', 'Agrégation de mathématiques',                         '2021',                2),

((SELECT id_utilisateur FROM utilisateur WHERE email='o.dossou@invest-coach.com'),
   'poste',   'Consultant en éducation financière — indépendant',    '2022 à aujourd''hui', 1),
((SELECT id_utilisateur FROM utilisateur WHERE email='o.dossou@invest-coach.com'),
   'diplome', 'MBA — INSEAD',                                        '2019-2020',           2),

((SELECT id_utilisateur FROM utilisateur WHERE email='aristide.ehui@dev-ci.com'),
   'poste',   'Développeur full-stack — Orange CI',                  '2021 à aujourd''hui', 1),
((SELECT id_utilisateur FROM utilisateur WHERE email='aristide.ehui@dev-ci.com'),
   'diplome', 'Licence Informatique — INPHB Yamoussoukro',           '2017-2020',           2);

-- ----- SECTEURS D'EXPERTISE DES MENTORS -----

INSERT INTO utilisateur_secteur (id_utilisateur, id_secteur)
SELECT u.id_utilisateur, s.id_secteur FROM utilisateur u, secteur s WHERE
  (u.email='c.assogba@upmc.fr'           AND s.libelle IN ('Technologie','Éducation'))
  OR (u.email='lea.kakpo@bj-finance.com'    AND s.libelle IN ('Finance','Entrepreneuriat'))
  OR (u.email='m.diallo@sante-conakry.gn'   AND s.libelle IN ('Médecine','Sciences'))
  OR (u.email='awa.ndiaye@avocat.sn'        AND s.libelle IN ('Droit','Entrepreneuriat'))
  OR (u.email='b.sow@yebanj.com'            AND s.libelle IN ('Entrepreneuriat','Finance','Technologie'))
  OR (u.email='marie.gbe@scientifique.fr'   AND s.libelle IN ('Sciences','Éducation','Ingénierie'))
  OR (u.email='o.dossou@invest-coach.com'   AND s.libelle IN ('Finance','Entrepreneuriat','Éducation'))
  OR (u.email='fatou.cisse@artconcept.ml'   AND s.libelle IN ('Arts','Communication'))
  OR (u.email='aristide.ehui@dev-ci.com'    AND s.libelle IN ('Technologie','Éducation'))
  -- Étudiants
  OR (u.email='demo@lasource.io'            AND s.libelle IN ('Technologie','Finance'))
  OR (u.email='fadel.agbo@etu.uac.bj'       AND s.libelle IN ('Technologie','Sciences'))
  OR (u.email='aissa.diop@ucad.sn'          AND s.libelle IN ('Entrepreneuriat','Finance'))
  OR (u.email='souley.traore@um6p.ma'       AND s.libelle IN ('Technologie','Agriculture'))
  OR (u.email='marielle.h@etu.uac.bj'       AND s.libelle IN ('Médecine','Sciences'));

-- ----- QUESTIONS RÉALISTES, ANCRÉES AFRIQUE FRANCOPHONE -----

INSERT INTO question (id_auteur, titre, corps, id_secteur, publiee_le)
SELECT u.id_utilisateur, q.titre, q.corps,
       (SELECT id_secteur FROM secteur WHERE libelle = q.secteur LIMIT 1),
       DATE_SUB(NOW(), INTERVAL q.jours_avant DAY)
FROM utilisateur u JOIN (
  SELECT 'fadel.agbo@etu.uac.bj' AS email, 'Comment réussir le partiel de structures de données en L2 ?' AS titre,
   'Le partiel approche et je galère sur les arbres binaires de recherche. Quels exercices pratiques recommandez-vous pour bien comprendre les insertions et suppressions ?' AS corps,
   'Technologie' AS secteur, 2 AS jours_avant UNION ALL

  SELECT 'aissa.diop@ucad.sn', 'Comment lancer une petite activité pendant mes études sans bloquer mon emploi du temps ?',
   'Je suis en L3 gestion à Dakar et je voudrais lancer une petite activité de vente de produits cosmétiques. Comment équilibrer mes cours et un démarrage d''activité ?',
   'Entrepreneuriat', 4 UNION ALL

  SELECT 'souley.traore@um6p.ma', 'Bourse de doctorat en France après un master en data au Maroc, par où commencer ?',
   'Je termine mon M1 en data science et je vise un doctorat en France. Quelles bourses (Eiffel, AUF, autres) regarder en priorité et quand commencer les démarches ?',
   'Sciences', 1 UNION ALL

  SELECT 'marielle.h@etu.uac.bj', 'PASS validé, et après ? Spécialisation ou médecine générale ?',
   'Je viens de valider ma PASS à Cotonou et je dois choisir une orientation. J''hésite entre médecine générale pour rentrer plus vite en activité ou tenter une spécialisation.',
   'Médecine', 6 UNION ALL

  SELECT 'fadel.agbo@etu.uac.bj', 'Apprendre Python pour la data en parallèle de mes cours de maths, par où débuter ?',
   'Mes cours actuels sont surtout théoriques. Je veux apprendre Python pour la data en parallèle. Quels projets concrets simples conseillez-vous pour vraiment progresser ?',
   'Technologie', 8 UNION ALL

  SELECT 'aissa.diop@ucad.sn', 'Comment économiser avec un budget étudiant à Dakar ?',
   'Mes parents m''envoient 50 000 FCFA par mois pour vivre. Comment organiser ce budget pour ne pas être à sec en fin de mois, et même mettre un peu de côté ?',
   'Finance', 3 UNION ALL

  SELECT 'demo@lasource.io', 'Comment se préparer aux entretiens de stage en finance à Cotonou ?',
   'Je vise un stage dans une banque ou une fintech à Cotonou. Quelles questions reviennent souvent en entretien ? Quel niveau d''Excel attendre ?',
   'Finance', 5 UNION ALL

  SELECT 'souley.traore@um6p.ma', 'Faut-il un GitHub fourni pour postuler à un premier poste de développeur en Afrique ?',
   'On me dit qu''il faut absolument un GitHub avec des projets pour décrocher un premier job de dev en Afrique francophone. Vrai ou exagéré ?',
   'Technologie', 7 UNION ALL

  SELECT 'marielle.h@etu.uac.bj', 'Concours d''internat de médecine en France pour un étudiant ouest-africain, est-ce réaliste ?',
   'Concrètement, en partant d''une faculté à Cotonou, est-il réaliste de viser le concours d''internat en France ? Quels prérequis administratifs et académiques ?',
   'Médecine', 12 UNION ALL

  SELECT 'aissa.diop@ucad.sn', 'Mobile money ou compte bancaire pour un étudiant : que choisir ?',
   'Je n''ai pas de compte bancaire, juste un wallet Wave. Faut-il ouvrir un vrai compte ? Quels avantages concrets pour un étudiant qui commence à gagner un peu d''argent ?',
   'Finance', 10
) q ON u.email = q.email;

-- ----- RÉPONSES DES MENTORS -----

INSERT INTO reponse (id_question, id_auteur, contenu, note_etoiles, cree_le)
SELECT q.id_question, m.id_utilisateur, r.contenu, r.etoiles,
       DATE_SUB(NOW(), INTERVAL r.h_avant HOUR)
FROM question q
JOIN utilisateur a ON a.id_utilisateur = q.id_auteur
JOIN utilisateur m ON m.email = r.mentor_email
JOIN (
  -- (titre_question, mentor_email, contenu, etoiles, heures_avant)
  SELECT 'Comment réussir le partiel de structures de données en L2 ?' AS titre, 'c.assogba@upmc.fr' AS mentor_email,
   'Fais et refais les insertions/suppressions à la main sur papier d''abord. Ensuite implémente un BST minimal en Python (insert, search, delete), puis ajoute le parcours infixe. Tu comprendras tout en 2 soirées si tu pratiques sans regarder de solution.' AS contenu, 5 AS etoiles, 30 AS h_avant
  UNION ALL SELECT 'Comment réussir le partiel de structures de données en L2 ?', 'aristide.ehui@dev-ci.com',
   'Petit complément : note les invariants après chaque opération. Cela rend les bugs visibles immédiatement.', 4, 24
  UNION ALL SELECT 'Comment lancer une petite activité pendant mes études sans bloquer mon emploi du temps ?', 'b.sow@yebanj.com',
   'Démarre vraiment petit : 3 produits, 5 clientes test, livre toi-même les 2 premiers mois. Bloque-toi un créneau fixe le week-end pour la production. Le piège est de vouloir scaler avant d''avoir compris la marge réelle.', 5, 50
  UNION ALL SELECT 'Comment lancer une petite activité pendant mes études sans bloquer mon emploi du temps ?', 'lea.kakpo@bj-finance.com',
   'Sur la partie compta : tiens un cahier simple recettes/dépenses dès le premier mois. C''est ce qui te permettra de demander un crédit ou un investisseur plus tard.', 4, 40
  UNION ALL SELECT 'Bourse de doctorat en France après un master en data au Maroc, par où commencer ?', 'marie.gbe@scientifique.fr',
   'Eiffel se prépare un an à l''avance (octobre N-1 pour septembre N). Vise aussi les contrats CIFRE et les bourses des écoles doctorales. Commence par identifier 5 labos qui font ton sujet, écris-leur dès l''été.', 5, 12
  UNION ALL SELECT 'PASS validé, et après ? Spécialisation ou médecine générale ?', 'm.diallo@sante-conakry.gn',
   'La généralité reste un excellent métier en Afrique de l''Ouest, avec une vraie demande. La spécialisation est valorisante mais prolonge la formation de 5 à 7 ans. Pense surtout à ce que tu veux soigner et où.', 5, 72
  UNION ALL SELECT 'Apprendre Python pour la data en parallèle de mes cours de maths, par où débuter ?', 'marie.gbe@scientifique.fr',
   'Concrètement : pandas + matplotlib sur un vrai jeu de données qui t''intéresse (météo, foot, prix de marché). Tu apprends 80% des bases en 2 semaines en travaillant sur quelque chose qui te parle.', 5, 90
  UNION ALL SELECT 'Apprendre Python pour la data en parallèle de mes cours de maths, par où débuter ?', 'c.assogba@upmc.fr',
   'Ajoute Jupyter pour expérimenter, et apprends à versionner avec Git tôt. Ce sont deux outils que tu garderas toute ta carrière.', 4, 80
  UNION ALL SELECT 'Comment économiser avec un budget étudiant à Dakar ?', 'o.dossou@invest-coach.com',
   'Règle simple : 50% nécessités (loyer/nourriture/transport), 30% études et envies, 20% épargne automatique dès le 1er du mois. Adapte les pourcentages mais garde l''épargne en premier. 50 000 FCFA suffit pour démarrer.', 5, 24
  UNION ALL SELECT 'Comment se préparer aux entretiens de stage en finance à Cotonou ?', 'lea.kakpo@bj-finance.com',
   'Excel : maîtrise les TCD et les fonctions de recherche (RECHERCHEV/INDEX-EQUIV). Questions classiques : pourquoi la banque, présentation rapide, et au moins 1 question de bilan/compte de résultat. Sache parler de 2 actualités économiques béninoises récentes.', 5, 60
  UNION ALL SELECT 'Faut-il un GitHub fourni pour postuler à un premier poste de développeur en Afrique ?', 'aristide.ehui@dev-ci.com',
   'Pas besoin de 50 projets. 2-3 projets soignés, avec un bon README, une démo en ligne et du code propre valent mieux qu''un GitHub fourre-tout. Les recruteurs regardent 5 minutes maximum.', 5, 36
  UNION ALL SELECT 'Faut-il un GitHub fourni pour postuler à un premier poste de développeur en Afrique ?', 'c.assogba@upmc.fr',
   'D''accord, et n''hésite pas à contribuer à un petit projet open source local (Saytu, OuiCarry, etc.) : ça montre que tu sais lire du code existant.', 4, 30
  UNION ALL SELECT 'Concours d''internat de médecine en France pour un étudiant ouest-africain, est-ce réaliste ?', 'm.diallo@sante-conakry.gn',
   'Réaliste mais long. Il te faut d''abord obtenir l''équivalence de diplôme via le PAE, puis te présenter au concours EVC. Plusieurs collègues l''ont fait en 2-3 ans. Le plus dur reste le financement de l''attente.', 5, 96
  UNION ALL SELECT 'Mobile money ou compte bancaire pour un étudiant : que choisir ?', 'o.dossou@invest-coach.com',
   'Garde Wave pour les flux quotidiens et ouvre un compte d''épargne (Coris, NSIA) pour ce que tu veux mettre de côté. La règle : ne mélange jamais ton épargne avec ton argent du quotidien.', 5, 48
) r ON r.titre = q.titre;

-- ----- MARQUAGES « UTILE » SUR QUELQUES RÉPONSES -----

INSERT INTO marquage_reponse (id_reponse, id_utilisateur, type_marquage)
SELECT r.id_reponse, u.id_utilisateur, 'utile'
FROM reponse r, utilisateur u
WHERE u.email IN ('demo@lasource.io','fadel.agbo@etu.uac.bj','aissa.diop@ucad.sn',
                  'souley.traore@um6p.ma','marielle.h@etu.uac.bj')
  AND r.note_etoiles = 5
LIMIT 30;

-- ----- SAUVEGARDES POUR LE COMPTE DÉMO (pour qu'il ait du contenu) -----

INSERT INTO sauvegarde (id_utilisateur, id_question)
SELECT (SELECT id_utilisateur FROM utilisateur WHERE email='demo@lasource.io'),
       id_question
FROM question
WHERE id_question IN (1, 3, 6, 8)
LIMIT 4;

-- ----- SUIVIS DE MENTORS PAR LE COMPTE DÉMO -----

INSERT INTO suivi_mentor (id_suiveur, id_mentor)
SELECT (SELECT id_utilisateur FROM utilisateur WHERE email='demo@lasource.io'),
       u.id_utilisateur
FROM utilisateur u
WHERE u.email IN ('c.assogba@upmc.fr','o.dossou@invest-coach.com','marie.gbe@scientifique.fr');

-- ----- NOTIFICATIONS POUR LE COMPTE DÉMO -----

INSERT INTO notification (id_destinataire, texte, lien_question, type_notif, est_lue)
SELECT u.id_utilisateur, n.texte, n.id_q, n.type_n, n.lu
FROM utilisateur u, (
  SELECT 'Cyrille ASSOGBA a répondu à votre question sur les entretiens de stage.' AS texte,
         (SELECT id_question FROM question WHERE titre LIKE 'Comment se préparer aux entretiens%' LIMIT 1) AS id_q,
         'reponse' AS type_n, FALSE AS lu
  UNION ALL SELECT 'Olivier DOSSOU (que vous suivez) a publié une nouvelle réponse.',
         (SELECT id_question FROM question WHERE titre LIKE 'Mobile money ou compte%' LIMIT 1),
         'reponse', FALSE
  UNION ALL SELECT 'Marie GBESSEMÉHLAN (que vous suivez) a répondu sur les bourses de doctorat.',
         (SELECT id_question FROM question WHERE titre LIKE 'Bourse de doctorat%' LIMIT 1),
         'reponse', TRUE
) n
WHERE u.email = 'demo@lasource.io';

-- ----- SIGNALEMENT DE DÉMONSTRATION (pour l'admin) -----

INSERT INTO signalement (id_signaleur, type_contenu, id_contenu, motif, statut)
SELECT (SELECT id_utilisateur FROM utilisateur WHERE email='demo@lasource.io'),
       'reponse',
       (SELECT id_reponse FROM reponse LIMIT 1 OFFSET 5),
       'Test : signalement de démonstration pour l''interface admin.',
       'ouvert';

-- =====================================================================
-- Identifiants après chargement
--   demo@lasource.io       / Source2026!   (étudiant — exploration)
--   admin@lasource.io      / Source2026!   (admin — modération + stats)
--   fadel.agbo@etu.uac.bj  / Source2026!   (étudiant)
--   c.assogba@upmc.fr      / Source2026!   (mentor vérifié)
--   o.dossou@invest-coach.com / Source2026! (mentor finance/éducation)
-- =====================================================================
