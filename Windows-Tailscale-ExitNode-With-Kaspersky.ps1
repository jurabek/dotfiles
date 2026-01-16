# Tailscale-Kaspersky-Routes.ps1
# Automatically discovers and routes Tailscale infrastructure IPs
# Run as Administrator

param(
    [Parameter(Position=0)]
    [ValidateSet("install", "remove", "status", "discover")]
    [string]$Action = "status"
)

function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-DefaultGateway {
    $gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" | 
                Where-Object { $_.NextHop -ne "0.0.0.0" -and $_.InterfaceAlias -notmatch "Tailscale|Kaspersky" } |
                Sort-Object RouteMetric |
                Select-Object -First 1).NextHop
    return $gateway
}

function Get-TailscaleInfrastructureIPs {
    $ips = @{
        ControlPlane = @()
        DERP = @()
    }
    
    Write-Host "Discovering Tailscale infrastructure IPs..." -ForegroundColor Cyan
    
    # Resolve control plane
    Write-Host "  Resolving controlplane.tailscale.com..." -ForegroundColor Gray
    try {
        $controlPlane = Resolve-DnsName controlplane.tailscale.com -Type A -ErrorAction Stop
        $ips.ControlPlane = $controlPlane | Where-Object { $_.Type -eq "A" } | Select-Object -ExpandProperty IPAddress
        Write-Host "    Found $($ips.ControlPlane.Count) IPs" -ForegroundColor Green
    } catch {
        Write-Host "    Failed to resolve" -ForegroundColor Red
    }
    
    # Resolve login
    Write-Host "  Resolving login.tailscale.com..." -ForegroundColor Gray
    try {
        $login = Resolve-DnsName login.tailscale.com -Type A -ErrorAction Stop
        $loginIPs = $login | Where-Object { $_.Type -eq "A" } | Select-Object -ExpandProperty IPAddress
        $ips.ControlPlane = ($ips.ControlPlane + $loginIPs) | Select-Object -Unique
        Write-Host "    Found $($loginIPs.Count) IPs" -ForegroundColor Green
    } catch {
        Write-Host "    Failed to resolve" -ForegroundColor Red
    }
    
    # Resolve DERP servers (try derp1 through derp30)
    Write-Host "  Discovering DERP relay servers..." -ForegroundColor Gray
    $consecutiveFailures = 0
    
    for ($i = 1; $i -le 30; $i++) {
        $hostname = "derp$i.tailscale.com"
        try {
            $derp = Resolve-DnsName $hostname -Type A -ErrorAction Stop
            $derpIP = ($derp | Where-Object { $_.Type -eq "A" } | Select-Object -First 1).IPAddress
            if ($derpIP) {
                $ips.DERP += @{ Number = $i; IP = $derpIP; Hostname = $hostname }
                Write-Host "    DERP$i : $derpIP" -ForegroundColor Green
                $consecutiveFailures = 0
            }
        } catch {
            $consecutiveFailures++
            # Stop after 3 consecutive failures (likely no more DERP servers)
            if ($consecutiveFailures -ge 3) {
                Write-Host "    Stopped at DERP$i (no more servers)" -ForegroundColor Gray
                break
            }
        }
    }
    
    Write-Host "  Total: $($ips.ControlPlane.Count) control plane IPs, $($ips.DERP.Count) DERP servers" -ForegroundColor Cyan
    return $ips
}

