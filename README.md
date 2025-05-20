ospharm2
================

# ospharm2

`ospharm2` est un package R destiné à **automatiser les requêtes SQL
utilisées dans les études pharmaceutiques**.  
L’objectif est de **faciliter les analyses répétées** sans avoir à
réécrire manuellement les requêtes SQL,  
ce qui permet de gagner du temps, de réduire les erreurs et de limiter
la dépendance à la maîtrise du SQL.

------------------------------------------------------------------------

## Installation

Pour installer la version de développement depuis GitHub :

``` r
# Si ce n’est pas encore fait
install.packages("devtools")

# Installer depuis GitHub
devtools::install_github("ISAAC-1996/ospharm2")
```

##——————- pharma_complete_12() —————————- La fonction
`pharma_complete_12()` permet de récupérer la liste des **pharmacies
complètes** sur les 12 mois d’une année donnée, ainsi que leur **chiffre
d’affaires total**.

Elle est utile pour exclure les structures incomplètes des analyses de
performance.

#### Fonctionnement :

- Par défaut (`n = 0`), elle renvoie les données de l’année précédente
  (année en cours - 1)
- `n = 1` → année en cours - 2, etc. jusqu’à `n = 2`
- Au-delà, elle indique qu’il n’y a pas de données

#### Exemple d’utilsation:

``` r
library(ospharm2)
# Pharmacies complètes de l’année précédente
pharma_complete_12()

# Pour l’année N-2
pharma_complete_12(n = 1)
```

\##———————– fréquentation journalière moyenne ————————

La fonction `frequentation_journaliere()` permet de calculer la
**fréquentation moyenne par jour** d’une pharmacie donnée sur une
période personnalisée.

Cette fréquentation est calculée à partir des données de
`v_el_collect_ospharm`, en comptant les clients uniques par jour sur la
période indiquée.

#### Exemple d’utilisation :

``` r
library(ospharm2)

# Fréquentation moyenne de la pharmacie 123456 entre janvier et avril 2024
frequentation_journaliere(n_auto = 123456, date_debut = 202401, date_fin = 202404)
```

\##——————–Exemple : informations sur les pharmacies ———————–

La fonction `pharmacies_infos()` permet de récupérer les **informations
détaillées** des pharmacies, avec ou sans filtrage par **groupement**.

Par défaut, elle renvoie **toutes les pharmacies actives**.  
Tu peux lui passer un identifiant de groupement pour filtrer.

#### Exemple d’utilisation :

``` r
library(ospharm2)

# Toutes les pharmacies
pharmacies_infos()

# Pharmacies du groupement 164
pharma
```

\##———————— honoraires de nouvelles missions ————————- La fonction
`Honoraires_new_mission()` permet de générer un tableau synthétique des
**honoraires B2** (nouvelles missions) réalisés par les pharmacies sur
une période définie.

Par défaut, la fonction renvoie les honoraires pour **toutes les
pharmacies actives**.  
Si un identifiant de **groupement** est fourni, elle filtre les
résultats pour ne montrer que les pharmacies appartenant à ce
groupement.

#### 🔎 Points clés :

- Les actes suivants sont **exclus** automatiquement : `'HD'`, `'HG'`,
  `'HC'`, `'HDA'`, `'HDE'`, `'HDR'`
- Le tableau est **pivoté** : chaque ligne correspond à une pharmacie et
  chaque colonne à un type d’honoraire
- Les volumes sont **agrégés** (total des actes réalisés)

#### 📘 Exemple d’utilisation :

``` r
library(ospharm2)

# Honoraires pour toutes les pharmacies entre janvier et avril 2024
Honoraires_new_mission(date_debut = 202401, date_fin = 202404)

# Honoraires pour les pharmacies du groupement 411
Honoraires_new_mission(groupement = 411, date_debut = 202401, date_fin = 202404)
```

##------------------ Classement des produits les plus vendus --------------------------------

La fonction `top_ventes_produits()` permet d’obtenir un **classement des produits les plus vendus** (en quantité) sur une période donnée.

Elle accepte plusieurs filtres facultatifs :
- `region` : restreint aux pharmacies d’une région précise
- `marque` : sélectionne uniquement les produits d’une marque
- `n_auto_adhpha_artic` : identifiant précis d’une pharmacie
- `date_debut`, `date_fin` (obligatoires) : période d’étude
- `top_n` : nombre de produits à retourner (défaut = 20)

Si un filtre n’est **pas précisé**, la fonction considère **toutes les valeurs possibles** pour ce critère.

#### 📘 Exemple 1 : top 30 des produits "avril" en région 1
```r
#TOP 30 des produit vendus des pharmacie sur periode definit et de la region 1(BRETAGNE)
top_ventes_produits(region = 1,
                    marque = "avril",
                    date_debut = 202401,
                    date_fin = 202412,
                    top_n = 30)
 
#TOP 10 des produit vendus d'une pharmacie sur periode definit                   
top_ventes_produits(n_auto_adhpha_artic = 7722,
                    date_debut = 202401,
                    date_fin = 202412,
                    top_n = 10)
                    
#TOP 20 tous produits vendus au niveau de national (trop lourd)
top_ventes_produits(date_debut = 202401,
                    date_fin = 202412)
  ```                  
                    
        

