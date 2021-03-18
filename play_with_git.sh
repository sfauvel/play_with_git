#! /bin/bash

SHOW_CMD=true
# Dispaly command and execute it
GIT() {
    if [ "$SHOW_CMD" = true ] ; then
        echo "------------------------------"
        echo -e "\e[33m> git $@\e[0m"
    fi
    git "$@"
}

run() {

    tmp_dir=$(mktemp -d -t testgit-XXXXXXXXXX) 
    pushd $tmp_dir > /dev/null

    echo "Execute in directory: $tmp_dir"


    echo -e "\e[32m\n=============================="
    echo -e "===   $1"
    echo -e "==============================\n\e[0m"
    $1
    echo -e "\n==============================\n"

    popd
}

log() {
    echo -e "\n\e[32m=== $1\e[0m"
}

help() {
    echo Select one of this method as parameter
    
    CURRENT_SCRIPT=`basename "$0"`
    grep "[s]tep_.*() {" "$CURRENT_SCRIPT" | cut -d '(' -f 1 | cut -d '_' -f 2-100
}

# #######################################################

init_repo() {
    echo "Hello" > file_A.txt  
    echo "Hello" > file_B.txt  
    echo "Hello" > file_C.txt  
    echo "Hello" > file_E.txt  
    echo "Hello" > file_F.txt  
    echo "Hello" > file_G.txt

    SHOW_CMD=false

    GIT init
    GIT add file_A.txt
    GIT add file_B.txt
    GIT add file_C.txt 
    GIT add file_E.txt  
    GIT add file_F.txt 
    GIT add file_G.txt 
    GIT commit -m "Init project"

    SHOW_CMD=true

}

append_and_commit() {
    COMMIT_COUNTER=$(($COMMIT_COUNTER+1))
    local FILE=$1
    local TEXT=$2
    local MESSAGE=${3:-"Commit $COMMIT_COUNTER"}
    echo "$TEXT" >> $FILE
    GIT add $FILE
    GIT commit -m "$MESSAGE"
}


# #######################################################

step_version() {
    GIT --version    
}

step_view_files() {
    GIT ls-files
}

step_create_repo() {
    echo "Hello World" > readme.adoc
    GIT init
    GIT add readme.adoc
    GIT commit -m "Init project"
    GIT log --oneline
}

step_init() {
    init_repo
    GIT log --oneline
}

step_init_multi_commit() {
    init_repo
    append_and_commit file_A.txt "World" "Add World to file A"
    append_and_commit file_B.txt "World" "Add World to file B"
    GIT log --oneline
}

step_show_tree() {
    init_repo
    echo " World" >> file_F.txt
    GIT add --all
    GIT commit -m "Add World to file F"
    
    GIT checkout -b develop
    append_and_commit file_A.txt "World" "Add World to file A"

    GIT checkout master
    append_and_commit file_B.txt "World" "Add World to file B"

    GIT log --oneline --graph --all
}

step_branch_create() {
    init_repo
    GIT branch --all

    log "Create branch and stay on current branch"
    GIT branch featureA
    GIT branch featureB

    GIT branch --all
    
    log "Create branch and checkout it"
    GIT checkout -b featureC

    GIT branch --all
}

step_merge() {
    init_repo
    echo " World" >> file_F.txt
    GIT add --all
    GIT commit -m "Add World to file F"
    
    GIT checkout -b develop
    append_and_commit file_A.txt "World" "Add World to file A"
    
    GIT checkout master
    append_and_commit file_B.txt "World" "Add World to file B"
    append_and_commit file_C.txt "World" "Add World to file C"

    GIT merge develop -m "Merge develop"

    GIT log --oneline --graph --all
}

prepare_step_merge() {
    init_repo
    echo " World" >> file_F.txt
    GIT add --all
    GIT commit -m "Add World to file F"
    
    GIT checkout -b develop
    append_and_commit file_A.txt "World" "Add World to file A"
    append_and_commit file_B.txt "World" "Add World to file B"
}

step_merge_ff() {
    prepare_step_merge

    GIT checkout master
    GIT merge develop -m "Merge develop"

    GIT log --oneline --graph --all
}

step_merge_no_ff() {
    prepare_step_merge

    GIT checkout master
    GIT merge --no-ff develop -m "Merge develop"

    GIT log --oneline --graph --all
}

step_rebase() {
    init_repo
    echo "World" >> file_F.txt
    GIT add --all
    GIT commit -m "Add World to file F"
    
    GIT checkout -b develop
    append_and_commit file_A.txt "World" "Add World to file A"
    
    GIT checkout master
    append_and_commit file_B.txt "World" "Add World to file B"
    append_and_commit file_C.txt "World" "Add World to file C"

    GIT rebase develop

    GIT log --oneline --graph --all
}

