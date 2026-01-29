resource "hcloud_ssh_key" "ssh_key_ed25519" {
  name       = "${var.server_username}-ssh-key-ed25519"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "hcloud_server" "microk8s" {
  name        = "${var.server_name}.broegger.dk"
  image       = var.server_image
  server_type = var.server_type
  location    = var.server_location
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  ssh_keys     = [hcloud_ssh_key.ssh_key_ed25519.id]
  firewall_ids = [hcloud_firewall.general_firewall.id]
  user_data    = <<EOF
    #cloud-config
    users:
      - name: ${var.server_username}
        groups: users, admin, microk8s
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - ${var.ssh_public_key}
    packages:
      - fail2ban
      - ufw
      - curl
      - ca-certificates
      - gnupg
      - apt-transport-https
    package_update: true
    package_upgrade: true
    write_files:
      - path: /etc/ssh/sshd_config.d/ssh-hardening.conf
        content: |
          PermitRootLogin no
          PasswordAuthentication no
          Port 2222
          KbdInteractiveAuthentication no
          ChallengeResponseAuthentication no
          MaxAuthTries 2
          AllowTcpForwarding no
          X11Forwarding no
          AllowAgentForwarding no
          AuthorizedKeysFile .ssh/authorized_keys
          AllowUsers ${var.server_username}
      - path: /etc/sysctl.d/99-k8s.conf
        permissions: "0644"
        content: |
          net.ipv4.ip_forward=1
      - path: /etc/fail2ban/jail.d/sshd.local
        permissions: "0644"
        content: |
          [sshd]
          enabled = true
          port = 2222
          maxretry = 3
          bantime = 1h
          findtime = 10m

    runcmd:
      - sysctl --system

      # UFW: avoid interactive prompts
      - ufw default deny incoming
      - ufw default allow outgoing
      - ufw allow 2222/tcp
      - ufw --force enable

      # Ensure sshd picks up the new config immediately (still fine if reboot happens later)
      - systemctl restart ssh || systemctl restart sshd
      - systemctl enable --now fail2ban

      # MicroK8s (Ubuntu/snap)
      - snap install microk8s --classic --channel=${var.microk8s_channel}
      - microk8s status --wait-ready

      # Kubectl
      - curl -fsSL https://pkgs.k8s.io/core:/stable:/v${var.microk8s_channel}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
      - chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
      - echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${var.microk8s_channel}/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
      - chmod 644 /etc/apt/sources.list.d/kubernetes.list
      - apt-get update
      - apt-get install -y kubectl

      # Optional: allow kubectl for your user
      - usermod -a -G microk8s ${var.server_username}
      - mkdir -p /home/${var.server_username}/.kube
      - microk8s config > /home/${var.server_username}/.kube/config
      - chown -R ${var.server_username}:${var.server_username} /home/${var.server_username}/.kube
      - chmod 600 /home/${var.server_username}/.kube/config

    final_message: "cloud-init finished at $TIMESTAMP"

    power_state:
      mode: reboot
      message: "Rebooting after cloud-init + microk8s install"
      timeout: 30
      condition: true
EOF
}
