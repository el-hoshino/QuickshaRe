#!/bin/bash

# Install mint if needed
which mint > /dev/null || {
  git clone https://github.com/yonaskolb/Mint.git
  pushd Mint
  swift run mint install yonaskolb/mint
  popd
  rm -rf Mint
}

# Install dependencies via mint
mint bootstrap
