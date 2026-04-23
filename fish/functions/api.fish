function api --description 'httpie wrapper: api <METHOD> <path|url> [httpie args...]'
    if test (count $argv) -lt 2
        echo "usage: api <METHOD> <path|url> [httpie args...]" >&2
        echo "  path starting with http(s):// is used as-is; otherwise API_BASE_URL is prepended" >&2
        return 2
    end

    __api_load; or return 1
    __api_auth; or return 1

    set -l method $argv[1]
    set -l target $argv[2]
    set -l rest
    if test (count $argv) -ge 3
        set rest $argv[3..]
    end

    set -l url
    if string match -qr '^https?://' -- $target
        set url $target
    else
        if not string match -q '/*' -- $target
            set target /$target
        end
        set url $API_BASE_URL$target
    end

    set -l extra
    set -q API_EXTRA_ARGS; and set extra $API_EXTRA_ARGS

    switch $API_AUTH_TYPE
        case basic
            http $extra --auth "$API_USERNAME:$API_PASSWORD" $method $url $rest
        case client_credentials
            http $extra $method $url "Authorization:Bearer $API_ACCESS_TOKEN" $rest
    end
end
