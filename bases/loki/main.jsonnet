local k = import 'ksonnet-util/kausal.libsonnet';
local loki = import 'loki/loki.libsonnet';

local envVar = k.core.v1.envVar;
local statefulSet = k.apps.v1.statefulSet;
local deployment = k.apps.v1.deployment;

// Drop the anti-affinity the library adds, so every pod can share one node.
local noAffinity = { spec+: { template+: { spec+: { affinity:: null } } } };
// Use the cluster's default StorageClass instead of the library's 'fast'.
local defaultStorageClass = { spec+: { storageClassName:: null } };

loki {
  _images+:: {
    loki: 'grafana/loki:3.7.10',
  },

  _config+:: {
    namespace: 'loki',
    cluster: 'homelab',

    using_tsdb_shipper: true,
    memberlist_ring_enabled: true,
    create_service_monitor: true,

    // One of everything.
    replication_factor: 1,
    memcached_replicas: 1,
    multi_zone_ingester_enabled: false,
    ingester_allow_multiple_replicas_on_same_node: true,
    distributor+: { no_schedule_constraints: true, use_topology_spread: false },
    querier+: { no_schedule_constraints: true, use_topology_spread: false, concurrency: 2 },
    queryFrontend+: { replicas: 1 },

    ingester_pvc_size: '5Gi',
    ingester_wal_disk_size: '5Gi',
    querier_pvc_size: '5Gi',
    compactor_pvc_size: '5Gi',

    // Object storage. The keys come from a Secret through the environment,
    // so nothing sensitive lands in the generated manifests.
    storage_backend: 's3',
    object_store_config: {
      aws: {
        endpoint: 'minio.minio.svc:9000',
        bucketnames: 'loki-chunks',
        access_key_id: '${S3_ACCESS_KEY_ID}',
        secret_access_key: '${S3_SECRET_ACCESS_KEY}',
        s3forcepathstyle: true,
        insecure: true,
      },
    },
    commonArgs+: { 'config.expand-env': 'true' },
    commonEnvs: [
      envVar.fromSecretRef('S3_ACCESS_KEY_ID', 'loki-s3-credentials', 'access-key-id'),
      envVar.fromSecretRef('S3_SECRET_ACCESS_KEY', 'loki-s3-credentials', 'secret-access-key'),
    ],

    loki+: {
      // No gateway in front, so run single-tenant.
      auth_enabled: false,
      ingester+: { wal+: { replay_memory_ceiling: '500MB' } },
      schema_config: {
        configs: [{
          from: '2026-11-10',
          store: 'tsdb',
          object_store: 's3',
          schema: 'v13',
          index: {
            prefix: '%s_index_' % $._config.table_prefix,
            period: '%dh' % $._config.index_period_hours,
          },
        }],
      },
    },
  },

  // The library hardcodes these sizes for a large cluster.
  distributor_container+:: k.util.resourcesRequests('50m', '128Mi') + k.util.resourcesLimits(null, '512Mi'),
  ingester_container+:: k.util.resourcesRequests('100m', '256Mi') + k.util.resourcesLimits(null, '1Gi'),
  querier_container+:: k.util.resourcesRequests('100m', '256Mi') + k.util.resourcesLimits(null, '1Gi'),
  query_frontend_container+:: k.util.resourcesRequests('50m', '128Mi') + k.util.resourcesLimits(null, '512Mi'),
  compactor_container+:: k.util.resourcesRequests('50m', '128Mi') + k.util.resourcesLimits(null, '512Mi'),

  distributor_deployment+: deployment.mixin.spec.withReplicas(1),
  ingester_statefulset+: statefulSet.mixin.spec.withReplicas(1),
  querier_statefulset+: statefulSet.mixin.spec.withReplicas(1) + noAffinity,
  query_frontend_deployment+: noAffinity,

  ingester_data_pvc+:: defaultStorageClass,
  ingester_wal_pvc+:: defaultStorageClass,
  querier_data_pvc+:: defaultStorageClass,
  compactor_data_pvc+:: defaultStorageClass,

  local smallCache = {
    memory_limit_mb:: 128,
    cpu_requests:: '25m',
    cpu_limits:: null,
    statefulSet+: noAffinity,
  },
  memcached_chunks+: smallCache,
  memcached_index_queries+: smallCache,
  memcached_frontend+: smallCache,
}
