provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "haproxy_controller" {
  metadata {
    name = "haproxy-controller"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "helm_release" "haproxy_ingress" {
  name       = "haproxy-ingress-controller"
  repository = "https://haproxytech.github.io/helm-charts"
  chart      = "kubernetes-ingress"
  namespace  = "haproxy-controller"

  set {
    name  = "controller.kind"
    value = "DaemonSet"
  }

  set {
    name  = "controller.daemonset.useHostPort"
    value = "true"

  }

  # set {
  #   name  = "controller.daemonset.hostPorts.http"
  #   value = 8080
  # }
  #
  # set {
  #   name  = "controller.daemonset.hostPorts.https"
  #   value = 8443
  # }
  #
  # set {
  #   name  = "controller.daemonset.hostPorts.stat"
  #   value = 8024
  # }

  depends_on = [
    kubernetes_namespace.haproxy_controller
  ]
}

resource "kubernetes_namespace" "haproxy_example" {
  metadata {
    name = "haproxy-example"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "helm_release" "haproxy_example" {
  name      = "haproxy-example"
  chart     = "./charts/haproxy-example"
  namespace = "haproxy-example"

  depends_on = [
    kubernetes_namespace.haproxy_example
  ]
}


resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"

  set {
    name  = "installCRDs"
    value = true
  }

  depends_on = [
    kubernetes_namespace.cert_manager
  ]
}

resource "helm_release" "cert_manager_config" {
  name  = "cert-manager"
  chart = "./charts/cert-manager-config"

  depends_on = [
    helm_release.cert_manager
  ]
}

resource "kubernetes_namespace" "onepassword" {
  metadata {
    name = "onepassword"
  }
}

resource "helm_release" "onepassword" {
  name       = "onepassword-connect"
  repository = "https://1password.github.io/connect-helm-charts"
  chart      = "connect"
  namespace  = "onepassword"

  set {
    name  = "connect.serviceType"
    value = "ClusterIP"
  }

  set {
    name  = "operator.create"
    value = true
  }

  set {
    name  = "operator.autoRestart"
    value = true
  }

  depends_on = [
    kubernetes_namespace.onepassword
  ]
}
