# Changelog

Newest first. Dates are when the change landed on main.

## 2026-11

- Nov 13: README got a "What I'd do next" section.
- Nov 13: README got a diagram of the canary steps.
- Nov 8: README got a CI status badge.
- Nov 3: CI now uses azure/setup-helm v5 and actions/checkout v7.

## 2026-10

- Oct 31: Dependabot now watches the GitHub Actions versions.
- Oct 30: CI tests against Argo Rollouts v1.10.1 instead of v1.7.2. The install is applied with `kubectl apply --server-side`, because the larger v1.10 install file fails a plain apply.
- Oct 15: Trivy step cleaned up: it runs from its image, scans one target and prints quietly.
- Oct 15: First version: Helm chart with an Argo Rollouts canary, an AnalysisTemplate, an Argo CD Application, and CI (helm lint, kubeconform, Trivy, kind e2e).
