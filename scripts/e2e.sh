#!/usr/bin/env bash
# Runs against a real cluster (kind in CI). Needs helm, kubectl and the kubectl-argo-rollouts plugin.
set -euo pipefail

NS=demo
REL=demo
CHART=charts/demo-service

status() { kubectl argo rollouts status "$REL" -n "$NS" --timeout "${1:-240s}"; }
stable_image() { kubectl get rollout "$REL" -n "$NS" -o jsonpath='{.status.stableRS}' >/dev/null; \
  kubectl get pods -n "$NS" -l app.kubernetes.io/name="$REL" -o jsonpath='{range .items[*]}{.spec.containers[0].image}{"\n"}{end}' | sort | uniq -c; }

echo "== 1. first install (blue)"
helm upgrade --install "$REL" "$CHART" -n "$NS" --create-namespace --set replicaCount=3
status

echo "== 2. good release (yellow) should roll out in steps and finish healthy"
helm upgrade "$REL" "$CHART" -n "$NS" --set replicaCount=3 --set image.tag=yellow
status 300s
stable_image | tee /tmp/images.txt
grep -q 'rollouts-demo:yellow' /tmp/images.txt

echo "== 3. bad release (image tag that does not exist) should be aborted"
helm upgrade "$REL" "$CHART" -n "$NS" --set replicaCount=3 --set image.tag=does-not-exist --set progressDeadlineSeconds=60
if status 200s; then
  echo "expected the bad release to fail, but it went healthy" >&2
  exit 1
fi
kubectl argo rollouts get rollout "$REL" -n "$NS" || true

echo "== 4. users should still be served by the last good version"
kubectl run probe -n "$NS" --rm -i --restart=Never --image=curlimages/curl:8.10.1 -- \
  curl -sf -o /dev/null -w 'stable service answered with %{http_code}\n' "http://$REL-stable.$NS.svc/"
stable_image | tee /tmp/images2.txt
grep -q 'rollouts-demo:yellow' /tmp/images2.txt

echo "all checks passed"
