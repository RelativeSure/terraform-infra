resource "hcloud_firewall" "general_firewall" {
  name = "general-firewall"
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "2222"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

}
