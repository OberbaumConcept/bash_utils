# ssh-agent-vault

Tool to use ssh-keys from ssh-agent to encrypt/decrypt passwords.

Select a ssh-key provided by ssh-agent, sign a fixed message with it and use
the signed message to encrypt the password and store it on disk.  
See `ssh-agent-vault --help` for more details.

## Requirements

- `bash` >= 4.0
- `ssh-add`
- `openssl`
- `sha256sum`
- `running ssh-agent`

## Usage

Example use case: ansible vault

Tired of typing ansible vault passwords, but uneasy to just save it in a file and use
`ANSIBLE_VAULT_PASSWORD_FILE`? Use `ssh-agent-vault` to store the password encrypted,
and automatically decrypt it for ansible as long as your ssh-agent provides the ssh-key.

Steps:

1. Encrypt ansible vault password with `ssh-agent-vault`, using i.e. 'ansible-vault' as namespace.
2. Create wrapper script `/opt/bin/ansible-vault-password`

   ```bash
   #!/usr/bin/env bash
   /opt/bin/ssh-agent-vault decrypt
   ```

3. Setup your environment

   ```bash
   export SSH_AGENT_VAULT_NAMESPACE=ansible-vault
   export ANSIBLE_VAULT_PASSWORD_FILE=/opt/bin/ansible-vault-password
   ```

4. Start using ansible. To use a different password for another ansible project,
   just encrypt the password using another namespace, i.e. 'project2'.
   Run `export SSH_AGENT_VAULT_NAMESPACE=project2` and you are good to go.  
