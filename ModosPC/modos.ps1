# ============================================================
#  MODOS PC - Z0R0PA
# ============================================================
#  Alternador de perfis do Windows para quem usa o MESMO PC
#  para tudo: desenvolvimento, faculdade e jogos.
#
#  O que cada modo ajusta:
#   - Plano de energia (powercfg)
#   - Prioridade de CPU (Win32PrioritySeparation)
#   - GameDVR (gravacao em segundo plano do Xbox Game Bar)
#   - Limpeza de RAM no modo JOGO (EmptyStandbyList, opcional)
#
#  O que este script NAO faz (de proposito):
#   - Nao desativa servicos criticos: anti-cheat (Vanguard),
#     Hyper-V/WSL2 (Docker), Windows Search, Windows Defender
#   - Nao aplica tweaks agressivos de registro
#
#  Como executar: botao direito no arquivo > Executar com PowerShell
#  (o script pede permissao de administrador automaticamente)
# ============================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = 'SilentlyContinue'

# ------------------------------------------------------------
# Ferramenta OPCIONAL de limpeza de RAM (EmptyStandbyList.exe)
# Procurada em pastas relativas ao script, para funcionar em
# qualquer maquina que clonar o projeto. Se nao encontrar,
# o modo JOGO funciona normalmente - apenas pula a limpeza.
# ------------------------------------------------------------
$script:LimpezaRAM = $null
foreach ($c in @(
    "$PSScriptRoot\tools\EmptyStandbyList.exe",
    "$PSScriptRoot\EmptyStandbyList.exe"
)) {
    if (Test-Path $c) { $script:LimpezaRAM = $c; break }
}

# --- Chave que guarda o modo ativo (usada pela opcao Status) ---
New-Item "HKCU:\Software\ModosPC" -Force | Out-Null

# --- Exigir admin (necessario para powercfg e chaves HKLM) ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Reiniciando com permissoes de administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host " ================================================================" -ForegroundColor Cyan
    Write-Host "                      WindowsUsingHelper"                         -ForegroundColor White
    Write-Host " ================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  COMO FUNCIONA: escolha um perfil e o Windows e ajustado na"  -ForegroundColor Gray
    Write-Host "  hora (energia, prioridade de CPU, GameDVR e limpeza de RAM)." -ForegroundColor Gray
    Write-Host "  Nada e desinstalado. Trocar de modo e instantaneo e reversivel." -ForegroundColor Gray
    Write-Host ""
    Write-Host "   [1] MODO JOGO        - Valorant / LoL / variados"        -ForegroundColor Yellow
    Write-Host "       Desempenho maximo: CPU foca no jogo + RAM limpa antes" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   [2] MODO ESTUDO/DEV  - Docker / WSL2 / IDEs / faculdade"   -ForegroundColor Yellow
    Write-Host "       Equilibrio: compilar, containers e navegador juntos"  -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   [3] MODO DIA A DIA   - uso geral"                           -ForegroundColor Yellow
    Write-Host "       Padroes do Windows: navegacao, videos, documentos"     -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   -------------------------------------------------------"   -ForegroundColor DarkGray
    Write-Host "   [4] Limpar inicializacao (remove TODOS apps de 3os)"       -ForegroundColor Yellow
    Write-Host "   [5] Status atual"                                           -ForegroundColor Yellow
    Write-Host "   [6] Restaurar padroes Windows"                              -ForegroundColor Yellow
    Write-Host "   [7] Entender os modos (explicacao detalhada)"               -ForegroundColor Yellow
    Write-Host "   [0] Sair"                                                   -ForegroundColor Yellow
    Write-Host ""
}

