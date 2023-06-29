# Outputs of this module

# The main purpose of this template, a complete key/val map of data to use in your kubernetes secret data
output "data" {
  description = "An easy-to-embed secret map, feel free to embed this into your kubernetes_secret data field"
  value = tomap({
    "database_uri"=            local.database_uri,
    "database_uri_without_db"= local.database_uri_without_db,
    "database_uri_options"=    local.database_uri_options,
    "jdbc_uri"=                local.jdbc_uri,
    "hostname"=                local.hostname,
    "database"=                local.database,
    "port"=                    local.port,
    "username"=                local.username,
    "password"=                local.password
  })
}

# Other singular outputs
output "hostname" {
  value       = local.hostname
  description = "Database hostname"
}
output "port" {
  value       = local.port
  description = "Database port"
}
output "username" {
  value       = local.username
  description = "Database username"
}
output "password" {
  value       = local.password
  description = "Database password"
  sensitive   = true
}
output "database" {
  value       = local.database
  description = "Database name"
}
output "database_uri" {
  value       = local.database_uri
  description = "Database URI"
  sensitive   = true
}
output "database_uri_without_db" {
  value       = local.database_uri_without_db
  description = "Database URI without db name (for dynamic db naming)"
  sensitive   = true
}
output "database_uri_options" {
  value       = local.database_uri_options
  description = "Database URI options only (useful to append manually after dynamic db naming)"
  sensitive   = true
}
output "jdbc_uri" {
  value       = local.jdbc_uri
  description = "Database JDBC URI"
  sensitive   = true
}
