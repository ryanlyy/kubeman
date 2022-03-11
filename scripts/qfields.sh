kubectl get pods -n nc3007-admin-ns -o jsonpath='{range .items[*]}{@.metadata.name}{" "}{@..containers.image}{" "}{@.status.phase}{" "}{@..startTime}{"\n"}{end}' | column -t
