# rice rules

these are the rules for changing the setup.

## before changing anything

1. identify the exact file
2. back it up
3. make one scoped change
4. verify the config
5. test the affected application
6. keep the rollback path obvious

## never

- touch yasb casually
- rewrite unrelated configs
- replace a working config with a generated guess
- remove existing keybindings without checking them
- make broad changes just to fix one visual issue
- commit secrets
- commit api keys
- commit authentication tokens
- commit machine-specific credentials

## public repo

safe to commit:
- config templates
- non-secret settings
- keybindings
- theme values
- workspace definitions
- scripts that do not contain secrets
- documentation
- software lists

do not commit:
- credentials
- tokens
- private keys
- browser profiles
- personal data
- exported passwords
- private application data

## change philosophy

small, reversible, verified.
