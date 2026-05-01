function __api_subst_stream --description 'read stdin line-by-line, apply __api_subst, write to stdout'
    while read -l line
        echo (__api_subst $line)
    end
end
