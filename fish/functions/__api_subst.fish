function __api_subst --description 'substitute {{$...}} dynamic templates; each occurrence gets a fresh value'
    set -l s (string join \n -- $argv)
    while string match -q '*{{$timestamp}}*' -- "$s"
        set s (string replace -- '{{$timestamp}}' (date -u +%Y-%m-%dT%H:%M:%SZ) "$s")
    end
    while string match -q '*{{$guid}}*' -- "$s"
        set s (string replace -- '{{$guid}}' (uuidgen | string lower) "$s")
    end
    while string match -q '*{{$uuid}}*' -- "$s"
        set s (string replace -- '{{$uuid}}' (uuidgen | string lower) "$s")
    end
    printf '%s' "$s"
end
