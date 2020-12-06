# => NOTE: Ensure that the specified top-level domains are pointing to this server ip address using DNS records.
# => Be sure to restart your server when you modify this file.

# Use this smartmachine as server or local.
SmartMachine.config.machine_mode = :server

# Top-level naked domain to be used for subdomains of apps.
SmartMachine.config.apps_domain = "yourdomain.com"

# domain to be used for git prereceiver
SmartMachine.config.git_domain = "git.yourdomain.com"

# Sysadmin email id.
SmartMachine.config.sysadmin_email = "admin@yourdomain.com"

# letsencrypt test boolean to be used
SmartMachine.config.letsencrypt_test = false

# logger level
# DEBUG, INFO, WARN, ERROR, FATAL, UNKNOWN
SmartMachine.config.logger_level = "INFO"
