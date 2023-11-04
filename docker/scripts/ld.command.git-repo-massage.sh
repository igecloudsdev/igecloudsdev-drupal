#!/usr/bin/env bash
# File
#
# This file contains git-repo-massage command for local-docker script ld.sh.

function ld_command_git-repo-massage_exec() {

    if [ ! -d ".git" ]; then
        echo -e "${Red}ERROR: Could not locate Git repository (.git folder missing).${Color_Off}"
        return 1
    fi

    # Check if we have initial local-docker commit in git history.
    GIT_COMMIT_MATCH=$(git rev-list HEAD | tail -n 1 |grep -c "99c1a03ce16f2ff1fe33bc136e09fcbcb0fd5397" )
    [ "$LD_VERBOSE" -ge "2" ] && [ "$GIT_COMMIT_MATCH" -gt "0" ] && echo "Initial Git commit matches known initial commit hash in Exove/local-docker.git"

    # This catches both https and ssh based remote addresses.
    GIT_REPO_MATCH=$(git config --get remote.origin.url | grep -c -E 'Exove\/local\-docker\.git$')

    [ "$LD_VERBOSE" -ge "2" ] && [ "$GIT_REPO_MATCH" -gt "0" ] && echo "Git repository is connected to Exove/local-docker.git"

    if [ "$GIT_REPO_MATCH" -gt "0" ]; then
        echo -e "${BYellow}NOTE${Yellow}: You are still connected to ${BYellow}Exove/local-docker.git${Yellow}.${Color_Off}"
        VALID=
        echo
        echo -e "${BBlack}== GIT repository address ==${Color_Off}"
        while [ -z "$VALID" ]; do
            echo "What is your Git repository address?"
            echo "It is YOUR responsibility to ensure it is correct and functional. However local-docker does not touch your git remote, ever."
            echo "If you leave this empty Git remote will not be edited."
            read -p "Git repository address: " ANSWER
             # Very simple test to see we have .git at the end of remote url.
            TEST_HAS_DOTGIT=$(echo $ANSWER | egrep -e '.*\.git$')
            TEST_HAS_SPACES=$(echo $ANSWER | egrep -e '\s')
            if [ -z "$ANSWER" ] || ( [ "${#TEST_HAS_DOTGIT}" -gt "0" ] && [ "${#TEST_HAS_SPACES}" -eq "0" ] ); then
                VALID=1
            else
                echo -e "${Red}ERROR: Git repository address is invalid. Please try again. No spaces allowed, must end with '.git'.${Color_Off}"
                echo
            fi
        done
        if [ -n "$ANSWER" ]; then
            git remote set-url origin $ANSWER
            [ "$LD_VERBOSE" -ge "2" ] && echo -e "${BYellow}INFO: ${Yellow}Git remotes (all):" && git remote -v
            [ "$LD_VERBOSE" -ge "2" ] && echo -e "${Color_Off}"
            GIT_REPO_MATCH=0
        fi
    fi

    if [ "$GIT_COMMIT_MATCH" -gt "0" ] && [ "$GIT_REPO_MATCH" -eq "0" ]; then
        [ "$LD_VERBOSE" -ge "1" ] && echo -ne "${BYellow}INFO: ${Yellow}Your Git history will be reduced to a single commit now (in 5 secs)."
        [ "$LD_VERBOSE" -ge "1" ] && timer 5
        git checkout --orphan main-tmp
        # Remove files related to local-dockers Github repository management.
        rm -rf .github
        git commit -aqm "Initial commit from local-docker v.${LOCAL_DOCKER_VERSION}"
        git branch -D main
        git branch -m main-tmp main
    else
        [ "$LD_VERBOSE" -ge "2" ] && echo "Commit hash check done, looks like the the git history has been massaged already."
    fi

    # In case all checks failed, we must return 0 to have some SIGINT value for
    # the main script.
    return 0
}

function ld_command_git-repo-massage_help() {
    echo "Tries to flatten your git history and update remote paths."
}

function ld_command_git-repo-massage_extended_help() {
    echo "This is used to clean project repository history and to connect repository to new project remote."
    echo
    echo "Example: $SCRIPT_NAME_SHORT git-repo-massage "
}
