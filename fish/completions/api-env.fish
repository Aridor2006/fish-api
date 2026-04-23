function __api_env_complete
    set -l envs_dir $HOME/.config/api-test/envs
    test -d $envs_dir; or return
    for f in $envs_dir/*.fish
        set -l name (basename $f .fish)
        string match -q '_*' $name; and continue
        echo $name
    end
end

complete -c api-env -f
complete -c api-env -n '__fish_is_first_token' -a '(__api_env_complete)' -d 'API env'
