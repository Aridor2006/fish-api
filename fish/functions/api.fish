function api --description 'httpie wrapper: api <METHOD> <path|url> [httpie args...]'
    if test (count $argv) -lt 2
        echo "usage: api <METHOD> <path|url> [httpie args...]" >&2
        echo "  path starting with http(s):// is used as-is; otherwise API_BASE_URL is prepended" >&2
        echo "  templates {{\$timestamp}} and {{\$guid}}/{{\$uuid}} are substituted in url, args, and stdin" >&2
        echo "  for templated bodies, redirect a file: api-post /endpoint < body.json" >&2
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
    set url (__api_subst -- $url)

    set -l subbed_rest
    for a in $rest
        set -a subbed_rest (__api_subst -- $a)
    end

    set -l extra
    set -q API_EXTRA_ARGS; and set extra $API_EXTRA_ARGS

    if isatty stdin
        switch $API_AUTH_TYPE
            case basic
                http $extra --auth "$API_USERNAME:$API_PASSWORD" $method $url $subbed_rest
            case apikey
                http $extra $method $url "$API_KEY_HEADER:$API_KEY" $subbed_rest
            case client_credentials
                http $extra $method $url "Authorization:Bearer $API_ACCESS_TOKEN" $subbed_rest
        end
    else
        switch $API_AUTH_TYPE
            case basic
                __api_subst_stream | http $extra --auth "$API_USERNAME:$API_PASSWORD" $method $url $subbed_rest
            case apikey
                __api_subst_stream | http $extra $method $url "$API_KEY_HEADER:$API_KEY" $subbed_rest
            case client_credentials
                __api_subst_stream | http $extra $method $url "Authorization:Bearer $API_ACCESS_TOKEN" $subbed_rest
        end
    end
end
