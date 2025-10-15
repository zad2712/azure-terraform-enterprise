locals {
  naming_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge({
    Environment = var.environment, ManagedBy = "terraform", Project = var.project_name,
    CostCenter = var.cost_center, Owner = var.owner_team, Criticality = var.criticality,
    DataClassification = var.data_classification, Layer = "storage"
  }, var.additional_tags)
}
