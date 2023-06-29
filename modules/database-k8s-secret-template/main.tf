# Parsing and reformatting the data to be used in the outputs
locals {
  hostname     = lower(format("%v", var.hostname))
  port         = lower(format("%v", var.port))
  username     = format("%v", var.username)
  password     = format("%v", var.password)
  database     = length(var.database) > 0 ? var.database : var.username
  database_uri = "${var.scheme}://${local.username}:${local.password}@${local.hostname}:${local.port}/${local.database}${var.database_uri_options}"
  database_uri_without_db = "${var.scheme}://${local.username}:${local.password}@${local.hostname}:${local.port}/"
  database_uri_options = "${var.database_uri_options}"
  jdbc_uri     = "jdbc:postgresql://${local.hostname}:${local.port}/${local.database}${var.jdbc_uri_options}"
}

# TODO: UPDATE JDBC URI TO SUFFIX WITH ;user=MyUserName;password=*****;
# TODO: Publish on Github or something?  :)
