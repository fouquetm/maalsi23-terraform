variable "project_name" {
  type = string
  description = "Détermine le nom du projet qui sera utilisé pour générer le nom des ressources."
}

variable "project_owner" {
  type = string
  description = "Responsable du projet."
}

variable "environnement" {
  type = string
  description = "Défini l'environnement cible pour la création des ressources."
}