#!/bin/bash

# This is a helper file for integration tests, and should not be used directly.
# Instead, this should be sourced from the IT specific sub-folders

if [ ! -z "$HERMIT_ENV" ]; then
  echo "Error: Deactivate Hermit environment before running integration tests"
  exit 1
fi

if [ ! -f ~/.local/bin/shellspec ]; then
  echo "Installing ShellSpec"
  curl -fsSL https://git.io/shellspec | sh -s -- --yes
fi

if [ ! -z $"HERMIT_EXE" ]; then
  unset HERMIT_EXE
fi

# Creates a "fake" release directory and sets HERMIT_DIST_URL to refer to it
fakeRelease() {
  DIR=$1

  echo "Compiling hermit"
  (
    . ../../bin/activate-hermit
    go build -o hermit ../../cmd/hermit
    go install ../../cmd/geninstaller
  )

  OS=$(../../bin/go version | awk '{print $NF}' | cut -d/ -f1)
  ARCH=$(../../bin/go version | awk '{print $NF}' | cut -d/ -f2)
  mkdir -p "$DIR"
  gzip -c hermit > "$DIR/hermit-${OS}-${ARCH}.gz"
  ../../.hermit/go/bin/geninstaller --dest="${DIR}/install.sh" --dist-url=-https://github.com/cashapp/hermit/releases/download/stable

  export HERMIT_DIST_URL=file://$PWD/$DIR
  echo $HERMIT_DIST_URL
}