function Show-ModosInfo {
    Clear-Host
    Write-Host ""
    Write-Host " ================================================================" -ForegroundColor Cyan
    Write-Host "                  ENTENDA CADA MODO"                              -ForegroundColor White
    Write-Host " ================================================================" -ForegroundColor Cyan

    Write-Host ""
    Write-Host " [1] MODO JOGO - quando for jogar" -ForegroundColor Yellow
    Write-Host "   O que muda:" -ForegroundColor White
    Write-Host "   - Plano de energia ULTIMATE PERFORMANCE: o processador nao" -ForegroundColor Gray
    Write-Host "     economiza energia e mantem o clock maximo o tempo todo." -ForegroundColor Gray
    Write-Host "   - GameDVR DESLIGADO: para a gravacao em segundo plano do" -ForegroundColor Gray
    Write-Host "     Xbox Game Bar, que consome GPU/CPU enquanto voce joga." -ForegroundColor Gray
    Write-Host "   - Prioridade de CPU no PRIMEIRO PLANO: o jogo recebe" -ForegroundColor Gray
    Write-Host "     mais atencao do processador que programas de fundo." -ForegroundColor Gray
    Write-Host "   - Game Mode do Windows LIGADO: recurso oficial da" -ForegroundColor Gray
    Write-Host "     Microsoft que prioriza o jogo. Seguro com anti-cheat." -ForegroundColor Gray
    Write-Host "   - LIMPEZA DE RAM: roda o EmptyStandbyList em 3 passadas" -ForegroundColor Gray
    Write-Host "     (workingsets, modifiedpagelist e standbylist), liberando" -ForegroundColor Gray
    Write-Host "     cache de memoria acumulado durante o dia." -ForegroundColor Gray
    Write-Host "   O que NAO muda:" -ForegroundColor White
    Write-Host "   - Nenhum servico e desativado. Vanguard e anti-cheats" -ForegroundColor Gray
    Write-Host "     continuam intactos (zero risco de ban)." -ForegroundColor Gray
    Write-Host "   Rotina ideal: estava estudando/dev > opcao 1 > confirmar o" -ForegroundColor Gray
    Write-Host "   fechamento de Docker/IDEs/navegadores (salve antes) > jogar." -ForegroundColor Gray

    Write-Host ""
    Write-Host " [2] MODO ESTUDO/DEV - faculdade e programacao" -ForegroundColor Cyan
    Write-Host "   O que muda:" -ForegroundColor White
    Write-Host "   - Plano de energia EQUILIBRADO: bom para sessoes longas." -ForegroundColor Gray
    Write-Host "   - Prioridade de CPU EQUILIBRADA (padrao do Windows):" -ForegroundColor Gray
    Write-Host "     nenhum processo domina - IDE compila enquanto Docker" -ForegroundColor Gray
    Write-Host "     e navegador rodam juntos." -ForegroundColor Gray
    Write-Host "   - GameDVR volta ao padrao." -ForegroundColor Gray
    Write-Host "   Por que e diferente do modo JOGO:" -ForegroundColor White
    Write-Host "   - Scripts de otimizacao comuns priorizam processos de" -ForegroundColor Gray
    Write-Host "     fundo e desligam Hyper-V/Windows Search - isso QUEBRA" -ForegroundColor Gray
    Write-Host "     Docker, WSL2 e a busca de arquivos. Aqui nada disso" -ForegroundColor Gray
    Write-Host "     e tocado." -ForegroundColor Gray
    Write-Host "   Lembrar: Docker Desktop inicia manualmente (startup limpo)." -ForegroundColor Gray

    Write-Host ""
    Write-Host " [3] MODO DIA A DIA - uso geral" -ForegroundColor DarkYellow
    Write-Host "   Aplica os padroes do Windows: energia equilibrada," -ForegroundColor Gray
    Write-Host "   prioridade padrao, GameDVR normal. E o estado neutro." -ForegroundColor Gray

    Write-Host ""
    Write-Host " O que NUNCA e tocado (em nenhum modo):" -ForegroundColor Red
    Write-Host "   - Anti-cheats (Vanguard etc.) | Docker / WSL2" -ForegroundColor Gray
    Write-Host "   - Windows Search e Defender   | Drivers de video" -ForegroundColor Gray
    Write-Host ""
}

