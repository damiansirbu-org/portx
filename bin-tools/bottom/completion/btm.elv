
use builtin;
use str;

set edit:completion:arg-completer[btm] = {|@words|
    fn spaces {|n|
        builtin:repeat $n ' ' | str:join ''
    }
    fn cand {|text desc|
        edit:complex-candidate $text &display=$text' '(spaces (- 14 (wcswidth $text)))$desc
    }
    var command = 'btm'
    for word $words[1..-1] {
        if (str:has-prefix $word '-') {
            break
        }
        set command = $command';'$word
    }
    var completions = [
        &'btm'= {
            cand --color 'Use a color scheme, use --help for info.'
            cand -C 'Sets the location of the config file.'
            cand --config 'Sets the location of the config file.'
            cand -t 'Default time value for graphs.'
            cand --default_time_value 'Default time value for graphs.'
            cand --default_widget_count 'Sets the n''th selected widget type as the default.'
            cand --default_widget_type 'Sets the default widget type, use --help for info.'
            cand -r 'Sets the data refresh rate.'
            cand --rate 'Sets the data refresh rate.'
            cand --retention 'The timespan of data stored.'
            cand -d 'The amount of time changed upon zooming.'
            cand --time_delta 'The amount of time changed upon zooming.'
            cand --autohide_time 'Temporarily shows the time scale in graphs.'
            cand -b 'Hides graphs and uses a more basic look.'
            cand --basic 'Hides graphs and uses a more basic look.'
            cand --battery 'Shows the battery widget.'
            cand -S 'Enables case sensitivity by default.'
            cand --case_sensitive 'Enables case sensitivity by default.'
            cand -c 'Sets the temperature type to Celsius.'
            cand --celsius 'Sets the temperature type to Celsius.'
            cand -u 'Sets process CPU% to be based on current CPU%.'
            cand --current_usage 'Sets process CPU% to be based on current CPU%.'
            cand --disable_advanced_kill 'Hides advanced process killing.'
            cand --disable_click 'Disables mouse clicks.'
            cand -m 'Uses a dot marker for graphs.'
            cand --dot_marker 'Uses a dot marker for graphs.'
            cand --enable_gpu_memory 'Enable collecting and displaying GPU memory usage.'
            cand -e 'Expand the default widget upon starting the app.'
            cand --expanded 'Expand the default widget upon starting the app.'
            cand -f 'Sets the temperature type to Fahrenheit.'
            cand --fahrenheit 'Sets the temperature type to Fahrenheit.'
            cand -g 'Groups processes with the same name by default.'
            cand --group 'Groups processes with the same name by default.'
            cand -a 'Hides the average CPU usage.'
            cand --hide_avg_cpu 'Hides the average CPU usage.'
            cand --hide_table_gap 'Hides spacing between table headers and entries.'
            cand --hide_time 'Hides the time scale.'
            cand -k 'Sets the temperature type to Kelvin.'
            cand --kelvin 'Sets the temperature type to Kelvin.'
            cand -l 'Puts the CPU chart legend to the left side.'
            cand --left_legend 'Puts the CPU chart legend to the left side.'
            cand --mem_as_value 'Defaults to showing process memory usage by value.'
            cand --network_use_binary_prefix 'Displays the network widget with binary prefixes.'
            cand --network_use_bytes 'Displays the network widget using bytes.'
            cand --network_use_log 'Displays the network widget with a log scale.'
            cand --process_command 'Show processes as their commands by default.'
            cand -R 'Enables regex by default.'
            cand --regex 'Enables regex by default.'
            cand --show_table_scroll_position 'Shows the scroll position tracker in table widgets.'
            cand -T 'Defaults the process widget be in tree mode.'
            cand --tree 'Defaults the process widget be in tree mode.'
            cand -n 'Show process CPU% usage without normalizing over the number of cores.'
            cand --unnormalized_cpu 'Show process CPU% usage without normalizing over the number of cores.'
            cand --use_old_network_legend 'DEPRECATED - uses a separate network legend.'
            cand -V 'Prints version information.'
            cand --version 'Prints version information.'
            cand -W 'Enables whole-word matching by default.'
            cand --whole_word 'Enables whole-word matching by default.'
            cand -h 'Print help (see more with ''--help'')'
            cand --help 'Print help (see more with ''--help'')'
        }
    ]
    $completions[$command]
}
