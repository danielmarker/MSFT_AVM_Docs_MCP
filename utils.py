"""Utility functions for MCP server deployment notebook."""

import subprocess
import json
import asyncio
from mcp import ClientSession
from mcp.client.streamable_http import streamablehttp_client


def run_command(command, description):
    """Execute a shell command and return the result."""
    print(f"🔄 {description}...")
    try:
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"❌ Error: {e.stderr}")
        raise


def build_and_deploy_mcp_server(server_config, containerapp_name, resource_group_name, 
                                  container_registry_name, container_registry_login_server, 
                                  build_number):
    """Build and deploy an MCP server to Azure Container App."""
    print("=" * 60)
    print(f"🏗️ Building {server_config['display_name']}")
    print("=" * 60)
    
    image_tag = f"{server_config['image_name']}:v{build_number}"
    build_cmd = f"az acr build --image {image_tag} --resource-group {resource_group_name} --registry {container_registry_name} --file {server_config['image_name']}/Dockerfile {server_config['image_name']}/. --no-logs"
    run_command(build_cmd, f"Building and pushing {image_tag}")
    
    print(f"✅ {server_config['display_name']} image built: {image_tag}")
    
    # Update Container App
    update_cmd = f'az containerapp update --name {containerapp_name} --resource-group {resource_group_name} --image "{container_registry_login_server}/{image_tag}"'
    run_command(update_cmd, f"Updating {server_config['display_name']} Container App")
    
    print(f"✅ {server_config['display_name']} deployed successfully")
    print()


async def list_mcp_tools(server_url, server_name):
    """Connect to an MCP server and list available tools."""
    print(f"🔌 Connecting to {server_name}...")
    print(f"🌐 Server URL: {server_url}/mcp")
    try:
        async with streamablehttp_client(f"{server_url}/mcp") as streams:
            async with ClientSession(streams[0], streams[1]) as session:
                await session.initialize()
                response = await session.list_tools()
                tools = response.tools
                
        print(f"✅ Connected to {server_name}")
        print(f"📋 Available tools ({len(tools)}):")
        for tool in tools:
            print(f"  • {tool.name}")
            if hasattr(tool, 'description') and tool.description:
                print(f"    {tool.description[:100]}...")
        print()
        return tools
    except Exception as e:
        print(f"❌ Error connecting to {server_name}: {str(e)}")
        print()
        return []