step_merge_conflict() {
    init_repo
    echo " World" >> file_F.txt
    GIT add --all
    GIT commit -m "Add World to file F"
    
    GIT checkout -b develop
    append_and_commit file_A.txt "World" "Add World to file A"
    
    GIT checkout master
    append_and_commit file_A.txt "Universe" "Add World to file A"

    GIT merge develop -m "Merge develop"

    cat file_A.txt

    echo "Hello" > file_A.txt
    echo "World and Universe" >> file_A.txt
    GIT add file_A.txt
    
    GIT -c core.editor=/bin/true merge --continue
    
    GIT log --oneline --graph --all
    
    cat file_A.txt
}


step_cherry_pick() {
    init_repo
    echo " World" >> file_F.txt
    GIT add --all
    GIT commit -m "Add World to file F"
    
    GIT checkout -b develop
    append_and_commit file_A.txt "World" "Add World to file A"
    append_and_commit file_B.txt "World" "Add World to file B"
    append_and_commit file_C.txt "World" "Add World to file C"
    
    GIT checkout master
    append_and_commit file_D.txt "Universe" "Add World to file D"
    append_and_commit file_E.txt "Universe" "Add World to file E"

    COMMIT=$(git log --oneline --all | grep "file B" | cut -d ' ' -f 1)
    GIT cherry-pick $COMMIT

    GIT log --oneline --graph --all
}

# https://emmanuelbernard.com/blog/2014/04/14/split-a-commit-in-two-with-git/
step_split_last_commit_in_two() {
    GIT init
    
    append_and_commit file_A.txt "World" "Add World to file A"
    append_and_commit file_B.txt "World" "Add World to file B"
    
    echo "World" "Add World to file C" >> file_C.txt
    echo "World" "Add World to file D" >> file_D.txt
    GIT add --all
    GIT commit -m "Add two files"

    GIT log --oneline --all

    GIT_SEQUENCE_EDITOR="sed -i -re 's/^pick \edit /'" GIT rebase -i HEAD^

    GIT reset HEAD^
    GIT status

    GIT add file_C.txt
    GIT commit -m "Add file C"
    GIT add file_D.txt
    GIT commit -m "Add file D"
    
    GIT rebase --continue

    GIT log --oneline --all

    GIT status
    pwd
}

step_view_modify_file() {
    GIT init
    
    append_and_commit file_A.txt "World" "Add World to file A"
    append_and_commit file_B.txt "World" "Add World to file B"
    append_and_commit file_C.txt "World" "Add World to file C"
    append_and_commit file_D.txt "World" "Add World to file D"
    append_and_commit file_E.txt "World" "Add World to file E"
    append_and_commit file_F.txt "World" "Add World to file F"
    
    GIT log --oneline --all

    COMMIT_BEGIN=$(git log --oneline --all | grep "file B" | cut -d ' ' -f 1)
    COMMIT_END=$(git log --oneline --all | grep "file E" | cut -d ' ' -f 1)
    GIT diff --name-only $COMMIT_BEGIN $COMMIT_END
}


# Create a feature branch, make a pull request and start another branch 
# from the first one to continue development.
step_pull_request_and_continue_to_commit() {
    step_create_repo
    
    append_and_commit file_A.txt "World"
    append_and_commit file_B.txt "World"

    GIT checkout -b featureA 
    append_and_commit file_A.txt "Universe"
    append_and_commit file_A.txt "Bob"
    append_and_commit file_A.txt "John"

    GIT checkout -b featureB
    append_and_commit file_B.txt "XXXX"

    GIT checkout master
    append_and_commit file_C.txt "CCCC"
    GIT log --oneline --graph --all

    GIT merge featureA -m "Merge featureA to master"
    GIT log --oneline --graph --all
    
    GIT checkout featureB
    # With rebase, second feature seems to start from master.
    GIT rebase master

    GIT log --oneline --graph --all

    append_and_commit file_B.txt "ZZZ" "Add ZZZ to file B"
    GIT checkout master
    append_and_commit file_D.txt "DDDD" "Add DDD to file D"
    GIT merge featureB -m "Merge featureB to master"

    GIT log --oneline --graph --all
}

# #######################################################

USE_CASE=step_$1
COMMIT_COUNTER=0
if [[ -z $1 || -z $(command -v $USE_CASE) ]]; then
    help
else
    run $USE_CASE
fi
