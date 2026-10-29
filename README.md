# Guarantees That Stack

Proof of concept for the article *Guarantees That Stack*
([English](https://blog.ragnagrok.com/en/2026-10-30-garantias-que-se-apilan) ·
[español](https://blog.ragnagrok.com/es/2026-10-30-garantias-que-se-apilan)):
security labels in Haskell's types, where **flattening a box inside another box doesn't
produce an effect but a guarantee**.

The idea in one line: the monad's `join` (flatten) uses the security lattice's *join* (⊔).
A secret box with a public box inside flattens into a secret box.

```haskell
flatten :: Labeled a (Labeled b x) -> Labeled (Join a b) x
```

## What's here

| File | What it shows |
|---|---|
| `src/Labels.hs` | One layer: confidentiality (`Public`, `Secret`). This is the code in the article. |
| `src/Layers.hs` | Two layers: confidentiality and integrity (`Trusted`, `Untrusted`). The lattice is the product, and the join is computed coordinate by coordinate. |
| `examples/Main.hs` | What does compile: a "model" transforms a trusted request, and the result is published and executed. |
| `rejected/*.hs` | What does **not** compile, each with the error it expects on its `-- expects:` line. |

The rejected ones:

- `Step5.hs`: the agent reads a key in step 1 and publishes it mixed with a request in step 5.
  `Couldn't match type ‘Secret’ with ‘Public’`.
- `FollowEmail.hs`: execute a command built from an email (prompt injection).
  `Couldn't match type ‘Untrusted’ with ‘Trusted’`.
- `Downgrade.hs`: put the secret inside a public box and flatten. It's still secret.
- `OpenTheBox.hs`: open the box by hand. The constructor isn't exported.
- `Coercion.hs`: force the type with `unsafeCoerce`. Under Safe Haskell, it can't even be imported.

The "model" is always an arbitrary function `String -> String`. The guarantees don't depend
on what it does: they hold **for all functions**.

## Running it

With GHC 9.12 and cabal:

```sh
./check.sh       # builds what should build and checks that the rejected files fail for the stated reason
cabal run demo   # the example that does compile
```

## What this proof of concept doesn't cover

It's a toy example, on purpose. The article has the details; in short:

- **The agent's code is the plan.** `label` lets the program create values at any level from
  what it writes itself. What's protected is the data that comes in at run time (keys, emails),
  as in CaMeL or TACIT.
- **Safe Haskell is part of the guarantee.** Without `Safe`, `unsafeCoerce` or `unsafePerformIO` open any box.
- **There's no declassification**: no controlled way to lower a label.
- **It doesn't cover side channels** (timing, termination), nor what isn't a data flow, such as a summary that lies.
- **A real model isn't a pure function**: it's a network call, and that call is another way out to the world.

## Further reading

- Russo, Claessen and Hughes (2008), *A Library for Light-Weight Information-Flow Security in Haskell* ([seclib](https://hackage.haskell.org/package/seclib)): this same idea, done properly.
- Abadi, Banerjee, Heintze and Riecke (1999), *A Core Calculus of Dependency*: one monad per lattice level.
- Odersky et al. (2026), [*Tracking Capabilities for Safer Agents*](https://arxiv.org/abs/2603.00991): `Classified[T]` in Scala 3 with capture checking.
- Debenedetti et al. (2025), [*Defeating Prompt Injections by Design*](https://arxiv.org/abs/2503.18813) (CaMeL).
- Costa, Köpf et al. (2025), [*Securing AI Agents with Information-Flow Control*](https://arxiv.org/abs/2505.23643) (FIDES).
