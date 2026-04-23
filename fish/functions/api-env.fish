function api-env --description 'switch or show the current API env'
    set -l envs_dir $HOME/.config/api-test/envs

    if test (count $argv) -eq 0
        if set -q API_ENV
            echo $API_ENV
        else
            echo "(no env set)" >&2
            return 1
        end
        return 0
    end

    set -l name $argv[1]
    set -l cfg $envs_dir/$name.fish
    if not test -f $cfg
        echo "no env config at $cfg" >&2
        echo "available:" >&2
        api-envs >&2
        return 1
    end

    api-auth-clear
    set -e API_ENV_LOADED
    for v in API_BASE_URL API_AUTH_TYPE API_TOKEN_URL API_CLIENT_ID API_CLIENT_SECRET API_SCOPE API_TOKEN_AUTH_STYLE API_USERNAME API_PASSWORD API_EXTRA_ARGS
        set -e $v
    end

    set -U API_ENV $name
    __api_load; or return 1
    echo "switched to $name ($API_BASE_URL)"
end
