# Example Voting App

## Lets start!

### 1. Run Locally With Docker Desktop
first of all you need Docker Desktop
then run this to start all services
```bash
docker-compose up
```

now you can open the `vote` app at [http://localhost:5000](http://localhost:5000) and `result` at [http://localhost:5001](http://localhost:5001)

### 2. production deployment (optional)
make sure you installed azure cli and terraform on your computer!.

run this
```bash
az login
```
you login then you can see your subscription id by running this
```bash
az account show
```
copy and paste your subs id to `main.tf`, in line 16, there are `subscription_id = ""` paste it here

next, make sure you're are in terraform path like this
```bash
PS C:\role_challange\example-voting-app\terraform>
```

if you're not, you can
```bash
cd .\example-voting-app\terraform\
```
then run this to initialize terraform
```bash
terraform init
```
then run this to deploy infrastructure
```bash
terraform apply --auto-approve
```
it may takes some times, be patient:)
once done, run this to connect your local `kubectl` to your AKS cluster
```bash
az aks get-credentials --resource-group voting-app-rg --name voting-app-aks
```
then you can run this to deploys your voting app to the AKS cluster
```bash
kubectl apply -f ../k8s-specifications/
```
this apply all file in `k8s-specifications` so you didn't need to apply it one by one:)

run to check pods
```bash
kubectl get pods
```
wait until it ready

you can check services using
```bash
kubectl get services
```
its time to open the app!
```bash
# Terminal 1 - Forward Vote service
kubectl port-forward service/vote 5000:8080

# Terminal 2 - Forward Result service  
kubectl port-forward service/result 5001:8081
```
congratulations! now you can access `vote` at http://localhost:5000 and `result` at http://localhost:5001

### 3. Design Decisions
#### - Architecture Analysis Approach
Document the microservices flow and dependencies
Reasoning:

- Clear Mental Model: Understanding data flow between services

- Dependency Mapping: Identified Redis as message queue, PostgreSQL as data store

- Technology Stack: Recognized polyglot architecture (Python, Node.js, .NET)

- Service Boundaries: Clear separation between voting, results, and processing
#### - Multi-stage Docker Builds
Use multi-stage builds instead of single-stage
Reasoning:

- Image Size Optimization: Final images contain only runtime dependencies

- Security: Minimal attack surface in production

- Development Experience: Dev stage includes debugging tools

- Build Performance: Cached layers for faster builds
#### - Docker Compose for Local Development
Use Docker Compose for local development
Reasoning:

- Service Discovery: Automatic networking between containers

- Health Checks: Ensures dependencies are ready before starting services

- Development Workflow: Single command to start entire stack

- Environment Consistency: Same containerized environment as production
#### - Terraform for Azure Provisioning
##### Terraform for Azure Provisioning
```hcl
resource "azurerm_kubernetes_cluster" "aks" {
  default_node_pool {
    enable_auto_scaling = true
    zones = ["2", "3"]  # High availability across zones
  }
}
```
Reasoning:

- Declarative Syntax: Clear, readable infrastructure definition

- State Management: Built-in state tracking and locking

- Plan Preview: See changes before applying

- Multi-cloud Potential: Same tool works across cloud providers
#### - Managed Kubernetes (AKS)
Use AKS instead of self-managed Kubernetes
Reasoning:

- Reduced Operational Overhead: Azure manages control plane

- Auto-scaling: Automatic node scaling based on workload

- Security: Managed identities and automatic security updates

- Cost Efficiency: Pay only for worker nodes, not control plane
#### - Network Architecture
```hcl
resource "azurerm_virtual_network" "vnet" {
  address_space = ["10.0.0.0/12"]  # Large CIDR for future growth
}
```
Custom VNET with dedicated subnet for AKS
Reasoning:

- Network Isolation: Separate from other Azure resources

- Controlled network boundaries and traffic flow

- IP Management: Predictable IP addressing for services

- Scalability: Room for cluster expansion and additional services
#### - Auto-scaling Configuration
Enable cluster auto-scaling with sensible limits
Reasoning:

- Cost Optimization: Scale down during low usage

- Performance: Scale up to handle traffic spikes

- Reliability: Ensure resources during high demand

- Budget Control: Maximum node count prevents runaway costs

### 4. Improvements i would make with more time.

With more time, I would focus on enhancing the architecture's efficiency and resilience by implementing advanced automation, intelligent scaling, and comprehensive observability. This would include automated deployment pipelines, self-healing capabilities, cost optimization through serverless components, and real-time monitoring to create a more robust and maintainable system that requires less manual intervention while delivering better performance and reliability.

thank you😊😊