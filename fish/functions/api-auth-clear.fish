function api-auth-clear --description 'clear cached access token; forces re-auth on next call'
    set -e API_ACCESS_TOKEN
    set -e API_ACCESS_TOKEN_EXPIRES_AT
end
