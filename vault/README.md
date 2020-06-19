# Vault

## Introduction

Vault is an open-source tool used for the storage and management of secrets. The secrets are embedding all personal or sensitive informations as credentials, SSH keys, login/password, AWS keys, API tokens, etc. Vault helps resolving the following management issues :

| Backend | Use |
|---------------|----------------|
| Storage | Where secrets are stored |
| Secret | Handles secrets |
| Auth | Handles authentication and autorisations |
| Audit | Logs all requests and responses |

More on Vault in its [documentation](https://www.vaultproject.io/docs).

## Usage

Fill the `.env.vault` file with the name of the Postgres container. If you do not wish to have standard credentials `vault:vault` for Vault in Postgres, modify it in `.env.vault` and `vault/config/vault-config.json` in `connection_url`.

## Vault unsealing

In Vault container :

```bash
vault operator init
```

Five keys are going to be generated and three shall be used for unsealing with :

```bash
vault operator unseal
```

After the third, `sealed` in the response will go to `false`. Use the root token to finish the unsealing :

```bash
vault login
```

Be sure that you remember or store your root token somewhere, you will need it to access the UI.
