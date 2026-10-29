# Garantías que se apilan

Prueba de concepto del artículo
[*Garantías que se apilan*](https://blog.ragnagrok.com/es/2026-10-30-garantias-que-se-apilan):
etiquetas de seguridad en los tipos de Haskell, donde **aplanar una caja dentro de otra
no produce un efecto sino una garantía**.

La idea en una línea: el `join` de la mónada (aplanar) usa el *join* del retículo de
seguridad (⊔). Una caja secreta con una caja pública adentro se aplana en una caja secreta.

```haskell
aplanar :: Etiquetado a (Etiquetado b x) -> Etiquetado (Join a b) x
```

## Qué hay

| Archivo | Qué muestra |
|---|---|
| `src/Etiquetas.hs` | Una capa: confidencialidad (`Publico`, `Secreto`). Es el código del artículo. |
| `src/Capas.hs` | Dos capas: confidencialidad e integridad (`Confiable`, `Dudoso`). El retículo es el producto y el join se calcula coordenada por coordenada. |
| `ejemplos/Main.hs` | Lo que sí compila: un "modelo" transforma un pedido confiable, y el resultado se publica y se ejecuta. |
| `rechazados/*.hs` | Lo que **no** compila, cada uno con el error que espera en su línea `-- espera:`. |

Los rechazados:

- `Paso5.hs`: el agente lee una clave en el paso 1 y la publica mezclada con un pedido en el paso 5.
  `Couldn't match type ‘Secreto’ with ‘Publico’`.
- `SeguirMail.hs`: ejecutar un comando armado a partir de un mail (inyección de instrucciones).
  `Couldn't match type ‘Dudoso’ with ‘Confiable’`.
- `BajarDeNivel.hs`: meter el secreto en una caja pública y aplanar. Sigue siendo secreto.
- `AbrirLaCaja.hs`: abrir la caja a mano. El constructor no se exporta.
- `Coercion.hs`: forzar el tipo con `unsafeCoerce`. Con Safe Haskell, ni siquiera se puede importar.

El "modelo" es siempre una función cualquiera `String -> String`. Las garantías no dependen
de lo que haga: valen **para toda función**.

## Cómo correrlo

Con GHC 9.12 y cabal:

```sh
./verificar.sh                         # compila lo que debe compilar y comprueba que los rechazados fallen por lo que dicen
cabal run demo                         # el ejemplo que sí compila
```

## Lo que esta prueba de concepto no cubre

Es un ejemplo de juguete, a propósito. En el artículo están los detalles; en corto:

- **El código del agente es el plan.** `etiquetar` deja crear valores de cualquier nivel a partir
  de lo que el propio programa escribe. Lo que se protege son los datos que entran en tiempo de
  ejecución (claves, mails), como en CaMeL o TACIT.
- **Safe Haskell es parte de la garantía.** Sin `Safe`, `unsafeCoerce` o `unsafePerformIO` abren cualquier caja.
- **No hay desclasificación**: no hay forma controlada de bajar una etiqueta.
- **No cubre canales laterales** (tiempos, terminación) ni lo que no es un flujo de datos, como un resumen que miente.
- **El modelo real no es una función pura**: es una llamada por la red, y esa llamada es otra salida al mundo.

## Para seguir

- Russo, Claessen y Hughes (2008), *A Library for Light-Weight Information-Flow Security in Haskell* ([seclib](https://hackage.haskell.org/package/seclib)): esto mismo, hecho en serio.
- Abadi, Banerjee, Heintze y Riecke (1999), *A Core Calculus of Dependency*: una mónada por cada nivel del retículo.
- Odersky y otros (2026), [*Tracking Capabilities for Safer Agents*](https://arxiv.org/abs/2603.00991): `Classified[T]` en Scala 3 con capture checking.
- Debenedetti y otros (2025), [*Defeating Prompt Injections by Design*](https://arxiv.org/abs/2503.18813) (CaMeL).
- Costa, Köpf y otros (2025), [*Securing AI Agents with Information-Flow Control*](https://arxiv.org/abs/2505.23643) (FIDES).
