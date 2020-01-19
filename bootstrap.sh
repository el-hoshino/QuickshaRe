#!/bin/bash

# Install mint if needed
which mint > /dev/null || {
  git clone https://github.com/yonaskolb/Mint.git
  cd Mint
  swift run mint install yonaskolb/mint
  cd ../
}

# Install dependencies via mint
mint bootstrap
