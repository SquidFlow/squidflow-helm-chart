# Squidflow Service Helm Chart

This Helm Chart is designed to deploy Squidflow Service with both frontend and backend components.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Features](#features)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
  - [Global Configuration](#global-configuration)
  - [Backend Configuration](#backend-configuration)
  - [Frontend Configuration](#frontend-configuration)
  - [Ingress Configuration](#ingress-configuration)
  - [ALB Configuration](#alb-specific-configuration)
  - [Application Repository Configuration](#application-repository-configuration)
- [Troubleshooting](#troubleshooting)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Ingress controller (nginx-ingress or Alibaba Cloud ALB Ingress)

## Features

- Frontend and Backend service deployment
- Configurable resource limits
- Support for both Nginx Ingress and Alibaba Cloud ALB
- Configurable autoscaling
- Built-in configuration management via ConfigMap

## Quick Start

### Installation

```shell
helm install squidflow chart \
  --set git.secrets[0].name=source-secret-rw-ssh \
  --set git.secrets[0].keyField=id_rsa \
  --set git.secrets[0].mountPath=id_rsa
```

### Uninstallation

```shell
helm uninstall squidflow
```

### Preview Template

```shell
helm template chart --set argocd.password=eYysu0BNxzDcxlSK
```

## Configuration

### Global Configuration

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `nameOverride` | Override the name part of the resources | `""` | No |
| `fullnameOverride` | Completely override the resource names | `""` | No |
| `createNamespace` | Whether to create namespace | `false` | No |
| `namespace` | Namespace to deploy the chart | `"squidflow"` | Yes |

### Backend Configuration

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `backend.replicaCount` | Number of backend replicas | `1` | No |
| `backend.service.type` | Backend service type | `ClusterIP` | No |
| `backend.service.port` | Backend service port | `38080` | Yes |
| `backend.image.repository` | Backend image repository | `ghcr.io/squidflow/service` | Yes |
| `backend.image.tag` | Backend image tag | `v0.0.3` | Yes |
| `backend.image.pullPolicy` | Backend image pull policy | `IfNotPresent` | No |
| `backend.resources.requests.cpu` | CPU requests | `100m` | No |
| `backend.resources.requests.memory` | Memory requests | `128Mi` | No |
| `backend.resources.limits.cpu` | CPU limits | `500m` | No |
| `backend.resources.limits.memory` | Memory limits | `512Mi` | No |
| `backend.env` | Environment variables | `[]` | No |

### Frontend Configuration

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `frontend.replicaCount` | Number of frontend replicas | `1` | No |
| `frontend.service.type` | Frontend service type | `ClusterIP` | No |
| `frontend.service.port` | Frontend service port | `80` | Yes |
| `frontend.image.repository` | Frontend image repository | `ghcr.io/squidflow/web` | Yes |
| `frontend.image.tag` | Frontend image tag | `v0.0.1` | Yes |
| `frontend.image.pullPolicy` | Frontend image pull policy | `IfNotPresent` | No |
| `frontend.resources.requests.cpu` | CPU requests | `100m` | No |
| `frontend.resources.requests.memory` | Memory requests | `128Mi` | No |
| `frontend.resources.limits.cpu` | CPU limits | `500m` | No |
| `frontend.resources.limits.memory` | Memory limits | `512Mi` | No |
| `frontend.env` | Environment variables | `[]` | No |

### Ingress Configuration

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `ingress.enabled` | Enable ingress | `true` | No |
| `ingress.type` | Ingress class name (e.g. `nginx`, `alb`) | `nginx` | Yes when ingress enabled |
| `ingress.host` | Hostname for the ingress | `""` | No |
| `ingress.annotations` | Ingress annotations | `{}` | No |

The ingress is configured with two paths by default:
- `/api/*` - Routes to backend service (backend:38080)
- `/*` - Routes to frontend service (frontend:80)

Example configuration:

```yaml
ingress:
  enabled: true
  type: nginx
  host: squidflow.example.com
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
```

### ALB Specific Configuration

When using Alibaba Cloud ALB (`ingress.type: alb`):

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `ingress.alb.enabled` | Enable ALB specific settings | `false` | No |
| `ingress.alb.annotations` | ALB specific annotations | See values.yaml | No |

Example ALB configuration:

```yaml
ingress:
  enabled: true
  type: alb
  alb:
    enabled: true
    annotations:
      alb.ingress.kubernetes.io/address-type: internet
      alb.ingress.kubernetes.io/vswitch-ids: "vsw-xxx"
```

### ArgoCD Configuration

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `argocd.serverAddress` | ArgoCD server address | `"argocd-server.argocd.svc.cluster.local:80"` | Yes |
| `argocd.username` | ArgoCD username | `"admin"` | Yes |
| `argocd.password` | ArgoCD password | `""` | Yes |

### Meta Repository Configuration

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `metarepo.remoteUrl` | Git repository URL for meta configuration | `"https://github.com/squidflow/gitops.git"` | Yes |
| `metarepo.accessToken` | Access token for meta repository | `""` | Yes |

Example configuration:

```yaml
metarepo:
  remoteUrl: "https://github.com/squidflow/gitops.git"
  accessToken: "your_access_token"
```

### Git SSH Configuration

Configure multiple Git SSH keys:

```yaml
git:
  secrets:
    - name: "source-secret-rw-ssh"  # Secret name
      keyField: "id_rsa"           # Field name of SSH key in secret
      mountPath: "id_rsa"          # Mounted file name
```

Install using values file:

```shell
helm install squidflow chart -f values.yaml
```

Or using command line parameters:

```shell
helm install squidflow chart \
  --set git.secrets[0].name=source-secret-rw-ssh \
  --set git.secrets[0].keyField=id_rsa \
  --set git.secrets[0].mountPath=id_rsa
```

### GitOps Configuration

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `gitops.mode` | GitOps operation mode | `"pull_request"` | No |
| `gitops.branchPrefix` | Prefix for created branches | `"squidflow-change"` | No |
| `gitops.kubeconformCrdsPath` | Path template for kubeconform CRDs | `"file:///app/crds/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json"` | No |


## example with minikube (dev)

create a local dev kuberntes cluster

```shell
minikube start
minikube addons enable ingress
```

to install the squidflow service without a create namesapce, and preapre the private key. and enable the ingerss.

```shell
kubectl create ns
kubectl -n squidflow create secret generic --from-file ~/.ssh/id_rsa source-secret-rw-ssh
helm install squidflow chart \
  --set git.secrets[0].name=source-secret-rw-ssh \
  --set git.secrets[0].keyField=id_rsa \
  --set git.secrets[0].mountPath=id_rsa \
  --set ingress.enabled=true \
  --set ingress.type=nginx
```

then forward the ingress to local

```shell
sudo minikube tunnel
```

try access the `http://localhost:` via browser

## Troubleshooting

### Common Issues

1. **Pod fails to start**
   - Check the pod logs using `kubectl logs <pod-name>`
   - Verify the image pull policy and credentials

2. **Ingress not working**
   - Ensure the ingress controller is properly installed
   - Verify the ingress class name matches your cluster setup

### Getting Support

For issues and feature requests, please create an issue in the project repository.
