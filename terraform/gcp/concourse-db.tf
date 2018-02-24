#### External Postgres DB
resource "google_sql_database_instance" "postgres" {
  name             = "master-instance"
  database_version = "POSTGRES_9_6"
  project          = "${var.gcp_project_name}"
  region           = "${var.gcp_region}"

  settings {
    tier              = "db-f1-micro"                                          #TO CHANGE !!!
    availability_type = "${var.ha_concourse == "true" ? "REGIONAL" : "ZONAL"}"

    ip_configuration {
      ipv4_enabled = "true"
    }

    location_preference {
      zone = "${var.gcp_zone_1}"
    }
  }

  count = "${var.flags.["use_external_postgres"] == "true" ? 1 : 0}"
}

### ATC DB
resource "google_sql_database" "atc" {
  name      = "atc"
  instance  = "${google_sql_database_instance.postgres.name}"
  charset   = "UTF8"
  collation = "en_US.UTF-8"

  count = "${var.flags.["use_external_postgres"] == "true" ? 1 : 0}"
}

resource "random_string" "atc_db_password" {
  length  = 16
  special = true

  count = "${var.flags.["use_external_postgres"] == "true" ? 1 : 0}"
}

resource "google_sql_user" "atc" {
  name     = "atc"
  instance = "${google_sql_database_instance.postgres.name}"
  host     = ""
  password = "${random_string.atc_db_password.result}"

  count = "${var.flags.["use_external_postgres"] == "true" ? 1 : 0}"
}

### Credhub DB
resource "google_sql_database" "credhub" {
  name      = "credhub"
  instance  = "${google_sql_database_instance.postgres.name}"
  charset   = "UTF8"
  collation = "en_US.UTF-8"

  count = "${var.flags.["use_external_postgres"] == "true" ? 1 : 0}"
}

resource "random_string" "credhub_db_password" {
  length  = 16
  special = true

  count = "${var.flags.["use_external_postgres"] == "true" ? 1 : 0}"
}

resource "google_sql_user" "credhub" {
  name     = "credhub"
  instance = "${google_sql_database_instance.postgres.name}"
  host     = ""
  password = "${random_string.credhub_db_password.result}"

  count = "${var.flags.["use_external_postgres"] == "true" ? 1 : 0}"
}

### UAA DB
resource "google_sql_database" "uaa" {
  name      = "uaa"
  instance  = "${google_sql_database_instance.postgres.name}"
  charset   = "UTF8"
  collation = "en_US.UTF-8"

  count = "${var.flags.["use_external_postgres"] == "true" ? 1 : 0}"
}

resource "random_string" "uaa_db_password" {
  length  = 16
  special = true

  count = "${var.flags.["use_external_postgres"] == "true" ? 1 : 0}"
}

resource "google_sql_user" "uaa" {
  name     = "uaa"
  instance = "${google_sql_database_instance.postgres.name}"
  host     = ""
  password = "${random_string.uaa_db_password.result}"

  count = "${var.flags.["use_external_postgres"] == "true" ? 1 : 0}"
}