function Set-ModoJogo {
    Clear-Host
    Write-Host ""
    Write-Host " MODO JOGO: prepara o Windows para focar no jogo." -ForegroundColor Green
    Write-Host " (nao desativa servico algum - anti-cheats ficam intactos)" -ForegroundColor DarkGray
    Write-Host ""

    # 0) Fechar Docker, IDEs e navegadores (com confirmacao - salve antes!)
    $fechar = Read-Host " Fechar Docker, IDEs e navegadores agora? SALVE SEU TRABALHO antes (S/N)"
    if ($fechar -match '^[Ss]') {
        Write-Host "   [..] Fechando Docker, IDEs e navegadores..." -ForegroundColor Green
        $alvos = 'Docker Desktop', 'com.docker.backend', 'com.docker.build',
                 'chrome', 'msedge', 'firefox', 'brave', 'opera',
                 'Code', 'idea64', 'pycharm64', 'webstorm64', 'rider64',
                 'clion64', 'goland64', 'phpstorm64', 'devenv'
        foreach ($n in $alvos) { Stop-Process -Name $n -Force -ErrorAction SilentlyContinue }
        wsl --shutdown 2>$null
        Write-Host "   [OK] Docker/WSL, IDEs e navegadores fechados - RAM liberada" -ForegroundColor Green
    } else {
        Write-Host "   [AV] Ok - feche manualmente antes de jogar" -ForegroundColor Yellow
    }
    Write-Host ""

    # 1) Plano de energia ULTIMATE PERFORMANCE (esquema oculto do Windows)
    #    Tenta ativar o GUID original; se nao existir (nunca foi desbloqueado),
    #    desbloqueia com /duplicatescheme e ativa a copia criada.
    powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
    if ($LASTEXITCODE -ne 0) {
        # Cria a copia se ainda nao existir (evita duplicatas: procura pelo nome)
        $temUltimate = powercfg /list 2>$null | Select-String "Ultimate Performance"
        if (-not $temUltimate) {
            powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null | Out-Null
        }
        # Ativa o plano "Ultimate Performance" existente (o GUID muda a cada copia)
        $scheme = powercfg /list 2>$null | Select-String "Ultimate Performance" |
            Select-Object -First 1
        if ($scheme -match '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})') {
            powercfg /setactive $Matches[1] 2>$null
        }
    }
    Write-Host "   [OK] Energia em ULTIMATE PERFORMANCE (Desempenho Maximo)" -ForegroundColor Green

    # 2) GameDVR desligado (gravacao em 2o plano do Xbox Game Bar)
    Set-ItemProperty "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Value 0 -Type DWord
    New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Force | Out-Null
    Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name AllowGameDVR -Value 0 -Type DWord
    Write-Host "   [OK] GameDVR desligado - gravacao de fundo para de consumir GPU/CPU" -ForegroundColor Green

    # 3) Prioridade de CPU para o primeiro plano (jogos ganham)
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name Win32PrioritySeparation -Value 38 -Type DWord
    Write-Host "   [OK] CPU prioriza o JOGO em vez de programas de fundo" -ForegroundColor Green

    # 4) Game Mode oficial do Windows (seguro com anti-cheat)
    Set-ItemProperty "HKCU:\Software\Microsoft\GameBar" -Name AutoGameModeEnabled -Value 1 -Type DWord
    Set-ItemProperty "HKCU:\Software\Microsoft\GameBar" -Name AllowAutoGameMode -Value 1 -Type DWord
    Write-Host "   [OK] Game Mode do Windows ativado" -ForegroundColor Green

    # 5) Limpeza de memoria com EmptyStandbyList (se disponivel)
    if ($script:LimpezaRAM -and (Test-Path $script:LimpezaRAM)) {
        Write-Host "   [..] Limpando memoria (3 passadas, como no booster original)..." -ForegroundColor Green
        $antes = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB, 1)
        & $script:LimpezaRAM workingsets 2>$null
        & $script:LimpezaRAM modifiedpagelist 2>$null
        & $script:LimpezaRAM standbylist 2>$null
        $depois = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1MB, 1)
        $liberada = [math]::Max(0, $depois - $antes)
        Write-Host "   [OK] RAM limpa - liberados ~$liberada GB de cache" -ForegroundColor Green
    } else {
        Write-Host "   [AV] EmptyStandbyList.exe nao encontrado - limpeza de RAM pulada" -ForegroundColor Yellow
        Write-Host "        (opcional: coloque o exe em ModosPC\tools\ ou na pasta irma)" -ForegroundColor DarkGray
    }

    Set-ItemProperty "HKCU:\Software\ModosPC" -Name ModoAtual -Value "JOGO" -Type String

    Write-Host ""
    Write-Host " >>> MODO JOGO ATIVO <<<" -ForegroundColor Green
    Write-Host " Feche manualmente: Docker Desktop, IDEs e navegadores." -ForegroundColor Yellow
}

