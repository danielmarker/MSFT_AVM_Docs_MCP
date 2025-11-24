# 10x CSA: AI-Powered Azure Architecture Tools

> Empower Cloud Solution Architects to become 10x more productive using AI-driven Model Context Protocol (MCP) servers for Azure infrastructure design, pricing analysis, and best practices.

## 🎯 Overview

As a **Cloud Solution Architect (CSA)**, you're constantly balancing multiple demands:
- Designing scalable, secure Azure architectures
- Staying current with Azure Verified Modules (AVM) and best practices
- Providing accurate cost estimates and pricing comparisons
- Delivering solutions quickly while maintaining quality

This repository deploys AI-powered MCP servers that integrate directly with your development tools (VS Code Copilot, Claude Desktop, and other MCP-compatible AI assistants), giving you instant access to Azure expertise and pricing data **without leaving your workflow**.

## 🚀 Why This Makes You a 10x CSA

### Traditional Workflow Pain Points
❌ Switching between browser tabs to search Azure documentation  
❌ Manually navigating the Azure Pricing Calculator  
❌ Searching GitHub for Azure Verified Modules examples  
❌ Context switching between design tools and reference materials  
❌ Copy-pasting Bicep/ARM templates from various sources  

### 10x CSA Workflow with AI + MCP
✅ **Ask your AI assistant**: "Show me the latest AVM module for Azure Storage Accounts"  
✅ **Query pricing instantly**: "Compare App Service P1v3 costs across West Europe and East US"  
✅ **Get implementation details**: "What parameters does the AVM Key Vault module support?"  
✅ **Build accurate estimates**: "Calculate monthly cost for a Standard D4s v3 VM in UK South"  
✅ **Stay in flow**: All answers delivered directly in your IDE or chat interface  

## 🛠️ What's Included

This repository deploys **two specialized MCP servers** to Azure Container Apps:

### 1. **AVM MCP Server** 
Provides real-time access to Azure Verified Modules (AVM):
- Browse the complete AVM catalog
- Retrieve module parameters and usage examples
- Access documentation and resource type details
- Stay current with Microsoft's recommended infrastructure patterns

**Example queries:**
- *"List all AVM modules related to networking"*
- *"Show me the parameters for the Azure Virtual Network module"*
- *"What's the latest version of the Key Vault AVM module?"*

### 2. **Azure Pricing MCP Server**
Instant access to Azure pricing data:
- Query the Azure Retail Prices API
- Calculate monthly costs for any Azure service
- Compare pricing across regions
- Support for consumption, reservation, and spot pricing

**Example queries:**
- *"What's the monthly cost of a P1v3 App Service Plan in West Europe?"*
- *"Compare VM pricing: D4s v3 vs D4as v5 in East US"*
- *"List all Azure Database service families with pricing"*

## 📋 Prerequisites

- **Azure Subscription** with permissions to create resources
- **Azure CLI** installed and authenticated
- **Python 3.8+** with Jupyter support
- **VS Code** (recommended) with Copilot or MCP extension, OR
- **Claude Desktop** or any MCP-compatible client

## 🎬 Quick Start

### Step 1: Clone and Deploy

```bash
# Clone this repository
git clone https://github.com/nourshaker-msft/10xcsa.git
cd 10x-csa

# Open the deployment notebook
code deploy-mcp-servers.ipynb
```

### Step 2: Run the Deployment Notebook

The included Jupyter notebook (`deploy-mcp-servers.ipynb`) automates the entire deployment:

1. **Initialize variables** - Configure deployment settings
2. **Verify Azure CLI** - Ensure you're connected to your subscription
3. **Clone MCP server repositories** - Download the latest server code
4. **Create resource group** - Provision Azure resources
5. **Deploy infrastructure** - Use Bicep to deploy Container Apps
6. **Build container images** - Build and push Docker images to ACR
7. **Retrieve endpoints** - Get your MCP server URLs
8. **Test connection** - Verify tools are accessible

**Deployment time:** ~10-15 minutes

### Step 3: Configure Your AI Assistant

#### For VS Code with MCP Extension

Add to `~/.config/Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json`:

```json
{
  "mcpServers": {
    "avm-modules": {
      "type": "http",
      "url": "https://your-avm-server.azurecontainerapps.io/mcp"
    },
    "azure-pricing": {
      "type": "http",
      "url": "https://your-pricing-server.azurecontainerapps.io/mcp"
    }
  }
}
```

