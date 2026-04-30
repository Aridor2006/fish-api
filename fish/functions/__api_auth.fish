function __api_auth --description 'ensure we have valid auth state for the current env'
    switch $API_AUTH_TYPE
        case basic
            if not set -q API_USERNAME; or not set -q API_PASSWORD
                echo "basic auth: API_USERNAME / API_PASSWORD not set in env config" >&2
                return 1
            end
            return 0

        case apikey
            if not set -q API_KEY
                echo "apikey: API_KEY not set in env config" >&2
                return 1
            end
            if not set -q API_KEY_HEADER
                set -gx API_KEY_HEADER X-API-Key
            end
            return 0

        case client_credentials
            if set -q API_ACCESS_TOKEN; and set -q API_ACCESS_TOKEN_EXPIRES_AT
                if test (date +%s) -lt $API_ACCESS_TOKEN_EXPIRES_AT
                    return 0
                end
            end

            for v in API_TOKEN_URL API_CLIENT_ID API_CLIENT_SECRET
                if not set -q $v
                    echo "client_credentials: $v not set in env config" >&2
                    return 1
                end
            end

            set -l style form
            set -q API_TOKEN_AUTH_STYLE; and set style $API_TOKEN_AUTH_STYLE

            set -l form_args grant_type=client_credentials
            set -q API_SCOPE; and set -a form_args "scope=$API_SCOPE"

            set -l resp
            switch $style
                case basic
                    set resp (http --check-status --ignore-stdin --form POST $API_TOKEN_URL \
                        --auth "$API_CLIENT_ID:$API_CLIENT_SECRET" \
                        $form_args 2>&1)
                case form
                    set -a form_args "client_id=$API_CLIENT_ID" "client_secret=$API_CLIENT_SECRET"
                    set resp (http --check-status --ignore-stdin --form POST $API_TOKEN_URL $form_args 2>&1)
                case '*'
                    echo "unknown API_TOKEN_AUTH_STYLE: $style (use 'form' or 'basic')" >&2
                    return 1
            end
            if test $status -ne 0
                echo "token request failed:" >&2
                echo $resp >&2
                return 1
            end

            set -l token (echo $resp | jq -r '.access_token // empty')
            if test -z "$token"
                echo "token response had no access_token:" >&2
                echo $resp >&2
                return 1
            end
            set -l expires_in (echo $resp | jq -r '.expires_in // 3600')

            set -gx API_ACCESS_TOKEN $token
            set -gx API_ACCESS_TOKEN_EXPIRES_AT (math (date +%s) + $expires_in - 60)
            return 0

        case '*'
            echo "unknown API_AUTH_TYPE: '$API_AUTH_TYPE' (use 'basic', 'apikey', or 'client_credentials')" >&2
            return 1
    end
end