function Install-Routes {
    $gateway = Get-DefaultGateway
    if (-not $gateway) {
        Write-Host "ERROR: Could not detect default gateway!" -ForegroundColor Red
        Write-Host "Please specify manually by editing the script." -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "`n=== Installing Tailscale bypass routes ===" -ForegroundColor Cyan
    Write-Host "Detected gateway: $gateway`n" -ForegroundColor White
    
    $ips = Get-TailscaleInfrastructureIPs
    
    # Determine if we can use a subnet for control plane (192.200.0.0/24)
    $useControlPlaneSubnet = ($ips.ControlPlane | Where-Object { $_ -match "^192\.200\.0\." }).Count -gt 5
    
    Write-Host "`nAdding routes..." -ForegroundColor Cyan
    
    if ($useControlPlaneSubnet) {
        Write-Host "  Control Plane: 192.200.0.0/24 (subnet)" -ForegroundColor Yellow
        route -p add 192.200.0.0 mask 255.255.255.0 $gateway metric 1 2>&1 | Out-Null
        Write-Host "    OK" -ForegroundColor Green
    } else {
        foreach ($ip in $ips.ControlPlane) {
            Write-Host "  Control Plane: $ip" -ForegroundColor Yellow
            route -p add $ip mask 255.255.255.255 $gateway metric 1 2>&1 | Out-Null
            Write-Host "    OK" -ForegroundColor Green
        }
    }
    
    foreach ($derp in $ips.DERP) {
        Write-Host "  DERP$($derp.Number): $($derp.IP)" -ForegroundColor Yellow
        route -p add $derp.IP mask 255.255.255.255 $gateway metric 1 2>&1 | Out-Null
        Write-Host "    OK" -ForegroundColor Green
    }
    
    Write-Host "`n=== Routes installed ===" -ForegroundColor Cyan
    Write-Host @"

NEXT STEPS:
1. Open Kaspersky VPN > Settings > Split-Tunneling
2. REMOVE or DISABLE these apps:
   - tailscale-ipn.exe
   - tailscaled.exe  
   - tailscale.exe
3. Click 'Speichern' (Save)
4. Restart Tailscale: Restart-Service Tailscale
5. Verify: tailscale status

"@ -ForegroundColor White
}

function Remove-Routes {
    Write-Host "`n=== Removing Tailscale bypass routes ===" -ForegroundColor Cyan
    
    $ips = Get-TailscaleInfrastructureIPs
    
    # Remove control plane subnet
    Write-Host "  Removing 192.200.0.0/24" -ForegroundColor Yellow
    route delete 192.200.0.0 2>&1 | Out-Null
    
    # Remove individual control plane IPs (in case they were added individually)
    foreach ($ip in $ips.ControlPlane) {
        route delete $ip 2>&1 | Out-Null
    }
    
    # Remove DERP routes
    foreach ($derp in $ips.DERP) {
        Write-Host "  Removing DERP$($derp.Number): $($derp.IP)" -ForegroundColor Yellow
        route delete $derp.IP 2>&1 | Out-Null
    }
    
    Write-Host "`n=== Done ===" -ForegroundColor Cyan
    Write-Host "Remember to re-add Tailscale apps to Kaspersky split tunneling if needed.`n"
}

function Show-Status {
    $gateway = Get-DefaultGateway
    Write-Host "`n=== Configuration ===" -ForegroundColor Cyan
    Write-Host "Detected gateway: $gateway"
    
    Write-Host "`n=== Discovering current Tailscale IPs ===" -ForegroundColor Cyan
    $ips = Get-TailscaleInfrastructureIPs
    
    Write-Host "`n=== Checking installed routes ===" -ForegroundColor Cyan
    $routeTable = route print
    
    # Check control plane
    $cpRoute = $routeTable | Select-String "192.200.0.0"
    if ($cpRoute) {
        Write-Host "Control Plane (192.200.0.0/24): INSTALLED" -ForegroundColor Green
    } else {
        Write-Host "Control Plane (192.200.0.0/24): NOT INSTALLED" -ForegroundColor Red
    }
    
    # Check DERP servers
    $installedDerp = 0
    foreach ($derp in $ips.DERP) {
        $match = $routeTable | Select-String $derp.IP
        if ($match) {
            $installedDerp++
        }
    }
    Write-Host "DERP Servers: $installedDerp / $($ips.DERP.Count) installed" -ForegroundColor $(if ($installedDerp -eq $ips.DERP.Count) { "Green" } else { "Yellow" })
    
    Write-Host "`n=== Tailscale Status ===" -ForegroundColor Cyan
    tailscale status
}

function Show-Discovery {
    Write-Host "`n=== Tailscale Infrastructure Discovery ===" -ForegroundColor Cyan
    $gateway = Get-DefaultGateway
    Write-Host "Detected gateway: $gateway`n"
    
    $ips = Get-TailscaleInfrastructureIPs
    
    Write-Host "`n=== Summary ===" -ForegroundColor Cyan
    Write-Host "Control Plane IPs:" -ForegroundColor Yellow
    $ips.ControlPlane | ForEach-Object { Write-Host "  $_" }
    
    Write-Host "`nDERP Relay Servers:" -ForegroundColor Yellow
    $ips.DERP | ForEach-Object { Write-Host "  DERP$($_.Number): $($_.IP) ($($_.Hostname))" }
}

# Main
if (-not (Test-Admin)) {
    Write-Host "ERROR: Run this script as Administrator!" -ForegroundColor Red
    exit 1
}

switch ($Action) {
    "install"  { Install-Routes }
    "remove"   { Remove-Routes }
    "status"   { Show-Status }
    "discover" { Show-Discovery }
}
