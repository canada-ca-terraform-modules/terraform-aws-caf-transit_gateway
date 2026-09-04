variable "tags" {
  description = "Tags applied to all resources (merged with transit_gateway.tags)"
  type        = map(string)
  default     = {}
}

variable "env" {
  description = "(Required) env value used in name generation"
  type        = string
}

variable "userDefinedString" {
  description = "(Required) UserDefinedString part of the name of the transit gateway"
  type        = string
}

variable "transit_gateway" {
  description = "(Required) Object describing the transit gateway and every attachment/route/association hung off it (see TFVars Parameters below). Optional `name` key overrides the auto-derived \"env-userDefinedString\" Name tag value."
  type        = any
  default     = {}
}
