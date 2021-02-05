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

    echo -e "\n==============================\n"
    $1
    echo -e "\n==============================\n"

    popd
}

help() {
    echo Select one of this method as parameter
    
    CURRENT_SCRIPT=`basename "$0"`
    grep "[s]tep_.*() {" "$CURRENT_SCRIPT"
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


# #######################################################

if [[ -z $1 || -z $(command -v $1) ]]; then
    help
else
    run $1
fi
