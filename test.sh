#!/bin/bash

PYTHON3=/usr/bin/python3.6  # need a version that is supported by PyPi's TF 1.15
PIP_INSTALL="pip install --use-feature=2020-resolver -q"


prepare_test_data() {
  if ! test -e dta19.tar.bz2; then
    if ! test -e GT4HistOCR.tar; then
      curl -o GT4HistOCR.tar https://zenodo.org/record/1344132/files/GT4HistOCR.tar?download=1
    fi
    tar -x -f GT4HistOCR.tar --strip-components=1 corpus/dta19.tar.bz2
  fi
}

test_calamari_0() {
  env=`mktemp -d`
  virtualenv -q -p${PYTHON3} ${env}
  . $env/bin/activate
  $PIP_INSTALL --use-feature=2020-resolver -q https://github.com/Calamari-OCR/calamari/archive/v0.3.5.zip
  calamari-predict --version
}

test_calamari_1() {
  env=`mktemp -d`
  virtualenv -q -p${PYTHON3} ${env}
  . $env/bin/activate
  $PIP_INSTALL --use-feature=2020-resolver -q https://github.com/Calamari-OCR/calamari/archive/master.zip  # calamari master for TF2.3 fixes
  calamari-predict --version
}


prepare_test_data
test_calamari_0
test_calamari_1
