#!/bin/bash
set -e

# Author: Akbar Shaikh
# Date  : 4-AUG-2019

echo "*******************************************"
echo "**************** Go-Lang ******************"
echo "*******************************************"

GO_VERSION="1.12.7"
OS=`uname -s`
ARCH=`uname -m`
GO_ROOT="/usr/local/go"
GO_PATH=$HOME/go

function usage {
    printf "    ./go-setup.sh -v <version> \n"
    printf "    Example: sudo ./go-setup.sh -v 1.12.7 \n"
    exit 1
}

while getopts :v: opt
do
    case $opt in
        v) GO_VERSION="$OPTARG" ;;
        \?) printf "Invalid option : $OPTARG \n"
            echo "Usage:"
        usage ;;
    esac
done

function install {
    echo
    printf "Scanning ... \n"
    
    # Check if there is any older version GO installed on this machine
    if [ -d /usr/local/go ]; then
        printf "Found an older version of GO ... \n"
        printf "Would you like to remove it ? [y/n]: "
        read result
        case "$result" in
            "y"|"Y"|"yes"|"Yes"|"YES") sudo rm -rf /usr/local/go ;;
            *) printf "Exiting ...\n"; exit 1 ;;
        esac
    fi
    
    # Check if the OS is Linux
    if [ "$OS" == "Linux" ] && [ "$ARCH" == "x86_64" ]; then
        pkg=go$GO_VERSION.linux-amd64.tar.gz
        pushd /tmp> /dev/null
        echo
        echo "Downloading ..."
        curl -ko ./$pkg https://storage.googleapis.com/golang/$pkg
        if [ $? -ne 0 ]; then
            echo "Failed to download the Go package."
            echo "Exiting ..."
            exit 1
        fi
        echo "Insatlling ..."
        sudo tar -C /usr/local/ -xzf $pkg
        rm -rf $pkg
        popd > /dev/null
        
        echo "Installed Successfully ..."
        # Setup GO
        setup
        echo "Open new terminal tab to start using GO!"
        echo "Go! setup completed " $'\xF0\x9F\x98\x81'
        exit 0
    fi
    
    # Check if the OS is Linux
    if [ "$OS" == "Darwin" ] && [ "$ARCH" == "x86_64" ]; then
        pkg=go$GO_VERSION.darwin-amd64.pkg
        pushd /tmp> /dev/null
        echo
        echo "Downloading ..."
        curl -ko ./$pkg https://storage.googleapis.com/golang/$pkg
        if [ $? -ne 0 ]; then
            echo "Failed to download the Go package."
            echo "Exiting ..."
            exit 1
        fi
        echo "Insatlling ..."
        sudo /usr/sbin/installer -pkg $pkg -target /
        rm -rf $pkg
        popd > /dev/null
        
        echo "Installed Successfully ..."
        # Setup GO
        setup
        echo "Open new terminal tab to start using GO!"
        echo "Go! setup completed %s" $'\xF0\x9F\x98\x81'
        exit 0
    fi
    
    echo "Cannot determine your OS [$OS] or you are not running 64-bit [$ARCH] machine."
    exit 1
}

function setup {
    if [ ! -d $GO_PATH ]; then
        mkdir $GO_PATH
        mkdir -p $GO_PATH/{src,pkg,bin}
    else
        mkdir -p $GO_PATH/{src,pkg,bin}
    fi
    
    if [ -n "`$SHELL -c 'echo $BASH_VERSION'`" ]; then
        sh_profile="bashrc"
        elif [ -n "`$SHELL -c 'echo $ZSH_VERSION'`" ]; then
        sh_profile="zshrc"
    fi
    
    if [ ! -f $HOME/.${sh_profile} ]; then
        touch $HOME/.${sh_profile}
    fi
    
    # Clean exiting GO paths
    if [ "$OS" == "Linux" ]; then
        sed -i '/export GOROOT/d' "$HOME/.${sh_profile}"
        sed -i '/$GOROOT\/bin/d' "$HOME/.${sh_profile}"
        sed -i '/export GOPATH/d' "$HOME/.${sh_profile}"
        sed -i '/$GOPATH\/bin/d' "$HOME/.${sh_profile}"
    fi
    
    if [ "$OS" == "Darwin" ]; then
        sed -i "" '/export GOROOT/d' "$HOME/.${sh_profile}"
        sed -i "" '/$GOROOT\/bin/d' "$HOME/.${sh_profile}"
        sed -i "" '/export GOPATH/d' "$HOME/.${sh_profile}"
        sed -i "" '/$GOPATH\/bin/d' "$HOME/.${sh_profile}"
        
    fi
    
    # Set Go paths.
    touch "$HOME/.${sh_profile}"                                                   1 ↵
    {
        echo '# Go'
        echo "export GOROOT=${GO_ROOT}"
        echo 'export PATH=$GOROOT/bin:$PATH'
        echo "export GOPATH=$GO_PATH"
        echo 'export PATH=$GOPATH/bin:$PATH'
    } >> "$HOME/.${sh_profile}"
    
    echo "Go $OS env path setup completed."
    echo "Go! setup Completed for $OS ..."
    echo "You are ready to GO!!!"
}

echo "Go! setup started for $OS ..."
install

