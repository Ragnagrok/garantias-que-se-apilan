#!/usr/bin/env bash
# Compila la biblioteca y el ejemplo, y comprueba que cada archivo de rechazados/
# falle con el error que anuncia en su línea "-- espera:".
set -euo pipefail
cd "$(dirname "$0")"

cabal build all -v0
echo "ok   la biblioteca y ejemplos/Main.hs compilan"

fallas=0
for f in rechazados/*.hs; do
  esperado=$(sed -n 's/^-- espera: //p' "$f")
  if salida=$(ghc -XHaskell2010 -fno-code -isrc -outputdir /tmp/garantias-ghc "$f" 2>&1); then
    echo "FALLA $f compiló, y no debería"; fallas=1
  elif grep -qF "$esperado" <<<"$salida"; then
    echo "ok   $f no compila: $esperado"
  else
    echo "FALLA $f no compila, pero no por lo esperado:"; echo "$salida"; fallas=1
  fi
done
exit $fallas
