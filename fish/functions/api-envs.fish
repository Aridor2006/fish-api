function api-envs --description 'list available API envs'
    set -l envs_dir $HOME/.config/api-test/envs
    if not test -d $envs_dir
        return 0
    end
    for f in $envs_dir/*.fish
        set -l name (basename $f .fish)
        string match -q '_*' $name; and continue
        if set -q API_ENV; and test "$name" = "$API_ENV"
            echo "* $name"
        else
            echo "  $name"
        end
    end
end
