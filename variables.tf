variable "tiller_version" {
  type        = string
  default     = "2.17.0"
  description = "Version of Tiller to be deployed."
}

variable "tiller_namespace" {
  type        = string
  default     = "kube-system"
  description = "Namespace to deploy Tiller into."
}

variable "tiller_history_max" {
  type        = string
  default     = 50
  description = "Number of old releases to be kept by Tiller."
}

variable "tiller_service_account_name" {
  type        = string
  default     = "tiller"
  description = "Name of the service account to be created for the Tiller deployment."
}

variable "tiller_service_type" {
  type        = string
  default     = "ClusterIP"
  description = "Type of Tiller's Kubernetes service object."
}

variable "tiller_service_session_affinity" {
  type        = string
  default     = "None"
  description = "Session affinity of the Tiller service."
}

variable "tiller_sql_connection_string" {
  type        = string
  default     = ""
  description = "SQL connection string to use (only used if 'tiller_storage' is set to 'sql')."
}

variable "tiller_sql_dialect" {
  type        = string
  default     = "postgres"
  description = "SQL dialect to use."
}

variable "tiller_image_pull_policy" {
  type        = string
  default     = "IfNotPresent"
  description = "Default pull policy to be used for the Tiller container image."
}

variable "tiller_pod_node_selector" {
  type        = map(string)
  default     = {}
  description = "Node selector to be applied to the tiller pod."
}

variable "tiller_storage" {
  type        = string
  default     = "configmap"
  description = "Storage driver to use. One of 'configmap', 'memory', 'sql' or 'secret'."
}


variable "tiller_tls" {
  type = object({
    enabled         = bool
    verify          = bool
    ca_cert_pem     = string
    private_key_pem = string
    cert_pem        = string
  })
  default = {
    enabled         = false
    verify          = false
    ca_cert_pem     = null
    private_key_pem = null
    cert_pem        = null
  }
  description = "TLS configuration for Tiller."
}

variable "tolerations" {
  type        = list(map(string))
  default     = []
  description = "Tolerations to apply to Tiller deployment"
}

variable "node_selectors" {
  type        = map(string)
  default     = {}
  description = "Map of {label: value} to use as node selector for Tiller deployment"
}
