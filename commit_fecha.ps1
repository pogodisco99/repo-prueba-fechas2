# ==========================================================================
# commit_fecha.ps1
# ==========================================================================
# Función para hacer commits de git con la fecha que TÚ elijas.
#
# USO:
#   1. Primero "cargas" este archivo en tu sesión de PowerShell:
#        . .\commit_fecha.ps1
#   2. Luego trabajas normalmente y solo usas Commit-Fecha en lugar de
#      git commit cuando quieras fijar una fecha específica:
#
#        git add -A
#        Commit-Fecha "2026-01-01" "Día 1: setup inicial"
#
#        (modificas archivos...)
#        git add -A
#        Commit-Fecha "1/1/2026 10:30:00" "agregué main.py"
#
#        (borras archivos...)
#        git add -A
#        Commit-Fecha "15-01-2026" "limpieza de utils"
#
# FORMATOS DE FECHA QUE ACEPTA:
#   "2026-01-01"            → solo fecha (hora por defecto 00:00:00)
#   "1/1/2026"              → día/mes/año
#   "01-01-2026 10:30:00"   → fecha + hora
#   "15/01/2026 14:30"      → fecha + hora sin segundos
#
# Nota: SIEMPRE debes hacer "git add -A" antes de Commit-Fecha, igual que
#       con un commit normal. Commit-Fecha solo sustituye al "git commit".
# ==========================================================================


function Commit-Fecha {
    param(
        # Fecha del commit. Puede ser cualquier formato que PowerShell entienda.
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Fecha,

        # Mensaje del commit (igual que pasas a git commit -m).
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Mensaje
    )

    # --- 1) Convertir la fecha a formato ISO 8601 (lo que git necesita) ---
    # PowerShell es inteligente: parsea "1/1/2026", "2026-01-01", "01-15-2026", etc.
    $fechaParseada = [datetime]::Parse($Fecha)
    $fechaISO = $fechaParseada.ToString("yyyy-MM-ddTHH:mm:ss")

    Write-Host ""
    Write-Host "▶ Commit con fecha: $fechaISO" -ForegroundColor Cyan
    Write-Host "  Mensaje: $Mensaje" -ForegroundColor Cyan
    Write-Host "  Estado actual de cambios:" -ForegroundColor DarkGray

    # --- 2) Guardar variables de entorno previas (por si ya existían) ---
    $autorPrevio = $env:GIT_AUTHOR_DATE
    $commiterPrevio = $env:GIT_COMMITTER_DATE

    # --- 3) Setear las dos fechas que git lee para un commit ---
    # GIT_AUTHOR_DATE    → "cuándo se escribió el código"
    # GIT_COMMITTER_DATE → "cuándo se creó el commit"
    # Ambas deben coincidir para que GitHub muestre esa fecha.
    $env:GIT_AUTHOR_DATE = $fechaISO
    $env:GIT_COMMITTER_DATE = $fechaISO

    try {
        # --- 4) Ejecutar git commit ---
        # Pasamos el mensaje tal cual. Si tiene espacios, PowerShell lo maneja solo.
        git commit -m $Mensaje
    }
    finally {
        # --- 5) Limpiar variables de entorno al terminar ---
        # Esto es CRÍTICO: si no lo hacemos, el SIGUIENTE commit normal
        # (sin Commit-Fecha) heredaría esta fecha y sería un lío.
        if ($autorPrevio) {
            $env:GIT_AUTHOR_DATE = $autorPrevio
        } else {
            Remove-Item Env:\GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
        }
        if ($commiterPrevio) {
            $env:GIT_COMMITTER_DATE = $commiterPrevio
        } else {
            Remove-Item Env:\GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
        }
    }

    Write-Host ""
    Write-Host "✅ Commit creado con fecha $fechaISO" -ForegroundColor Green
    Write-Host "   (recuerda: git push para subirlo a GitHub)" -ForegroundColor DarkGray
    Write-Host ""
}


# ==========================================================================
# BONUS: función corta para ver el historial con fechas, sin escribir
#        todo el comando git log --pretty=... cada vez.
# ==========================================================================

function Ver-Historial {
    git log --pretty=format:"%h | %ad | %s" --date=iso
    Write-Host ""
}

Write-Host ""
Write-Host "Funciones cargadas:" -ForegroundColor Yellow
Write-Host "  Commit-Fecha  <fecha> <mensaje>   → commit con fecha personalizada" -ForegroundColor Yellow
Write-Host "  Ver-Historial                     → muestra el historial con fechas" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ejemplos:" -ForegroundColor DarkGray
Write-Host '  Commit-Fecha "2026-01-01" "setup inicial"' -ForegroundColor DarkGray
Write-Host '  Commit-Fecha "1/1/2026 10:30:00" "agregué main.py"' -ForegroundColor DarkGray
Write-Host '  Ver-Historial' -ForegroundColor DarkGray
Write-Host ""

