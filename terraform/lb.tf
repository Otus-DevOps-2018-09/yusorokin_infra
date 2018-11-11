resource "google_compute_global_forwarding_rule" "reddit-app-forward" {
  name        = "reddit-app-forward"
  target      = "${google_compute_target_http_proxy.reddit-app-proxy.self_link}"
  ip_protocol = "HTTP"
  port_range  = "80"
}

resource "google_compute_target_http_proxy" "reddit-app-proxy" {
  name    = "reddit-app-proxy"
  url_map = "${google_compute_url_map.ra-url-map.self_link}"
}

resource "google_compute_url_map" "ra-url-map" {
  name            = "ra-url-map"
  default_service = "${google_compute_backend_service.reddit-backend.self_link}"

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.reddit-backend.self_link}"
  }
}

resource "google_compute_backend_service" "reddit-backend" {
  name          = "reddit-backend"
  protocol      = "HTTP"
  health_checks = ["${google_compute_health_check.default.*.self_link}"]

  backend {
    group = "${google_compute_instance_group.reddit-app-group.self_link}"
  }

  port_name = "puma-9292"
}

resource "google_compute_health_check" "default" {
  name = "reddit-health-check"

  tcp_health_check {
    port = "9292"
  }

  check_interval_sec = 3
  timeout_sec        = 2
}

resource "google_compute_instance_group" "reddit-app-group" {
  name      = "reddit-app-group"
  instances = ["${google_compute_instance.app.*.self_link}"]
  zone      = "${var.zone}"

  named_port {
    name = "puma-9292"
    port = "9292"
  }
}
