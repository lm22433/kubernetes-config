local utils = import '../utils.libsonnet';

local kp = (import '../kube-prometheus.libsonnet') + {
  values+: {
    grafana+: {
      dashboards+: {
        'k8s-resources-windows-namespace.json':: {},
        'k8s-resources-windows-cluster.json':: {},
        'k8s-resources-windows-pod.json':: {},
        'k8s-windows-cluster-rsrc-use.json':: {},
        'k8s-windows-node-rsrc-use.json':: {},
      },
    },
  },
};

local argoCdDashboards = {
  'argo-cd-application-overview.json': kp.argoCdMixin.grafanaDashboards['argo-cd-application-overview.json'],
  'argo-cd-operational-overview.json': kp.argoCdMixin.grafanaDashboards['argo-cd-operational-overview.json'],
};

local grafana = kp {
  values+:: {
    common+: {
      versions+:: {
        grafana: '13.3.1',
      },
    },
    grafana+:: {
      config: {
        sections: {
          database: {
            type: 'postgres',
            host: 'grafana-db:5432',
            name: '${DATABASE_NAME}',
            user: '${DATABASE_USER}',
            password: '${DATABASE_PASSWORD}',
          },
          metrics: {
            enabled: true,
          },
          users: {
            allow_sign_up: false,
            auto_assign_org: true,
            auto_assign_org_role: 'Editor',
          },
          'auth.basic': {
            enabled: true,
          },
          'auth.proxy': {
            enabled: true,
            auto_sign_up: true,
            header_name: 'X-Auth-Request-Email',
            header_property: 'email',
          },
          rbac: {
            permission_cache: false,
          },
          security: {
            disable_initial_admin_creation: false,
            admin_user: '${ADMIN_USER}',
            admin_password: '${ADMIN_PASSWORD}',
            admin_email: '${ADMIN_EMAIL}',
          },
          date_formats: {
            interval_hour: 'DD/MM HH:mm',
            interval_day: 'DD/MM',
            default_timezone: 'UTC',
          },
          dashboards: {
            default_home_dashboard_path: '',
          },
        },
      },
    },
  },
};

local manifests = {
  [name]: grafana.grafana[name]
  for name in std.objectFields(grafana.grafana)
  if grafana.grafana[name].kind != 'PrometheusRule'
};

utils.generate(manifests)
