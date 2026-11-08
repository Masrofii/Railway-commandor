#!/usr/bin/env bash
set -Eeuo pipefail

: "${SSH_USERNAME:=commandor}"

if [[ ! "$SSH_USERNAME" =~ ^[a-z_][a-z0-9_-]*[$]?$ ]]; then
  echo "Invalid SSH_USERNAME." >&2
  exit 1
fi

mkdir -p /run/sshd

if ! id "$SSH_USERNAME" >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash "$SSH_USERNAME"
fi

# Use SSH_PASSWORD if supplied; otherwise generate a fresh password at startup.
if [[ -n "${SSH_PASSWORD:-}" ]]; then
  PASSWORD="$SSH_PASSWORD"
else
  PASSWORD="$(openssl rand -base64 24 | tr -d '\n')"
  echo
  echo "=================================================="
  echo " COMMANDOR SSH PASSWORD (save it now)"
  echo " Username: $SSH_USERNAME"
  echo " Password: $PASSWORD"
  echo "=================================================="
  echo "This generated password may change when the container restarts."
  echo
fi

printf '%s:%s\n' "$SSH_USERNAME" "$PASSWORD" | chpasswd

# Optional SSH public key. Put a PUBLIC key in Railway's AUTHORIZED_KEYS variable.
if [[ -n "${AUTHORIZED_KEYS:-}" ]]; then
  install -d -m 700 -o "$SSH_USERNAME" -g "$SSH_USERNAME" "/home/$SSH_USERNAME/.ssh"
  printf '%s\n' "$AUTHORIZED_KEYS" > "/home/$SSH_USERNAME/.ssh/authorized_keys"
  chown "$SSH_USERNAME:$SSH_USERNAME" "/home/$SSH_USERNAME/.ssh/authorized_keys"
  chmod 600 "/home/$SSH_USERNAME/.ssh/authorized_keys"
fi

ssh-keygen -A

cat > /etc/ssh/sshd_config <<'SSHD'
Port 22
AddressFamily any
ListenAddress 0.0.0.0
ListenAddress ::
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
KbdInteractiveAuthentication no
UsePAM yes
X11Forwarding no
AllowTcpForwarding yes
AllowAgentForwarding yes
PrintMotd no
Subsystem sftp /usr/lib/openssh/sftp-server
SSHD

echo "Starting COMMANDOR HOSTING SERVER SSH..."
echo "SSH username: $SSH_USERNAME"
echo "Internal SSH port: 22"
exec /usr/sbin/sshd -D -e