function Set-ModoEstudo {
    Clear-Host
    Write-Host ""
    Write-Host " MODO ESTUDO/DEV: equilibrio para IDE + Docker + navegador." -ForegroundColor Cyan
    Write-Host " (nao desliga Hyper-V, WSL2 ou Windows Search - Docker funciona)" -ForegroundColor DarkGray
    Write-Host ""

    # 1) Plano de energia Equilibrado
    powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null | Out-Null
    Write-Host "   [OK] Energia EQUILIBRADA - ideal para sessoes longas de estudo" -ForegroundColor Cyan

    # 2) Prioridade equilibrada (padrao do Windows)
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name Win32PrioritySeparation -Value 2 -Type DWord
    Write-Host "   [OK] CPU EQUILIBRADA - compilar, containers e navegador juntos" -ForegroundColor Cyan

    # 3) GameDVR volta ao padrao
    Set-ItemProperty "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Value 1 -Type DWord
    Remove-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name AllowGameDVR -ErrorAction SilentlyContinue
    Write-Host "   [OK] GameDVR restaurado ao padrao" -ForegroundColor Cyan

    Set-ItemProperty "HKCU:\Software\ModosPC" -Name ModoAtual -Value "ESTUDO-DEV" -Type String

    Write-Host ""
    Write-Host " >>> MODO ESTUDO/DEV ATIVO <<<" -ForegroundColor Cyan
    Write-Host " Docker Desktop inicia manualmente - abra quando for usar." -ForegroundColor Yellow
}

function Set-ModoDia {
    Clear-Host
    Write-Host ""
    Write-Host " MODO DIA A DIA: padroes do Windows para uso geral." -ForegroundColor Yellow
    Write-Host ""
    Reset-Padroes -Silencioso
    Set-ItemProperty "HKCU:\Software\ModosPC" -Name ModoAtual -Value "DIA A DIA" -Type String
    Write-Host ""
    Write-Host " >>> MODO DIA A DIA ATIVO <<<" -ForegroundColor Yellow
}

function Reset-Padroes {
    [CmdletBinding()]
    param([switch]$Silencioso)

    powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null | Out-Null
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name Win32PrioritySeparation -Value 2 -Type DWord
    Set-ItemProperty "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Value 1 -Type DWord
    Remove-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name AllowGameDVR -ErrorAction SilentlyContinue

    if (-not $Silencioso) {
        Write-Host "   [OK] Energia: Equilibrada (padrao)"      -ForegroundColor Green
        Write-Host "   [OK] Prioridade de CPU: padrao do Windows" -ForegroundColor Green
        Write-Host "   [OK] GameDVR: padrao do Windows"           -ForegroundColor Green
    }
}

