-- =====================================================================
-- LaSource — Données de démonstration (SQLite)
-- Mots de passe : bcrypt "Source2026!" (vérifié)
-- Chargé automatiquement par initialiser_si_necessaire() après schema_sqlite.sql.
-- =====================================================================

-- ----- UTILISATEURS -----
-- Hash bcrypt en clair dans chaque INSERT (SQLite n'a pas de variables @)

INSERT INTO utilisateur (prenom, nom, email, telephone, mot_de_passe, role, bio, etudes, id_pays, ville, est_admin, est_actif, email_verifie) VALUES
('Découverte','LaSource','demo@lasource.io','+22900000000',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','etudiant',
 'Compte de démonstration publique. Connectez-vous pour explorer.',
 'Licence 2 — Université d''Abomey-Calavi',8,'Cotonou',0,1,1),

('Aïcha','KOSSOU','admin@lasource.io','+22901020304',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','admin',
 'Coordinatrice de la modération LaSource.','Master 2 — UAC',8,'Cotonou',1,1,1),

('Fadel','AGBO','fadel.agbo@etu.uac.bj','+22996010101',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','etudiant',
 'L2 Mathématiques appliquées. Curieux de tout, surtout des bases de données.',
 'L2 Maths-Info — UAC',8,'Cotonou',0,1,1),

('Aïssa','DIOP','aissa.diop@ucad.sn','+221770202020',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','etudiant',
 'Étudiante en gestion, je prépare un projet de microentreprise.',
 'L3 Gestion — UCAD',5,'Dakar',0,1,1),

('Souley','TRAORÉ','souley.traore@um6p.ma','+212600030303',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','etudiant',
 'Passionné de data science et d''agriculture intelligente.',
 'M1 Data — UM6P',6,'Benguérir',0,1,1),

('Marielle','HOUNDJI','marielle.h@etu.uac.bj','+22995040404',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','etudiant',
 'Future médecin, beaucoup de questions sur la suite après la 1re année.',
 'PASS — UAC',8,'Cotonou',0,1,1),

('Cyrille','ASSOGBA','c.assogba@upmc.fr','+33612345001',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','mentor',
 'Ingénieur logiciel à Paris, ex-stagiaire à Cotonou. J''aide les étudiants en informatique sur leurs projets de fin d''études.',
 'M2 Informatique — Sorbonne Université',1,'Paris',0,1,1),

('Léa','KAKPO','lea.kakpo@bj-finance.com','+22997010111',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','mentor',
 'Analyste financière en banque de financement à Cotonou. Disponible pour parler stages et premiers postes en finance.',
 'M2 Finance — IAE Paris',8,'Cotonou',0,1,1),

('Moustapha','DIALLO','m.diallo@sante-conakry.gn','+224622020303',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','mentor',
 'Médecin généraliste à Conakry, 7 ans d''exercice. Conseil pour les concours de l''internat et la pratique en Afrique de l''Ouest.',
 'Doctorat de médecine — UGAN',17,'Conakry',0,1,1),

('Awa','NDIAYE','awa.ndiaye@avocat.sn','+221771030505',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','mentor',
 'Avocate au barreau de Dakar, droit des affaires. Je réponds aux questions sur le parcours juridique en Afrique francophone.',
 'Master 2 Droit — UCAD',5,'Dakar',0,1,1),

('Boubacar','SOW','b.sow@yebanj.com','+22997020202',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','mentor',
 'Entrepreneur dans la fintech (mobile money), 3 levées de fonds réussies. Je parle volontiers business model et premiers clients.',
 'École de commerce — ESSEC',8,'Cotonou',0,1,1),

('Marie','GBESSEMÉHLAN','marie.gbe@scientifique.fr','+33612050606',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','mentor',
 'Doctorante en mathématiques appliquées à Lyon. Originaire de Lomé. Je conseille sur les bourses de master et les thèses en Europe.',
 'Doctorat — ENS Lyon',14,'Lyon',0,1,1),

('Olivier','DOSSOU','o.dossou@invest-coach.com','+22997070707',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','mentor',
 'Consultant en éducation financière et investissement responsable. Spécialisé dans l''accompagnement des jeunes professionnels africains.',
 'CFA + MBA — INSEAD',8,'Cotonou',0,1,1),

('Fatou','CISSÉ','fatou.cisse@artconcept.ml','+22376080808',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','mentor',
 'Designer graphique et directrice artistique à Bamako. Conseils créatifs et carrière dans les industries culturelles.',
 'Master Arts — INA',12,'Bamako',0,1,1),

('Aristide','EHUI','aristide.ehui@dev-ci.com','+22501010101',
 '$2b$12$OARDg/GseKwHtvVSv5n11.5q3CM.6KP1gl.enMrabpO86bEMrghM6','mentor',
 'Développeur full-stack et formateur à Abidjan. J''aime aider les autodidactes à structurer leur apprentissage.',
 'Licence Info — INPHB',7,'Abidjan',0,1,1);

-- ----- DÉTAILS MENTORS -----

INSERT INTO mentor_details (id_utilisateur, est_verifie, dispo, anciennete, delai_reponse, note_moyenne, nb_reponses) VALUES
((SELECT id_utilisateur FROM utilisateur WHERE email='c.assogba@upmc.fr'),          1,'disponible','2 ans','sous 24 h',4.80,28),
((SELECT id_utilisateur FROM utilisateur WHERE email='lea.kakpo@bj-finance.com'),   1,'disponible','1 an' ,'sous 48 h',4.70,19),
((SELECT id_utilisateur FROM utilisateur WHERE email='m.diallo@sante-conakry.gn'),  1,'occupe',    '3 ans','sous 72 h',4.90,41),
((SELECT id_utilisateur FROM utilisateur WHERE email='awa.ndiaye@avocat.sn'),       1,'disponible','2 ans','sous 24 h',4.60,22),
((SELECT id_utilisateur FROM utilisateur WHERE email='b.sow@yebanj.com'),           0,'absent',    '1 an' ,'sous 1 semaine',4.40,12),
((SELECT id_utilisateur FROM utilisateur WHERE email='marie.gbe@scientifique.fr'),  1,'disponible','4 ans','sous 48 h',4.90,56),
((SELECT id_utilisateur FROM utilisateur WHERE email='o.dossou@invest-coach.com'),  1,'disponible','2 ans','sous 24 h',4.85,33),
((SELECT id_utilisateur FROM utilisateur WHERE email='fatou.cisse@artconcept.ml'),  0,'disponible','6 mois','sous 72 h',4.50,8),
((SELECT id_utilisateur FROM utilisateur WHERE email='aristide.ehui@dev-ci.com'),   1,'disponible','3 ans','sous 24 h',4.75,47);

-- ----- EXPÉRIENCES -----

INSERT INTO experience (id_utilisateur, type_experience, intitule, periode, ordre) VALUES
((SELECT id_utilisateur FROM utilisateur WHERE email='c.assogba@upmc.fr'),         'poste',   'Ingénieur logiciel — Doctolib','2022 à aujourd''hui',1),
((SELECT id_utilisateur FROM utilisateur WHERE email='c.assogba@upmc.fr'),         'diplome', 'Master 2 Informatique — Sorbonne Université','2020-2022',2),
((SELECT id_utilisateur FROM utilisateur WHERE email='lea.kakpo@bj-finance.com'),  'poste',   'Analyste financière — Bank of Africa','2023 à aujourd''hui',1),
((SELECT id_utilisateur FROM utilisateur WHERE email='lea.kakpo@bj-finance.com'),  'diplome', 'Master 2 Finance — IAE Paris','2021-2023',2),
((SELECT id_utilisateur FROM utilisateur WHERE email='m.diallo@sante-conakry.gn'), 'poste',   'Médecin généraliste — Cabinet privé Conakry','2019 à aujourd''hui',1),
((SELECT id_utilisateur FROM utilisateur WHERE email='m.diallo@sante-conakry.gn'), 'diplome', 'Doctorat de médecine — UGAN','2012-2019',2),
((SELECT id_utilisateur FROM utilisateur WHERE email='awa.ndiaye@avocat.sn'),      'poste',   'Avocate associée — Cabinet Ndiaye & Partners','2022 à aujourd''hui',1),
((SELECT id_utilisateur FROM utilisateur WHERE email='awa.ndiaye@avocat.sn'),      'diplome', 'Master 2 Droit des affaires — UCAD','2018-2020',2),
((SELECT id_utilisateur FROM utilisateur WHERE email='b.sow@yebanj.com'),          'poste',   'Co-fondateur & CEO — YeBanj (fintech)','2023 à aujourd''hui',1),
((SELECT id_utilisateur FROM utilisateur WHERE email='marie.gbe@scientifique.fr'), 'poste',   'Doctorante — ENS Lyon','2022 à aujourd''hui',1),
((SELECT id_utilisateur FROM utilisateur WHERE email='o.dossou@invest-coach.com'), 'poste',   'Consultant en éducation financière — indépendant','2022 à aujourd''hui',1),
((SELECT id_utilisateur FROM utilisateur WHERE email='o.dossou@invest-coach.com'), 'diplome', 'MBA — INSEAD','2019-2020',2),
((SELECT id_utilisateur FROM utilisateur WHERE email='aristide.ehui@dev-ci.com'),  'poste',   'Développeur full-stack — Orange CI','2021 à aujourd''hui',1);

-- ----- SECTEURS D'INTÉRÊT / EXPERTISE -----

INSERT INTO utilisateur_secteur (id_utilisateur, id_secteur)
SELECT u.id_utilisateur, s.id_secteur FROM utilisateur u, secteur s WHERE
  (u.email='c.assogba@upmc.fr'         AND s.libelle IN ('Technologie','Éducation'))
  OR (u.email='lea.kakpo@bj-finance.com'  AND s.libelle IN ('Finance','Entrepreneuriat'))
  OR (u.email='m.diallo@sante-conakry.gn' AND s.libelle IN ('Médecine','Sciences'))
  OR (u.email='awa.ndiaye@avocat.sn'      AND s.libelle IN ('Droit','Entrepreneuriat'))
  OR (u.email='b.sow@yebanj.com'          AND s.libelle IN ('Entrepreneuriat','Finance','Technologie'))
  OR (u.email='marie.gbe@scientifique.fr' AND s.libelle IN ('Sciences','Éducation','Ingénierie'))
  OR (u.email='o.dossou@invest-coach.com' AND s.libelle IN ('Finance','Entrepreneuriat','Éducation'))
  OR (u.email='fatou.cisse@artconcept.ml' AND s.libelle IN ('Arts','Communication'))
  OR (u.email='aristide.ehui@dev-ci.com'  AND s.libelle IN ('Technologie','Éducation'))
  OR (u.email='demo@lasource.io'          AND s.libelle IN ('Technologie','Finance'))
  OR (u.email='fadel.agbo@etu.uac.bj'     AND s.libelle IN ('Technologie','Sciences'))
  OR (u.email='aissa.diop@ucad.sn'        AND s.libelle IN ('Entrepreneuriat','Finance'))
  OR (u.email='souley.traore@um6p.ma'     AND s.libelle IN ('Technologie','Agriculture'))
  OR (u.email='marielle.h@etu.uac.bj'     AND s.libelle IN ('Médecine','Sciences'));

-- ----- QUESTIONS -----

INSERT INTO question (id_auteur, titre, corps, id_secteur, publiee_le) VALUES
((SELECT id_utilisateur FROM utilisateur WHERE email='fadel.agbo@etu.uac.bj'),
 'Comment réussir le partiel de structures de données en L2 ?',
 'Le partiel approche et je galère sur les arbres binaires de recherche. Quels exercices pratiques recommandez-vous pour bien comprendre les insertions et suppressions ?',
 (SELECT id_secteur FROM secteur WHERE libelle='Technologie'),
 datetime('now','-2 days')),

((SELECT id_utilisateur FROM utilisateur WHERE email='aissa.diop@ucad.sn'),
 'Comment lancer une petite activité pendant mes études sans bloquer mon emploi du temps ?',
 'Je suis en L3 gestion à Dakar et je voudrais lancer une petite activité de vente de produits cosmétiques. Comment équilibrer mes cours et un démarrage d''activité ?',
 (SELECT id_secteur FROM secteur WHERE libelle='Entrepreneuriat'),
 datetime('now','-4 days')),

((SELECT id_utilisateur FROM utilisateur WHERE email='souley.traore@um6p.ma'),
 'Bourse de doctorat en France après un master en data au Maroc, par où commencer ?',
 'Je termine mon M1 en data science et je vise un doctorat en France. Quelles bourses (Eiffel, AUF, autres) regarder en priorité et quand commencer les démarches ?',
 (SELECT id_secteur FROM secteur WHERE libelle='Sciences'),
 datetime('now','-1 days')),

((SELECT id_utilisateur FROM utilisateur WHERE email='marielle.h@etu.uac.bj'),
 'PASS validé, et après ? Spécialisation ou médecine générale ?',
 'Je viens de valider ma PASS à Cotonou et je dois choisir une orientation. J''hésite entre médecine générale pour rentrer plus vite en activité ou tenter une spécialisation.',
 (SELECT id_secteur FROM secteur WHERE libelle='Médecine'),
 datetime('now','-6 days')),

((SELECT id_utilisateur FROM utilisateur WHERE email='fadel.agbo@etu.uac.bj'),
 'Apprendre Python pour la data en parallèle de mes cours de maths, par où débuter ?',
 'Mes cours actuels sont surtout théoriques. Je veux apprendre Python pour la data en parallèle. Quels projets concrets simples conseillez-vous pour vraiment progresser ?',
 (SELECT id_secteur FROM secteur WHERE libelle='Technologie'),
 datetime('now','-8 days')),

((SELECT id_utilisateur FROM utilisateur WHERE email='aissa.diop@ucad.sn'),
 'Comment économiser avec un budget étudiant à Dakar ?',
 'Mes parents m''envoient 50 000 FCFA par mois pour vivre. Comment organiser ce budget pour ne pas être à sec en fin de mois, et même mettre un peu de côté ?',
 (SELECT id_secteur FROM secteur WHERE libelle='Finance'),
 datetime('now','-3 days')),

((SELECT id_utilisateur FROM utilisateur WHERE email='demo@lasource.io'),
 'Comment se préparer aux entretiens de stage en finance à Cotonou ?',
 'Je vise un stage dans une banque ou une fintech à Cotonou. Quelles questions reviennent souvent en entretien ? Quel niveau d''Excel attendre ?',
 (SELECT id_secteur FROM secteur WHERE libelle='Finance'),
 datetime('now','-5 days')),

((SELECT id_utilisateur FROM utilisateur WHERE email='souley.traore@um6p.ma'),
 'Faut-il un GitHub fourni pour postuler à un premier poste de développeur en Afrique ?',
 'On me dit qu''il faut absolument un GitHub avec des projets pour décrocher un premier job de dev en Afrique francophone. Vrai ou exagéré ?',
 (SELECT id_secteur FROM secteur WHERE libelle='Technologie'),
 datetime('now','-7 days')),

((SELECT id_utilisateur FROM utilisateur WHERE email='marielle.h@etu.uac.bj'),
 'Concours d''internat de médecine en France pour un étudiant ouest-africain, est-ce réaliste ?',
 'Concrètement, en partant d''une faculté à Cotonou, est-il réaliste de viser le concours d''internat en France ? Quels prérequis administratifs et académiques ?',
 (SELECT id_secteur FROM secteur WHERE libelle='Médecine'),
 datetime('now','-12 days')),

((SELECT id_utilisateur FROM utilisateur WHERE email='aissa.diop@ucad.sn'),
 'Mobile money ou compte bancaire pour un étudiant : que choisir ?',
 'Je n''ai pas de compte bancaire, juste un wallet Wave. Faut-il ouvrir un vrai compte ? Quels avantages concrets pour un étudiant qui commence à gagner un peu d''argent ?',
 (SELECT id_secteur FROM secteur WHERE libelle='Finance'),
 datetime('now','-10 days'));

-- ----- RÉPONSES -----

INSERT INTO reponse (id_question, id_auteur, contenu, note_etoiles, cree_le) VALUES
((SELECT id_question FROM question WHERE titre LIKE 'Comment réussir le partiel%'),
 (SELECT id_utilisateur FROM utilisateur WHERE email='c.assogba@upmc.fr'),
 'Fais et refais les insertions/suppressions à la main sur papier d''abord. Ensuite implémente un BST minimal en Python (insert, search, delete), puis ajoute le parcours infixe. Tu comprendras tout en 2 soirées si tu pratiques sans regarder de solution.',
 5, datetime('now','-30 hours')),

((SELECT id_question FROM question WHERE titre LIKE 'Comment réussir le partiel%'),
 (SELECT id_utilisateur FROM utilisateur WHERE email='aristide.ehui@dev-ci.com'),
 'Petit complément : note les invariants après chaque opération. Cela rend les bugs visibles immédiatement.',
 4, datetime('now','-24 hours')),

((SELECT id_question FROM question WHERE titre LIKE 'Comment lancer une petite activité%'),
 (SELECT id_utilisateur FROM utilisateur WHERE email='b.sow@yebanj.com'),
 'Démarre vraiment petit : 3 produits, 5 clientes test, livre toi-même les 2 premiers mois. Bloque-toi un créneau fixe le week-end pour la production. Le piège est de vouloir scaler avant d''avoir compris la marge réelle.',
 5, datetime('now','-50 hours')),

((SELECT id_question FROM question WHERE titre LIKE 'Comment lancer une petite activité%'),
 (SELECT id_utilisateur FROM utilisateur WHERE email='lea.kakpo@bj-finance.com'),
 'Sur la partie compta : tiens un cahier simple recettes/dépenses dès le premier mois. C''est ce qui te permettra de demander un crédit ou un investisseur plus tard.',
 4, datetime('now','-40 hours')),

((SELECT id_question FROM question WHERE titre LIKE 'Bourse de doctorat%'),
 (SELECT id_utilisateur FROM utilisateur WHERE email='marie.gbe@scientifique.fr'),
 'Eiffel se prépare un an à l''avance (octobre N-1 pour septembre N). Vise aussi les contrats CIFRE et les bourses des écoles doctorales. Commence par identifier 5 labos qui font ton sujet, écris-leur dès l''été.',
 5, datetime('now','-12 hours')),

((SELECT id_question FROM question WHERE titre LIKE 'PASS validé%'),
 (SELECT id_utilisateur FROM utilisateur WHERE email='m.diallo@sante-conakry.gn'),
 'La généralité reste un excellent métier en Afrique de l''Ouest, avec une vraie demande. La spécialisation est valorisante mais prolonge la formation de 5 à 7 ans. Pense surtout à ce que tu veux soigner et où.',
 5, datetime('now','-72 hours')),

((SELECT id_question FROM question WHERE titre LIKE 'Apprendre Python%'),
 (SELECT id_utilisateur FROM utilisateur WHERE email='marie.gbe@scientifique.fr'),
 'Concrètement : pandas + matplotlib sur un vrai jeu de données qui t''intéresse (météo, foot, prix de marché). Tu apprends 80% des bases en 2 semaines en travaillant sur quelque chose qui te parle.',
 5, datetime('now','-90 hours')),

((SELECT id_question FROM question WHERE titre LIKE 'Apprendre Python%'),
 (SELECT id_utilisateur FROM utilisateur WHERE email='c.assogba@upmc.fr'),
 'Ajoute Jupyter pour expérimenter, et apprends à versionner avec Git tôt. Ce sont deux outils que tu garderas toute ta carrière.',
 4, datetime('now','-80 hours')),

((SELECT id_question FROM question WHERE titre LIKE 'Comment économiser%'),
 (SELECT id_utilisateur FROM utilisateur WHERE email='o.dossou@invest-coach.com'),
 'Règle simple : 50% nécessités (loyer/nourriture/transport), 30% études et envies, 20% épargne automatique dès le 1er du mois. Adapte les pourcentages mais garde l''épargne en premier. 50 000 FCFA suffit pour démarrer.',
 5, datetime('now','-24 hours')),

((SELECT id_question FROM question WHERE titre LIKE 'Comment se préparer aux entretiens%'),
 (SELECT id_utilisateur FROM utilisateur WHERE email='lea.kakpo@bj-finance.com'),
 'Excel : maîtrise les TCD et les fonctions de recherche (RECHERCHEV/INDEX-EQUIV). Questions classiques : pourquoi la banque, présentation rapide, et au moins 1 question de bilan/compte de résultat. Sache parler de 2 actualités économiques béninoises récentes.',
 5, datetime('now','-60 hours')),

((SELECT id_question FROM question WHERE titre LIKE 'Faut-il un GitHub%'),
 (SELECT id_utilisateur FROM utilisateur WHERE email='aristide.ehui@dev-ci.com'),
 'Pas besoin de 50 projets. 2-3 projets soignés, avec un bon README, une démo en ligne et du code propre valent mieux qu''un GitHub fourre-tout. Les recruteurs regardent 5 minutes maximum.',
 5, datetime('now','-36 hours')),

((SELECT id_question FROM question WHERE titre LIKE 'Faut-il un GitHub%'),
 (SELECT id_utilisateur FROM utilisateur WHERE email='c.assogba@upmc.fr'),
 'D''accord, et n''hésite pas à contribuer à un petit projet open source local : ça montre que tu sais lire du code existant.',
 4, datetime('now','-30 hours')),

((SELECT id_question FROM question WHERE titre LIKE 'Concours d''internat%'),
 (SELECT id_utilisateur FROM utilisateur WHERE email='m.diallo@sante-conakry.gn'),
 'Réaliste mais long. Il te faut d''abord obtenir l''équivalence de diplôme via le PAE, puis te présenter au concours EVC. Plusieurs collègues l''ont fait en 2-3 ans. Le plus dur reste le financement de l''attente.',
 5, datetime('now','-96 hours')),

((SELECT id_question FROM question WHERE titre LIKE 'Mobile money%'),
 (SELECT id_utilisateur FROM utilisateur WHERE email='o.dossou@invest-coach.com'),
 'Garde Wave pour les flux quotidiens et ouvre un compte d''épargne (Coris, NSIA) pour ce que tu veux mettre de côté. La règle : ne mélange jamais ton épargne avec ton argent du quotidien.',
 5, datetime('now','-48 hours'));

-- ----- MARQUAGES UTILES + SAUVEGARDES + SUIVIS + NOTIFICATIONS -----

INSERT INTO marquage_reponse (id_reponse, id_utilisateur, type_marquage)
SELECT r.id_reponse, u.id_utilisateur, 'utile'
FROM reponse r, utilisateur u
WHERE u.email IN ('demo@lasource.io','fadel.agbo@etu.uac.bj','aissa.diop@ucad.sn')
  AND r.note_etoiles = 5
LIMIT 12;

INSERT INTO sauvegarde (id_utilisateur, id_question)
SELECT (SELECT id_utilisateur FROM utilisateur WHERE email='demo@lasource.io'),
       id_question FROM question
WHERE titre IN (
  'Comment économiser avec un budget étudiant à Dakar ?',
  'Comment se préparer aux entretiens de stage en finance à Cotonou ?',
  'Mobile money ou compte bancaire pour un étudiant : que choisir ?'
);

INSERT INTO suivi_mentor (id_suiveur, id_mentor)
SELECT (SELECT id_utilisateur FROM utilisateur WHERE email='demo@lasource.io'),
       id_utilisateur FROM utilisateur
WHERE email IN ('c.assogba@upmc.fr','o.dossou@invest-coach.com','marie.gbe@scientifique.fr');

INSERT INTO notification (id_destinataire, texte, lien_question, type_notif, est_lue) VALUES
((SELECT id_utilisateur FROM utilisateur WHERE email='demo@lasource.io'),
 'Léa KAKPO a répondu à votre question sur les entretiens de stage.',
 (SELECT id_question FROM question WHERE titre LIKE 'Comment se préparer aux entretiens%'),
 'reponse', 0),

((SELECT id_utilisateur FROM utilisateur WHERE email='demo@lasource.io'),
 'Olivier DOSSOU (que vous suivez) a publié une nouvelle réponse.',
 (SELECT id_question FROM question WHERE titre LIKE 'Mobile money%'),
 'reponse', 0),

((SELECT id_utilisateur FROM utilisateur WHERE email='demo@lasource.io'),
 'Marie GBESSEMÉHLAN (que vous suivez) a répondu sur les bourses de doctorat.',
 (SELECT id_question FROM question WHERE titre LIKE 'Bourse de doctorat%'),
 'reponse', 1);

INSERT INTO signalement (id_signaleur, type_contenu, id_contenu, motif, statut)
SELECT (SELECT id_utilisateur FROM utilisateur WHERE email='demo@lasource.io'),
       'reponse', id_reponse,
       'Test : signalement de démonstration pour l''interface admin.',
       'ouvert'
FROM reponse LIMIT 1 OFFSET 5;
