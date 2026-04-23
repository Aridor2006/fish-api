function __api_load --description 'source current API env config if not already loaded'
    if not set -q API_ENV
        echo "no API env set — run: api-env <name>" >&2
        return 1
    end
    if set -q API_ENV_LOADED; and test "$API_ENV_LOADED" = "$API_ENV"
        return 0
    end
    set -l cfg $HOME/.config/api-test/envs/$API_ENV.fish
    if not test -f $cfg
        echo "env config missing: $cfg" >&2
        return 1
    end
    source $cfg; or return 1
    set -gx API_ENV_LOADED $API_ENV
end