function Clear-Startup {
    Clear-Host
    Write-Host ""
    Write-Host " LIMPEZA DE INICIALIZACAO" -ForegroundColor Yellow
    Write-Host " Remove apps de terceiros que abrem sozinhos com o Windows." -ForegroundColor DarkGray
    Write-Host " Voce abre cada programa manualmente quando precisar." -ForegroundColor DarkGray
    Write-Host ""

    $runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

    # Padroes de nomes de apps de terceiros (generico - funciona em qualquer PC)
    $padroes = 'Spotify', 'Steam', 'Discord', 'Docker', 'GoogleDrive',
               'Riot', 'Mozilla', 'Firefox', 'MicrosoftEdge', 'OneDrive', 'AMD'
    $removidos = 0

    $props = (Get-ItemProperty $runKey).PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' }
    foreach ($p in $props) {
        foreach ($pat in $padroes) {
            if ($p.Name -match $pat) {
                Remove-ItemProperty -Path $runKey -Name $p.Name -ErrorAction SilentlyContinue
                Write-Host "   [OK] Removido: $($p.Name)" -ForegroundColor Green
                $removidos++
                break
            }
        }
    }
    if ($removidos -eq 0) {
        Write-Host "   Nenhum app de terceiros encontrado no startup." -ForegroundColor DarkGray
    }

    # Atalhos da pasta Inicializar do usuario
    $startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $lnks = Get-ChildItem $startupFolder -Filter *.lnk -ErrorAction SilentlyContinue
    foreach ($l in $lnks) {
        Remove-Item $l.FullName -Force -ErrorAction SilentlyContinue
        Write-Host "   [OK] Removido atalho: $($l.BaseName)" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host " >>> INICIALIZACAO LIMPA <<<" -ForegroundColor Green
    Write-Host " Itens de sistema/seguranca foram mantidos." -ForegroundColor Yellow

    # Mostra o que sobrou no Run
    $restantes = (Get-ItemProperty $runKey).PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' }
    if ($restantes) {
        Write-Host ""
        Write-Host " Itens restantes no startup (verifique se sao de sistema):" -ForegroundColor Cyan
        foreach ($r in $restantes) { Write-Host "   - $($r.Name)" -ForegroundColor DarkCyan }
    }
}

function Show-Status {
    Clear-Host
    Write-Host ""
    Write-Host " ================= STATUS =================" -ForegroundColor Cyan
    Write-Host ""
    $modo = (Get-ItemProperty "HKCU:\Software\ModosPC" -ErrorAction SilentlyContinue).ModoAtual
    if (-not $modo) { $modo = "Nunca aplicado (padroes Windows)" }
    Write-Host " Modo atual: $modo" -ForegroundColor White
    Write-Host ""
    Write-Host " Plano de energia ativo:" -ForegroundColor Cyan
    powercfg /getactivescheme
    Write-Host ""
    Write-Host " Servicos criticos (devem estar Running):" -ForegroundColor Cyan
    foreach ($svc in "WSearch", "SysMain") {
        $s = Get-Service $svc -ErrorAction SilentlyContinue
        if ($s) { Write-Host "   $($s.Name): $($s.Status)" }
    }
    Write-Host ""
    Write-Host " Apps de terceiros ainda no startup:" -ForegroundColor Cyan
    $runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $achou = $false
    (Get-ItemProperty $runKey -ErrorAction SilentlyContinue).PSObject.Properties |
        Where-Object { $_.Name -match 'Spotify|Steam|Discord|Docker|GoogleDrive|Riot|Firefox|Edge|OneDrive|AMD' } |
        ForEach-Object { Write-Host "   - $($_.Name)" -ForegroundColor DarkCyan; $achou = $true }
    if (-not $achou) { Write-Host "   Nenhum - startup esta limpo." -ForegroundColor Green }
    Write-Host ""
}

# ============================================================
#  LOOP PRINCIPAL
# ============================================================
while ($true) {
    Show-Menu
    $opcao = Read-Host " Escolha uma opcao"

    switch ($opcao) {
        "1" { Set-ModoJogo }
        "2" { Set-ModoEstudo }
        "3" { Set-ModoDia }
        "4" { Clear-Startup }
        "5" { Show-Status }
        "6" {
            Clear-Host
            Write-Host ""
            Write-Host " RESTAURANDO PADROES DO WINDOWS..." -ForegroundColor Yellow
            Write-Host ""
            Reset-Padroes
            Remove-Item "HKCU:\Software\ModosPC" -Recurse -ErrorAction SilentlyContinue
            Write-Host ""
            Write-Host " >>> Tudo voltou ao padrao do Windows <<<" -ForegroundColor Green
            Write-Host " OBS: apps removidos do startup continuam fora." -ForegroundColor Yellow
            Write-Host " Reative no proprio app ou no Gerenciador de Tarefas." -ForegroundColor Yellow
        }
        "7" { Show-ModosInfo }
        "0" { exit }
    }

    Read-Host " Pressione ENTER para voltar ao menu"
}
