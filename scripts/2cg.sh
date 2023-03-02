NS=$1
POD=$2
CGRP=$3

PATH="/sys/fs/cgroup/$CGRP/kubepods.slice/kubepods-pod$(kubbectl get pod -n $NAMESPACE $PODNAME -o="jsonpath={.metadata.uid}" | tr -s "-" "_")"
