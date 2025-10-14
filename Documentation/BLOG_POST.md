# Greed and Glory Hole : Les coulisses d'un jeu d'action 3D

Bonjour à tous ! Aujourd'hui, je vais vous parler du développement de **Greed and Glory Hole**, un jeu d'action en 3D sur lequel je travaille. Depuis le début du projet, j'ai mis l'accent sur la création d'une base solide et flexible qui permettra d'ajouter facilement de nouvelles fonctionnalités par la suite.

## Un système de mouvement qui a du style

L'une des premières choses que j'ai voulu créer, c'est un personnage agréable à contrôler. Dans beaucoup de jeux, se déplacer devrait être fun en soi ! J'ai donc développé un système qui permet au joueur de :

- **Marcher et courir** de façon fluide dans tous les sens
- **Glisser** sur les surfaces, avec une accélération dans les pentes
- **Sauter plusieurs fois en l'air** pour atteindre des endroits difficiles d'accès
- **Combiner le tout** : faire un saut depuis une glissade pour aller encore plus vite et plus loin !

Le plus important, c'est que ces mouvements s'enchaînent naturellement. Vous pouvez partir d'une marche, accélérer en glissant dans une pente, puis sauter pour traverser un gouffre. Tout est fluide et réactif.

## Des améliorations qui changent tout

Un aspect central du jeu est le **système d'améliorations**. Imaginez pouvoir trouver ou débloquer des objets qui changent complètement votre façon de jouer :

- **Améliorations de statistiques** : Augmentez votre vitesse, votre force de saut, ou même votre taille !
- **Équipements permanents** : Des upgrades qui restent entre les parties et vous permettent de progresser même après un échec
- **Effets spéciaux** : Des capacités uniques comme créer une onde de choc en sautant, attirer automatiquement les objets vers vous, ou même vous régénérer progressivement

Ce qui rend ce système intéressant, c'est qu'il est vraiment **modulaire**. Vous pouvez combiner plusieurs améliorations pour créer votre propre style de jeu. Voulez-vous être ultra-rapide et agile ? Ou préférez-vous être plus résistant avec des effets de zone ? C'est à vous de décider !

## Une architecture pensée pour l'avenir

J'ai aussi passé beaucoup de temps à organiser le code de manière intelligente. Pourquoi ? Parce que je veux pouvoir ajouter facilement de nouvelles fonctionnalités sans casser ce qui existe déjà. Le jeu est construit avec plusieurs **gestionnaires** qui s'occupent chacun d'un aspect spécifique :

- Un gestionnaire pour les **statistiques du joueur**
- Un gestionnaire pour les **améliorations**
- Un gestionnaire pour les **événements** du jeu (quand vous sautez, glissez, etc.)
- Un gestionnaire pour les **transitions** entre les scènes
- Un gestionnaire pour le **feedback** visuel et sonore

Cette organisation fait que chaque système peut évoluer indépendamment. Si je veux améliorer le système de son, je n'ai pas besoin de toucher au code du mouvement du joueur !

## L'interface et la progression

Le jeu dispose déjà d'un **écran de démarrage**, d'un **menu principal**, et d'un système de navigation entre les scènes avec des transitions visuelles (fondu au noir). J'ai également prévu un système de **monnaie** pour acheter des améliorations, même si cette partie n'est pas encore complètement implémentée.

## Ce qui rend ce projet spécial

Ce qui me plaît particulièrement dans ce projet, c'est l'équilibre entre **simplicité** et **profondeur**. Les contrôles sont simples à comprendre (WASD pour bouger, Espace pour sauter, Shift pour glisser), mais les combinaisons de mouvements et d'améliorations offrent beaucoup de possibilités.

J'ai aussi créé une **documentation technique complète** (plus de 600 lignes !) pour m'assurer que je ne me perds pas dans mon propre code et pour faciliter l'arrivée d'éventuels contributeurs.

## Et maintenant ?

