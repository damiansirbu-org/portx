_btm() {
    local i cur prev opts cmd
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cmd=""
    opts=""

    for i in ${COMP_WORDS[@]}
    do
        case "${cmd},${i}" in
            ",$1")
                cmd="btm"
                ;;
            *)
                ;;
        esac
    done

    case "${cmd}" in
        btm)
            opts="-b -S -c -C -u -t -m -e -f -g -a -k -l -r -R -d -T -n -V -W -h --autohide_time --basic --battery --case_sensitive --celsius --color --config --current_usage --default_time_value --default_widget_count --default_widget_type --disable_advanced_kill --disable_click --dot_marker --enable_gpu_memory --expanded --fahrenheit --group --hide_avg_cpu --hide_table_gap --hide_time --kelvin --left_legend --mem_as_value --network_use_binary_prefix --network_use_bytes --network_use_log --process_command --rate --regex --retention --show_table_scroll_position --time_delta --tree --unnormalized_cpu --use_old_network_legend --version --whole_word --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --color)
                    COMPREPLY=($(compgen -W "default default-light gruvbox gruvbox-light nord nord-light" -- "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -C)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --default_time_value)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -t)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --default_widget_count)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --default_widget_type)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --rate)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -r)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --retention)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --time_delta)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -d)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
    esac
}

complete -F _btm -o bashdefault -o default btm
