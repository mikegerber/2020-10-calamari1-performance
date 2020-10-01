#!/bin/bash

PYTHON3=/usr/bin/python3.6  # need a version that is supported by PyPi's TF 1.15
PIP_INSTALL="pip install --use-feature=2020-resolver -q"

# CPU only
export CUDA_VISIBLE_DEVICES=


prepare_test_data() {
  echo "Preparing test data..."
  if ! test -d dta19/1828-platen_gedichte; then
    if ! test -e dta19.tar.bz2; then
      if ! test -e GT4HistOCR.tar; then
        curl -o GT4HistOCR.tar https://zenodo.org/record/1344132/files/GT4HistOCR.tar?download=1
      fi
      tar -x -f GT4HistOCR.tar --strip-components=1 corpus/dta19.tar.bz2
    fi
    tar xf dta19.tar.bz2 dta19/1828-platen_gedichte
  fi
}

download_models() {
  echo "Downloading models..."
  if ! test -d model_0; then
    mkdir model_0
    (
      cd model_0
      curl -O https://qurator-data.de/calamari-models/GT4HistOCR/model.tar.xz
      tar xf model.tar.xz
      rm model.tar.xz
    )
  fi
  if ! test -d model_1; then
    mkdir model_1
    (
      cd model_1
      curl -O https://qurator-data.de/calamari-models/GT4HistOCR/2019-12-11T11_10+0100/model.tar.xz && \
      tar xf model.tar.xz
      rm model.tar.xz
    )
  fi
}

test_calamari_0() {
  env=`mktemp -d`
  virtualenv -q -p${PYTHON3} ${env}
  . $env/bin/activate
  $PIP_INSTALL --use-feature=2020-resolver -q https://github.com/Calamari-OCR/calamari/archive/v0.3.5.zip
  $PIP_INSTALL tensorflow==1.15.\*
  calamari-predict --version
  calamari-predict --files dta19/1828-platen_gedichte/*.png --checkpoint model_0/*.json
}

test_calamari_1() {
  env=`mktemp -d`
  virtualenv -q -p${PYTHON3} ${env}
  . $env/bin/activate
  $PIP_INSTALL --use-feature=2020-resolver -q https://github.com/Calamari-OCR/calamari/archive/master.zip  # calamari master for TF2.3 fixes
  $PIP_INSTALL tensorflow==2.3.\*
  calamari-predict --version
  calamari-predict --files dta19/1828-platen_gedichte/*.png --checkpoint model_1/*.json
}


prepare_test_data
download_models
test_calamari_0
test_calamari_1
