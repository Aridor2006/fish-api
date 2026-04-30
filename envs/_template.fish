# Template API env config. Copy to <name>.fish and edit.
# Called by __api_load. Use `set -gx` (NOT `set -U`) so secrets
# stay in the current shell and never hit ~/.config/fish/fish_variables.

set -gx API_BASE_URL "https://api.example.com"

# One of: basic | apikey | client_credentials
set -gx API_AUTH_TYPE "client_credentials"

# ---- client_credentials ----
set -gx API_TOKEN_URL "https://auth.example.com/oauth/token"
set -gx API_CLIENT_ID "my-client-id"
set -gx API_CLIENT_SECRET (pass show api/example/client-secret)
# optional:
# set -gx API_SCOPE "read write"
# How to send client creds to token endpoint: form | basic (default: form)
# set -gx API_TOKEN_AUTH_STYLE "basic"

# ---- basic ----
# set -gx API_USERNAME "me"
# set -gx API_PASSWORD (pass show api/example/password)

# ---- apikey ----
# set -gx API_KEY (pass show api/example/api-key)
# Header name (default: X-API-Key). Examples: Authorization, Api-Key, X-Api-Token.
# If your API expects a prefix like "Bearer xyz" or "ApiKey xyz", include it in API_KEY.
# set -gx API_KEY_HEADER "X-API-Key"

# Optional: extra httpie args applied to every call (array).
# set -gx API_EXTRA_ARGS --verify=no
