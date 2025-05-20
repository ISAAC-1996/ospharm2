# ospharm2

`ospharm2` est un package R destiné à **automatiser les requêtes SQL utilisées dans les études pharmaceutiques**.  
L’objectif est de **faciliter les analyses répétées** sans avoir à réécrire manuellement les requêtes SQL,  
ce qui permet de gagner du temps, de réduire les erreurs et de limiter la dépendance à la maîtrise du SQL.

---

## Installation

Pour installer la version de développement depuis GitHub :

```r
# Si ce n’est pas encore fait
install.packages("devtools")

# Installer depuis GitHub
devtools::install_github("ISAAC-1996/ospharm2")
```

##------------------- pharma_complete_12() ----------------------------
La fonction `pharma_complete_12()` permet de récupérer la liste des **pharmacies complètes** sur les 12 mois d’une année donnée, ainsi que leur **chiffre d’affaires total**.

Elle est utile pour exclure les structures incomplètes des analyses de performance.

#### Fonctionnement :

- Par défaut (`n = 0`), elle renvoie les données de l’année précédente (année en cours - 1)
- `n = 1` → année en cours - 2, etc. jusqu’à `n = 2`
- Au-delà, elle indique qu’il n’y a pas de données

#### Exemple d'utilsation:

```r
library(ospharm2)
# Pharmacies complètes de l’année précédente
pharma_complete_12()

# Pour l’année N-2
pharma_complete_12(n = 1)
```
