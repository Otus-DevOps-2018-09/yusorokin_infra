output "balancer_external_ip" {
  value = "${google_compute_global_forwarding_rule.reddit-app-forward.ip_address}"
}