Le projet est encore en développement actif. Les fondations sont solides, et je peux maintenant me concentrer sur l'ajout de contenu : des ennemis variés, des niveaux intéressants, plus d'améliorations, et pourquoi pas un système de génération procédurale de niveaux ?

Le voyage ne fait que commencer, et j'ai hâte de voir où ce projet me mènera !

---

## Pour les curieux : les détails techniques

Si vous vous intéressez au développement de jeux, voici quelques détails plus techniques sur les choix d'architecture que j'ai faits :

### Le Pattern Strategy pour le mouvement

Plutôt que d'avoir un seul gros script avec des `if/else` partout pour gérer les différents états de mouvement, j'ai utilisé le **Pattern Strategy**. Concrètement, j'ai créé trois "stratégies" de mouvement distinctes :
- `GroundMovement` pour le mouvement au sol
- `AirMovement` pour le mouvement en l'air
- `SlideMovement` pour la glissade

Le contrôleur du joueur bascule automatiquement entre ces stratégies selon la situation. Chaque stratégie implémente sa propre logique de physique : calcul de la gravité, de l'accélération, de la décélération, etc. Cela rend le code beaucoup plus **maintenable** et **extensible**. Vous voulez ajouter un mode "wall run" ? Créez simplement une nouvelle stratégie !

### Event Bus : la communication découplée

J'ai implémenté un **EventBus** global, qui est un pattern Observer. Au lieu que les différentes parties du code se parlent directement (ce qui crée des dépendances compliquées), elles communiquent par des événements :

```gdscript
EventBus.on_player_jumped.emit(jump_count)
EventBus.on_player_landed.connect(_on_player_landed)
```

Par exemple, quand le joueur saute, le contrôleur émet un événement `on_player_jumped`. Tous les systèmes intéressés (effets sonores, effets visuels, certaines améliorations) peuvent "s'abonner" à cet événement sans que le contrôleur ait besoin de savoir qui écoute. C'est extrêmement pratique pour les effets d'améliorations !

### Composition over Inheritance

Pour les statistiques, au lieu de créer des classes qui héritent les unes des autres, j'utilise la **composition**. Chaque stat (vitesse, force de saut, etc.) est une ressource indépendante avec :
- Une valeur de base
- Des modificateurs additifs (+10 de vitesse)
- Des multiplicateurs (×1.5 de vitesse)

La valeur finale est calculée automatiquement : `(base + additif) × multiplicateur`. Les améliorations ne font que modifier ces valeurs, ce qui évite les bugs et rend le système très flexible.

### Modularité des Upgrades

Le système d'améliorations utilise une hiérarchie à trois niveaux :
1. **BaseUpgrade** : classe abstraite de base
2. **StatBoostUpgrade** : augmente simplement une stat
3. **EquipmentUpgrade** : upgrades permanentes avec gestion de slots
4. **EffectUpgrade** : effets custom qui peuvent faire n'importe quoi

Chaque upgrade définit deux méthodes : `apply_effect()` et `remove_effect()`. Cela permet d'ajouter et de retirer des améliorations dynamiquement, ce qui est essentiel pour un système de progression.

### Technologies

Le jeu est développé avec **Godot 4.5**, un moteur de jeu open-source extrêmement puissant. J'utilise le langage **GDScript**, qui ressemble à Python et est très intuitif. Le jeu tourne en résolution 640×480 (style rétro) avec un rendu 3D moderne en Forward Plus.

### Métriques du projet

À ce stade, le projet comprend :
- **30 scripts GDScript** (environ 3000+ lignes de code)
- **10 scènes Godot** pour l'interface et le monde
- **9 autoloads** (systèmes globaux)
- **4 types d'effets d'amélioration** déjà implémentés
- **11 statistiques de joueur** différentes
- Une **documentation technique** de 620 lignes

Tout cela a été développé avec une attention particulière à la qualité du code, aux patterns de conception, et à la maintenabilité à long terme.

---

*Ce billet de blog a été écrit pour partager ma passion du développement de jeux vidéo et j'espère qu'il vous a donné envie d'en savoir plus sur le processus de création d'un jeu !*
