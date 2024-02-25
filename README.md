<br />
<p align="center">
    <img src="/titan.png"/>
    <h3 align="center">Titan Deployment</h3>
    <p align="center">
        Titan microservice for managing user/group creation and authorization.
    </p>
</p>

## Dependencies

- Cluster Dependencies
    - [Metrics Server](https://github.com/kubernetes-sigs/metrics-server)

## Usage

Titan is a microservice that manages user/group creation and authorization. It also handles air-gapped authentication 
against the Juno user pool which is built against [AWS Cognito](https://aws.amazon.com/cognito/). Since many clients
require high security with no internet connection, Titan receives a JWT token from the client and validates it against
the Juno user pool using the public key to verify it is signed by our private key. This allows for secure authentication
without the need for internet access.

You can read more about how we do this on the official AWS documentation [here](https://github.com/awslabs/aws-support-tools/blob/master/Cognito/decode-verify-jwt/decode-verify-jwt.py).

Titan also is responsible for authorizing users and groups to access resources in the Juno ecosystem. Titan also provides 
a RESTful API for creating and managing users and groups from an outside source. This allows for easy integration with
services such as LDAP or Active Directory.

> **Note:** Titan is not responsible for managing the Juno user pool. This is done through the Juno Atlas Portal [here](https://junovfx.com).

> **Note:** Titan is slated to support things like Keycloak, Okta, and other identity providers in the future.

## Configuration

```yaml
titan:
  image:                            # Registry to pull the Titan server image from
  namespace: production             # Namespace to deploy the Titan server to

  owner:                            # Owner of the cluster

  node_selector:                    # Node selector to deploy the Titan server to
    enable: true                    # Enable node selector
    labels:                         # Node selector to deploy the Titan server to
      kubernetes.io/arch: amd64


  autoscaling:
    min_replicas: 3                 # Minimum number of replicas to run
    max_replicas: 5                 # Maximum number of replicas to run
```

### ArgoCD Application

Ideally, you will use an Application in ArgoCD to deploy Titan. Below is an example of how to set one up.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: titan
  namespace: argocd
spec:
  project: <your project>
  destination:
    server: <target cluster>
    namespace: argocd
  
  # We use the multi source approach to allow for the use of a private values repo
  # https://argo-cd.readthedocs.io/en/stable/user-guide/multiple_sources/
  sources:
    - path: .
      repoURL: https://github.com/juno-fx/Titan-Deployment.git
      targetRevision: <the version of Titan you want to use>
      helm:
        valueFiles:
          - $values/titan.yaml

    - repoURL: https://<your values repo>.git
      targetRevision: <branch>
      ref: values
```

Once ArgoCD has synchronized the application, you should see the Titan server ready to go. 