#### For Claude Desktop

Add to your Claude Desktop configuration file:

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`  
**Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "avm-modules": {
      "command": "http",
      "args": ["https://your-avm-server.azurecontainerapps.io/mcp"]
    },
    "azure-pricing": {
      "command": "http",
      "args": ["https://your-pricing-server.azurecontainerapps.io/mcp"]
    }
  }
}
```

### Step 4: Start Being 10x More Productive

Open your AI assistant and start asking Azure questions directly!

## 💡 Real-World CSA Use Cases

### Architecture Design
**Before:** Search Azure docs → Find AVM module → Copy parameters → Adapt to your needs  
**Now:** *"Show me the AVM module for Azure Container Apps with Dapr enabled"*

### Cost Estimation
**Before:** Open Pricing Calculator → Configure each service → Export estimate  
**Now:** *"Calculate monthly costs: 3x D4s_v3 VMs + 1TB Premium SSD + App Gateway in East US"*

### Client Presentations
**Before:** Manually research and compile pricing comparisons  
**Now:** *"Compare Azure Database for PostgreSQL Flexible Server costs: D4s vs D8s in West Europe"*

### Proposal Development
**Before:** Hours of research to validate architecture patterns  
**Now:** *"What are the best practices for deploying AKS with the AVM modules?"*

### Knowledge Sharing
**Before:** Write documentation from scratch  
**Now:** *"Generate a deployment guide for Azure Front Door using AVM modules"*

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Your AI Assistant                        │
│         (VS Code Copilot, Claude Desktop, etc.)             │
└────────────────────┬────────────────────────────────────────┘
                     │ MCP Protocol (HTTPS)
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌───────────────┐         ┌───────────────┐
│  AVM MCP      │         │ Pricing MCP   │
│  Server       │         │ Server        │
│               │         │               │
│ Container App │         │ Container App │
└───────┬───────┘         └───────┬───────┘
        │                         │
        └────────────┬────────────┘
                     │
              ┌──────▼──────┐
              │   Azure     │
              │  Container  │
              │  Registry   │
              └─────────────┘
```

**Deployed Azure Resources:**
- Azure Container Registry (ACR)
- Container Apps Environment
- Log Analytics Workspace
- 2x Container Apps (AVM + Pricing MCP Servers)
- Managed Identity
- HTTPS Ingress with public endpoints

## 📊 Cost Considerations

Typical monthly costs for this deployment (approximate):

| Resource | Tier | Monthly Cost (UK South) |
|----------|------|------------------------|
| Container Apps | Consumption | ~£5-15 |
| Container Registry | Basic | ~£4 |
| Log Analytics | Pay-as-you-go | ~£2-5 |
| **Total** | | **~£11-24/month** |

💡 **ROI for CSAs:** If these tools save you even 1 hour per week on research and pricing lookups, you've already recouped the investment many times over.

## 🔐 Security Best Practices

- ✅ Container Apps use Managed Identity for Azure authentication
- ✅ HTTPS-only ingress with TLS 1.2+
- ✅ Container images stored in private Azure Container Registry
- ✅ Network isolation via Container Apps Environment
- 🔒 **Consider:** Add Azure Front Door with WAF for production use
- 🔒 **Consider:** Enable authentication (Azure AD) for production endpoints

## 🧹 Cleanup

To remove all deployed resources:

```bash
az group delete --name lab-10x-csa-mcp-servers --yes --no-wait
```

Or uncomment the cleanup cell in the deployment notebook.

## 🤝 Contributing

Contributions are welcome! Areas for enhancement:
- Additional MCP servers (Azure DevOps, Azure Monitor, Cost Management)
- Enhanced pricing queries and cost optimization tools
- Integration examples with Semantic Kernel
- Custom AVM module generators

## 📚 Additional Resources

- [Model Context Protocol (MCP) Documentation](https://modelcontextprotocol.io/)
- [Azure Verified Modules (AVM)](https://aka.ms/avm)
- [Azure Pricing API](https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices)
- [Azure Container Apps](https://learn.microsoft.com/en-us/azure/container-apps/)

## 🏆 Success Stories

*Have you become a 10x CSA using these tools? Share your story by opening an issue or PR!*

## 🙋‍♂️ Support

For issues, questions, or feedback:
- Open an issue in this repository
- Contact your Cloud Solution Architect team

---

**Built by CSAs, for CSAs.** 🚀

*Spend less time searching, more time architecting.*
