# macOS quarantine
alias unquarantine="sudo xattr -rd com.apple.quarantine"

# Open a webserver serving the current directory and execute a browser to point
# at it
alias server='open http://localhost:8000 && python3 -m http.server'
