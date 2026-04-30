function __api_subst_stream --description 'read stdin, apply __api_subst, write to stdout'
    set -l buf (cat | string collect --no-trim-newlines)
    if test -n "$buf"
        __api_subst "$buf"
    end
end
