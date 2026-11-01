# Windows Helper

Alternador de perfis do Windows para quem usa o mesmo PC para **desenvolvimento, faculdade e jogos**.

Um único script (`ModosPC/modos.ps1`) ajusta na hora — e de forma reversível — plano de energia, prioridade de CPU, GameDVR e limpeza de RAM, sem desativar serviços críticos (anti-cheat, Docker/WSL2, Windows Search, Defender).

## Como usar

1. Clone o projeto
2. Botão direito em `ModosPC/modos.ps1` → **Executar com PowerShell**
   (ou `powershell -ExecutionPolicy Bypass -File modos.ps1`)
3. O script pede permissão de administrador automaticamente

## Os modos

| Modo | Quando usar | O que faz |
|---|---|---|
| **1 · JOGO** | Valorant, LoL, CS2, jogos variados | Energia em Desempenho Máximo (Ultimate Performance), GameDVR desligado, CPU prioriza o jogo, Game Mode ligado, limpeza de RAM (cache da standby list, com download automático do exe se faltar) e prioridade ALTA opcional para o CS2 |
| **2 · ESTUDO/DEV** | Faculdade, IDEs, Docker/WSL2 | Energia equilibrada, prioridade equilibrada (IDE + containers + navegador juntos), GameDVR padrão |
| **3 · DIA A DIA** | Uso geral | Padrões do Windows (estado neutro) |

Extras no menu: limpar inicialização (remove apps de terceiros do startup), status atual, restaurar padrões do Windows e uma tela **"Entenda os modos"** com a explicação detalhada de cada perfil.

## Por que não desativa serviços

Otimizações comuns (estilo "boost pack") costumam desligar Hyper-V, Windows Search e priorizar processos de fundo — quebram Docker/WSL2, a busca de arquivos e atrapalham compilação. Este script foi feito para **não tocar** em nada disso e nunca desativa anti-cheats (sem risco de ban no Valorant/LoL).

## Limpeza de RAM (opcional)

No MODO JOGO, o script usa o `EmptyStandbyList.exe` para liberar o cache de memória acumulado. Como é um binário de terceiros, **não vem no repositório**. Duas formas de obtê-lo:

1. **Download automático** — se o exe não for encontrado, o modo JOGO oferece baixá-lo para `ModosPC\tools\` (fonte comunitária no GitHub, sha256 conferido contra o binário original)
2. **Manual** — coloque o exe em:

```
ModosPC/tools/EmptyStandbyList.exe
```

Sem o arquivo, o modo JOGO funciona normalmente e apenas avisa que a limpeza foi pulada.

## Instalador MSI (opcional)

O projeto pode ser empacotado num instalador MSI (per-user, sem precisar de admin para instalar):

1. Requer [WiX Toolset v3.x](https://wixtoolset.org/) instalado
2. Na pasta `installer/`:

```
build.bat
```

Isso compila `WindowsHelper.wxs` (candle + light) e gera `Windows Helper 1.0.0.msi`. O instalador copia `modos.ps1`, `README.md` e o launcher `Windows Helper.bat` para `%LOCALAPPDATA%\WindowsHelper`, cria atalho "Windows Helper" no Menu Iniciar e aparece em **Configurações → Aplicativos** para desinstalação limpa. O launcher pede elevação de admin ao abrir (necessário para o `powercfg`).

## O que não é versionado

- `RELATÓRIO.txt` — relatório msinfo32 desta máquina (dados pessoais)
- `ModosPC/tools/` — binários externos (EmptyStandbyList)
- `installer/*.msi`, `*.wixobj`, `*.wixpdb` — artefatos de build; só o `.wxs` e o `build.bat` vão pro repo
