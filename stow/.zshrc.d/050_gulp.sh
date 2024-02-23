# Taken and modified from:
# https://github.com/akoenig/gulp.plugin.zsh/blob/master/gulp.plugin.zsh
#
# PR sent
#
# Using grep is much faster than using the default of gulp --simple-tasks
function _gulp_tasks () {
    compls=$(grep -Eho "gulp\.task[^,]*" {g,G}ulpfile.* 2>/dev/null | sed s/\"/\'/g | cut -d "'" -f 2 | sort)

    completions=(${=compls})
    compadd -- $completions
}

compdef _gulp_tasks gulp
