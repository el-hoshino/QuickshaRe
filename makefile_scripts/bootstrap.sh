#!/bin/zsh

install_mint() {
    
    echo "## Mint Installation"
    echo ""
    if type mint &> /dev/null; then
        echo "Mint has been installed. Skip mint installation."
        echo ""
    else
        git clone https://github.com/yonaskolb/Mint.git
        pushd Mint
        swift run mint install yonaskolb/mint
        ln -s ~/.mint/bin/mint /usr/local/bin
        popd
        rm -rf Mint
        echo "Mint installation finished."
        echo ""
    fi
    
}

# Install mint if needed
install_mint

# Install dependencies via mint
mint bootstrap
