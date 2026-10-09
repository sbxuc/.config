#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
alias cl='clear'
alias ff='fastfetch'
alias cm='cmus'
alias ssn='sudo shutdown now'
alias sp='sudo pacman -S'

sch() {
    # Поисковая система
    local SEARCH_ENGINE="https://www.google.com/search?q="
    
    # Получаем текст из аргументов или stdin
    local query=""
    
    # Проверяем, есть ли данные в stdin (pipe)
    if [ ! -t 0 ]; then
        query=$(cat)
    # Если есть аргументы
    elif [ $# -gt 0 ]; then
        query="$*"
    # Если ничего нет — спрашиваем интерактивно
    else
        read -p "Поисковый запрос: " query
    fi
    
    # Проверяем, что запрос не пустой
    if [ -z "$query" ]; then
        echo "Пустой запрос"
        return 1
    fi
    
    # Проверяем, является ли запрос готовой ссылкой
    if [[ "$query" =~ ^https?:// ]]; then
        local url="$query"
    else
        # Кодируем запрос через python3
        local encoded_query=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$query")
        local url="${SEARCH_ENGINE}${encoded_query}"
    fi
    
    # Открываем браузер (xdg-open с fallback на firefox)
    if command -v xdg-open &> /dev/null; then
        xdg-open "$url" 2>/dev/null || firefox "$url" &
    else
        firefox "$url" &
    fi
    
    echo "Открыто: $url"
}
yt() {
    local base_url="https://www.youtube.com"
    
    # Если аргументы не переданы, просто открываем главную страницу
    if [ $# -eq 0 ]; then
        firefox "$base_url" &>/dev/null & disown
        return 0
    fi

    # Объединяем все аргументы в одну строку и надежно кодируем её для URL
    # (python3 в Arch Linux есть по умолчанию, это гарантирует корректную обработку кириллицы и спецсимволов)
    local query
    query=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote_plus(sys.argv[1]))" "$*")
    
    local search_url="${base_url}/results?search_query=${query}"
    
    # Открываем Firefox в фоне, скрываем вывод и открепляем процесс от терминала
    firefox "$search_url" &>/dev/null & disown
}

